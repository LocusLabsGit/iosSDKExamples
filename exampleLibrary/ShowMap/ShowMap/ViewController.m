//
//  ViewController.m
//  ShowMap
//
//  Created by Ana Grande on 2/16/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import "ViewController.h"

// ---------------------------------------------------------------------------------------------------------------------
// ViewController
//
//  - viewDidLoad
// ---------------------------------------------------------------------------------------------------------------------
@interface ViewController ()

@property (strong, nonatomic) LLAirportDatabase *airportDatabase;
@property (strong, nonatomic) LLAirport *airport;
@property (strong, nonatomic) LLFloor *floor;
@property (strong, nonatomic) LLMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the LocusLabs SDK with the accountId provided by LocusLabs.
    [LLLocusLabs setup].accountId = @"A11F4Y6SZRXH4X";
    
    // Create a new LLAirportDatabase object: our top-level entry point into the LocusLabs SDK functionality.
    self.airportDatabase = [LLAirportDatabase airportDatabase];
    
    // Set its delegate: asynchronous calls to LLAirportDatabase are fielded by delegate methods.
    self.airportDatabase.delegate = self;
    
    // Initiate a request for the list of airports (to be processed later by LLAirportDatabaseDelegate.airportList)
    [self.airportDatabase listAirports];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


// ---------------------------------------------------------------------------------------------------------------------
//  LLAirportDatabaseDelegate
//
// - airportDatabase:airportList:
// - airportDatabase:airportLoaded:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation ViewController(LLAirportDatabaseDelegate)

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
    LLBuildingInfo *buildingInfo = [self.airport listBuildings][0];
    LLBuilding *building  = [self.airport loadBuilding:buildingInfo.buildingId];
    
    // Collect the list of floorInfos found in this building and (arbitrarily) load the first one
    LLFloorInfo *floorInfo = [building listFloors][0];
    self.floor = [building loadFloor:floorInfo.floorId];
    
    // Set all the delegates
    self.floor.delegate = self;
    
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
@implementation ViewController(FloorDelegate)


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
    
    // add the mapView as a subview
    [self.view addSubview:mapView];
    
    // "constrain" the mapView to fill the entire screen
    [mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(mapView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:0 metrics:nil views:views]];
}

@end


