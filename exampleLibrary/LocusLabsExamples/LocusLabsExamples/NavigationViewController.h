//
//  NavigationViewController.h
//  LocusLabsExamples
//
//  Created by Ana Grande on 2/16/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import <LocusLabsSDK/LocusLabsSDK.h>

@interface NavigationViewController : UIViewController @end

@interface NavigationViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
@interface NavigationViewController(FloorDelegate)           <LLFloorDelegate>           @end
@interface NavigationViewController(PositionManagerDelegate) <LLPositionManagerDelegate> @end
@interface NavigationViewController(MapViewDelegate)         <LLMapViewDelegate>         @end
@interface NavigationViewController(AirportDelegate)         <LLAirportDelegate>         @end
