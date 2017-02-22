//
//  NavigationViewController.m
//  LocusLabsExamples
//
//  Created by Ana Grande on 2/16/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import "NavigationViewController.h"

// ---------------------------------------------------------------------------------------------------------------------
// MainViewController
//
//  - viewDidLoad
// ---------------------------------------------------------------------------------------------------------------------
@interface NavigationViewController ()

@property (strong, nonatomic) LLAirportDatabase *airportDatabase;
@property (strong, nonatomic) LLAirport *airport;
@property (strong, nonatomic) LLFloor *floor;
@property (strong, nonatomic) LLMapView *mapView;
//@property (strong, nonatomic) LLPositionManager *positionManager;
@property (strong, nonatomic) LLNavPoint *navPoint;

@end

@implementation NavigationViewController


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
@implementation NavigationViewController(LLAirportDatabaseDelegate)

// ---------------------------------------------------------------------------------------------------------------------
//  airportDatabase:airportList
//
//  Receive the list of available airports and (arbitrarily) pick one to show
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
    LLBuilding *building  = [self.airport loadBuilding:@"lax-south"];
    
    // Collect the list of floorInfos found in this building and (arbitrarily) load the first one
    self.floor = [building loadFloor:@"lax-south-departures"];
    
    // Make self the delegate for the floor, so we receive floor:mapLoaded: calls (below)
    // Make self the delegate for the airport, so we receive airport:navigationPath:from:toDestinations: (below)
    self.floor.delegate = self;
    self.airport.delegate = self;
    
    // Load the map for the floor.  Map is sent via floor:mapLoaded:
    [self.floor loadMap];
}

@end





// ---------------------------------------------------------------------------------------------------------------------
//  LLFloorDelegate
//
// -- floor:mapLoaded:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation NavigationViewController(FloorDelegate)


// ---------------------------------------------------------------------------------------------------------------------
// floor:mapLoaded
//
// Callback for LLFloor.loadMap:
//
// Create an LLMapView (which is a UIView) and place it on the screen. LLMapView renders the map
// ---------------------------------------------------------------------------------------------------------------------
- (void)floor:(LLFloor *)floor mapLoaded:(LLMap *)map
{
    // Create and initialize a new LLMapView and set its map and delegate
    LLMapView *mapView = [[LLMapView alloc] init];
    self.mapView = mapView;
    mapView.map = map;
    mapView.delegate = self;
    
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
// LLMapViewDelegate
//
// - mapViewReady:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation NavigationViewController(LLMapViewDelegate)

// ---------------------------------------------------------------------------------------------------------------------
// mapViewReady
//
//  The mapView has finished loading asynchronously:
// -- Pan and zoom to an interesting area
// ---------------------------------------------------------------------------------------------------------------------
- (void)mapViewReady:(LLMapView *)mapView
{
    // Pan/zoom the map
    [self.mapView levelSelected:@"lax-south-departures"];
    self.mapView.mapCenter = [[LLLatLng alloc] initWithLat:@33.941384 lng:@-118.402057];
    self.mapView.mapRadius = @190.0;
    
    [self showSampleNavPath];
}

// ---------------------------------------------------------------------------------------------------------------------
// create a navigation path from two sample positions at LAX
// ---------------------------------------------------------------------------------------------------------------------
- (void)showSampleNavPath
{
    // Show a Navigation
    LLLatLng *ll1 = [[LLLatLng alloc] initWithLat:@33.940627 lng:@-118.401892];
    LLLatLng *ll2 = [[LLLatLng alloc] initWithLat:@33.9410700 lng:@-118.399598];
    
    LLPosition *p1 = [[LLPosition alloc] initWithFloor:self.floor latLng:ll1];
    LLPosition *p2 = [[LLPosition alloc] initWithFloor:self.floor latLng:ll2];
    
    [self.airport navigateFrom:p1 to:p2];
}
@end



// ---------------------------------------------------------------------------------------------------------------------
//  LLAirportDelegate
//
//   - airport:navigationPath:from:toDestinations:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation NavigationViewController(LLAirportDelegate)


// ---------------------------------------------------------------------------------------------------------------------
// airport:navigationPath:from:toDestinations:
// ---------------------------------------------------------------------------------------------------------------------
- (void)airport:(LLAirport *)airport navigationPath:(LLNavigationPath *)navigationPath from:(LLPosition *)startPosition toDestinations:(NSArray *)destinations
{
    // Create a LLPolyline from the waypoints and render it on the mapView
    [self createPolylineFromWaypoints:navigationPath.waypoints startingOnFloor:startPosition.floorId];
}

// ---------------------------------------------------------------------------------------------------------------------
// createPolylineFromWaypoints:
//
// Create a "polyline" we can place on a mapView from the passed in LLWaypoint's
// Each LLWaypoint knows its own latLng and floor
// ---------------------------------------------------------------------------------------------------------------------
- (void) createPolylineFromWaypoints:(NSArray*)waypoints startingOnFloor:(NSString*)floorId {
    
    LLMutablePath *path = [[LLMutablePath alloc] init];
    for (LLWaypoint *waypoint in waypoints) {
        
        // Add this latLng to the LLPath.
        [path addLatLng:waypoint.latLng];
        
        // Add a black circle at the destination
        if ([waypoint.isDestination boolValue]) {
            [self createCircleCenteredAt:waypoint.latLng onFloor:waypoint.floorId withRadius:@5 andColor:[UIColor blackColor]];
        }
    }
    
    // Create a new LLPolyline object and set its path
    LLPolyline *polyline = [[LLPolyline alloc] init];
    [polyline setPath:path];
    polyline.floorView = [self.mapView getFloorViewForId:floorId];
}

// ---------------------------------------------------------------------------------------------------------------------
// createCircleCenteredAt:withRadius:andColor:
// return a new LLCircle we can place on a mapView
// ---------------------------------------------------------------------------------------------------------------------
- (LLCircle*) createCircleCenteredAt:(LLLatLng*)latLng onFloor:(NSString*)floorId withRadius:(NSNumber*)radius andColor:(UIColor*)color {
    
    LLCircle *circle = [LLCircle circleWithCenter:latLng radius:radius];
    [circle setFillColor:color];
    circle.floorView = [self.mapView getFloorViewForId:floorId];
    return circle;
}

@end
