//
//  Header.h
//  LocusLabsExamples
//
//  Created by Ana Grande on 2/16/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import <LocusLabsSDK/LocusLabsSDK.h>

@interface UserPosViewController : UIViewController @end

@interface UserPosViewController(AirportDatabaseDelegate) <LLAirportDatabaseDelegate> @end
@interface UserPosViewController(FloorDelegate)           <LLFloorDelegate>           @end
@interface UserPosViewController(PositionManagerDelegate) <LLPositionManagerDelegate> @end
