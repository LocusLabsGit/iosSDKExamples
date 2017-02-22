//
//  SearchViewController.m
//  LocusLabsExamples
//
//  Created by Ana Grande on 2/16/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import "SearchViewController.h"

// ---------------------------------------------------------------------------------------------------------------------
// MainViewController
//
//  - viewDidLoad
// ---------------------------------------------------------------------------------------------------------------------
@interface SearchViewController ()

@property (strong, nonatomic) LLAirportDatabase *airportDatabase;
@property (strong, nonatomic) LLAirport *airport;
@property (strong, nonatomic) LLFloor *floor;
@property (strong, nonatomic) LLMapView *mapView;
@property (strong, nonatomic) LLSearch *search;
@property (strong, nonatomic) LLPOIDatabase *poiDatabase;

@end

@implementation SearchViewController


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
    [LLLogger defaultLogger].logLevel = LLLogLevelDebug;
    
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
@implementation SearchViewController(LLAirportDatabaseDelegate)

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
    self.search = [self.airport search];
    self.poiDatabase = [self.airport poiDatabase];
    
    // Collect the list of buildingsInfos found in this airport and (arbitrarily) load the first one
    LLBuildingInfo *buildingInfo = [self.airport listBuildings][0];
    LLBuilding *building  = [self.airport loadBuilding:buildingInfo.buildingId];
    
    // Collect the list of floorInfos found in this building and (arbitrarily) load the first one
    LLFloorInfo *floorInfo = [building listFloors][0];
    self.floor = [building loadFloor:floorInfo.floorId];
    
    // Make self the delegate for the floor, so we receive floor:mapLoaded: calls (below)
    // Make self the delegate for the airport, so we receive airport:navigationPath:from:toDestinations: (below)
    // Make self the delegate for the search engine, so we receive search:results: (below)
    // Make self the delegate for theairport, so we receive poiDatabase:poiLoaded: (below)
    self.floor.delegate = self;
    self.airport.delegate = self;
    self.search.delegate = self;
    self.poiDatabase.delegate = self;
    
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
@implementation SearchViewController(FloorDelegate)


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
@implementation SearchViewController(LLMapViewDelegate)

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
    //self.mapView.mapCenter = [[LLLatLng alloc] initWithLat:@33.944230 lng:@-118.404152];
    self.mapView.mapCenter = [[LLLatLng alloc] initWithLat:@33.94221 lng:@-118.402057];
    self.mapView.mapRadius = @190.0;
    
    // use the search engine to look for Starbucks
    [self.search search:@"gate 62"];
    [self.search search:@"Restroom"];
    [self.search proximitySearchWithTerms:[NSArray arrayWithObjects:@"Starbucks",nil] floorId:@"lax-south-departures" lat:@33.94221 lng:@-118.402057];
    
}

@end


// ---------------------------------------------------------------------------------------------------------------------
//  LLAirportDelegate
//
//   - airport:navigationPath:from:toDestinations:
//
// ---------------------------------------------------------------------------------------------------------------------
@implementation SearchViewController(LLAirportDelegate)


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


// ---------------------------------------------------------------------------------------------------------------------
//  LLSearchDelegate
//
// -- search:results connecting the dots.
// -- proximitySearchWithTerms: Search the closest places requested.
// ---------------------------------------------------------------------------------------------------------------------
@implementation SearchViewController(LLSearchDelegate)

// ---------------------------------------------------------------------------------------------------------------------
// search:results:
//
// Process the results of a search (initiated with LLSearch.search). As examples, here, we
//
// - load more information for the POI if the query was for "Starbucks" OR
// - place a yellow dot on each of the searchReults
// ---------------------------------------------------------------------------------------------------------------------
- (void)search:(LLSearch *)search results:(LLSearchResults *)searchResults
{
    NSString *query = searchResults.query;
    
    // Get more information about the Restrooms locations from the POI database.
    if ([query isEqualToString:@"Restroom"])
    {
        for (LLSearchResult *searchResult in searchResults.results)
        {
            [self.poiDatabase loadPOI:searchResult.poiId];
        }
        return;
    }
    
    // Put a yellow dot on the map for the found objects.
    for (LLSearchResult *searchResult in searchResults.results)
    {
        LLPosition *p = searchResult.position;
        [self createCircleCenteredAt:p.latLng onFloor:p.floorId withRadius:@3 andColor:[UIColor yellowColor]];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// -- proximitySearchWithTerms: Search the closest places requested.
//
// Process the results of a search by proximity(initiated with LLSearch.proximitySearchWithTerms). As examples, here, we
//
// - place a red dot on each of the searchReults, in this example, closest Starbucks.
// ---------------------------------------------------------------------------------------------------------------------
- (void)proximitySearchWithTerms:(LLSearch *)search results:(LLSearchResults *)searchResults {
    for (LLSearchResult *searchResult in searchResults.results) {
        LLPosition *p = searchResult.position;
        [self createCircleCenteredAt:p.latLng onFloor:p.floorId withRadius:@3 andColor:[UIColor redColor]];
    }
    return;
}

@end

// ---------------------------------------------------------------------------------------------------------------------
//  LLPOIDatabaseDelegate
//
// - poiDatabase:poiLoaded:
// ---------------------------------------------------------------------------------------------------------------------
@implementation SearchViewController(LLPOIDatabaseDelegate)

// ---------------------------------------------------------------------------------------------------------------------
// poiDatabase:poiLoaded:
//
// Callback for LLPoiDatabase.loadPoi returning data for the POI. Here use the position of the POI to place a circle
// ---------------------------------------------------------------------------------------------------------------------

- (void)poiDatabase:(LLPOIDatabase *)poiDatabase poiLoaded:(LLPOI *)poi
{
    LLPosition *p = poi.position;
    [self createCircleCenteredAt:p.latLng onFloor:p.floorId withRadius:@3 andColor:[UIColor blueColor]];
}

@end

