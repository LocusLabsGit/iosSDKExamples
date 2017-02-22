//
//  SearchViewController.h
//  LocusLabsExamples
//
//  Created by Ana Grande on 2/16/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import <LocusLabsSDK/LocusLabsSDK.h>

@interface SearchViewController : UIViewController @end

@interface SearchViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
@interface SearchViewController(FloorDelegate)           <LLFloorDelegate>           @end
@interface SearchViewController(MapViewDelegate)         <LLMapViewDelegate>         @end
@interface SearchViewController(AirportDelegate)         <LLAirportDelegate>         @end
@interface SearchViewController(SearchDelegate)          <LLSearchDelegate>          @end
@interface SearchViewController(POIDatabaseDelegate)     <LLPOIDatabaseDelegate>     @end
