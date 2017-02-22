//
//  UserPosViewController.m
//  LocusLabsExamples
//
//  Created by Ana Grande on 2/16/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import "UserPosViewController.h"

// ---------------------------------------------------------------------------------------------------------------------
// MainViewController
//
//  - viewDidLoad
// ---------------------------------------------------------------------------------------------------------------------
@interface UserPosViewController ()

@property (strong, nonatomic) LLAirportDatabase *airportDatabase;
@property (strong, nonatomic) LLAirport *airport;
@property (strong, nonatomic) LLFloor *floor;
@property (strong, nonatomic) LLMapView *mapView;
@property (strong, nonatomic) LLPositionManager *positionManager;
@property (strong, nonatomic) LLNavPoint *navPoint;

@end

@implementation UserPosViewController


// ---------------------------------------------------------------------------------------------------------------------
// viewDidLoad
//
// Initialize LocusLabs and then load information about all the airports the user has access to
// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Initialize the LocusLabs SDK with the accountId provided by LocusLabs.
    [LLLocusLabs setup].accountId = @"A11F4Y6SZRXH4X";
    
    // Create a new LLAirportDatabase object: our top-level entry point into the LocusLabs SDK functionality.
    // Set its delegate: asynchronous calls to LLAirportDatabase are fielded by delegate methods.
    // Initiate a request for the list of airports (to be processed later by LLAirportDatabaseDelegate.airportList)
    self.airportDatabase = [LLAirportDatabase airportDatabase];
    self.airportDatabase.delegate = self;
    [self.airportDatabase listAirports];
}

@end


// ---------------------------------------------------------------------------------------------------------------------
//  LLAirportDatabaseDelegate
//
// - airportDatabase:airportList:
// - airportDatabase:airportLoaded:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation UserPosViewController(LLAirportDatabaseDelegate)

// ---------------------------------------------------------------------------------------------------------------------
//  airportDatabase:airportList
//
//  Receive the list of available airports and (arbit      rily) pick one to show
// ---------------------------------------------------------------------------------------------------------------------
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportList:(NSArray *)airportList
{
    [self.airportDatabase loadAirport:@"lax"];
}

// ---------------------------------------------------------------------------------------------------------------------
//  airportDatabase:airportLoaded
//
//  Receive the airport loaded via airportDatabase:loadAirport, then:
//
// - select a building from that airport
// - select a floor from that building
// - asynchronously load the map for that floor
// ---------------------------------------------------------------------------------------------------------------------
- (void)airportDatabase:(LLAirportDatabase *)airportDatabase airportLoaded:(LLAirport *)airport
{
    // Store the loaded airport
    self.airport = airport;
    
    // Collect the list of buildingsInfos found in this airport and (arbitrarily) load the first one
    LLBuildingInfo *buildingInfo = [self.airport listBuildings][0];
    LLBuilding *building  = [self.airport loadBuilding:buildingInfo.buildingId];
    
    // Collect the list of floorInfos found in this building and (arbitrarily) load the first one
    LLFloorInfo *floorInfo = [building listFloors][0];
    self.floor = [building loadFloor:floorInfo.floorId];
    
    // Make self the delegate for the floor, so we receive floor:mapLoaded: calls (below)
    self.floor.delegate = self;
    
    // Load the map for the floor.  Map is sent via floor:mapLoaded:
    [self.floor loadMap];
    
    // start tracking the user's position
    [self startTrackingUserPosition];
}

// ---------------------------------------------------------------------------------------------------------------------
// startTrackingUserPosition
//
// Create a positionManager and listen to it (via a delegate); turn on "passive" positioning (which will later
// turn on "active" positioning if the user comes within the range of some beacons)
// ---------------------------------------------------------------------------------------------------------------------
- (void) startTrackingUserPosition {
    self.positionManager = [[LLPositionManager alloc] initWithAirports:@[self.airport]];
    self.positionManager.delegate = self;
    self.positionManager.passivePositioning = TRUE;
}

@end



// ---------------------------------------------------------------------------------------------------------------------
//  LLFloorDelegate
//
// -- floor:mapLoaded:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation UserPosViewController(FloorDelegate)


// ---------------------------------------------------------------------------------------------------------------------
// floor:mapLoaded
//
// Callback for LLFloor.loadMap:
//
// Create an LLMapView (which is a UIView) and place it on the screen. LLMapView renders the map
// ---------------------------------------------------------------------------------------------------------------------
- (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map
{
    // Create and initialize a new LLMapView and set its map
    LLMapView *mapView = [[LLMapView alloc] init];
    self.mapView = mapView;
    mapView.map = map;
    
    // add the mapView as a subview
    [self.view addSubview:mapView];
    
    // "constrain" the mapView to fill the entire screen
    [mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(mapView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:0 metrics:nil views:views]];
}

@end


// ---------------------------------------------------------------------------------------------------------------------
//  LLPositionManagerDelegate
//
// - positionManager:positionChanged:
// - positionManager:positioningAvailable:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation UserPosViewController(LLPositionManagerDelegate)

// ---------------------------------------------------------------------------------------------------------------------
// positionManager:positioningAvailable:
//
// Sent whenever the positionManager's ability to track the user's position changes
// ---------------------------------------------------------------------------------------------------------------------
- (void)positionManager:(LLPositionManager *)positionManager positioningAvailable:(BOOL)positioningAvailable
{
    if (positioningAvailable) {
        NSLog(@"Positioning is now available");
    } else {
        NSLog(@"Positioning is now unavailable");
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// positionManager:positionChanged:
//
// Sent whenever the positionManager detects that the user has moved to a new position--or the user's position
// cannot be determined.
//
// Note: the positionManager doesn't work in the simulator, and will only find a position
// if you happen to actually be in an airport near iBeacons.
// ---------------------------------------------------------------------------------------------------------------------
- (void)positionManager:(LLPositionManager *)positionManager positionChanged:(LLPosition *)position
{
    // the positionManager is unable to locate the user--probably because the user is not
    // near enough to any iBeacon
    if (!position) {
        return;
    }
    
    // Initialize a LLNavPoint--a blue, pulsating circle on the mapView--that will track the user's position
    if (!self.navPoint) {
        self.navPoint = [[LLNavPoint alloc] init];
        self.navPoint.floorView = [self.mapView getFloorViewForId:position.floorId];
    }
    
    // Set the navPoint's position
    self.navPoint.position = position.latLng;
    
    // If we're now near an airport, start active positioning
    if (position.nearAirport) {
        self.positionManager.activePositioning = TRUE;
    }
    
    // If we're near a venue, show it
    if (position.venueId) {
        NSLog(@"VenueId: %@",position.venueId);
    }
}

@end
