//
//  ViewController.h
//  UIExamples
//
//  Created by Ana Grande on 2/16/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import <LocusLabsSDK/LocusLabsSDK.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) NSString *theme;

@end

@interface ViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
@interface ViewController(FloorDelegate) <LLFloorDelegate> @end
@interface ViewController(MapViewDelegate) <LLMapViewDelegate> @end

