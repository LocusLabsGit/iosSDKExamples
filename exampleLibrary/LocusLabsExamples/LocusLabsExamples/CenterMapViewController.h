//
//  CenterMapViewController.h
//  LocusLabsExamples
//
//  Created by Ana Grande on 2/16/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import <LocusLabsSDK/LocusLabsSDK.h>

@interface CenterMapViewController : UIViewController @end

@interface CenterMapViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
@interface CenterMapViewController(FloorDelegate)           <LLFloorDelegate>           @end
@interface CenterMapViewController(MapViewDelegate)         <LLMapViewDelegate>         @end
