//
//  ViewController.h
//  ShowMap
//
//  Created by Ana Grande on 2/16/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import <LocusLabsSDK/LocusLabsSDK.h>

@interface ViewController : UIViewController @end

@interface ViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
@interface ViewController(FloorDelegate) <LLFloorDelegate> @end

