//
//  CPULoadFilter.h
//  ActivityMonitor++
//
//  Created by st on 10/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPULoad.h"

@interface CPULoadFilter : NSObject
- (CPULoad*)filterLoad:(CPULoad*)cpuLoad;
@end
