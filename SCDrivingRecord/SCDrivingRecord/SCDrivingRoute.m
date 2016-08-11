//
//  SCDrivingRoute.m
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import "SCDrivingRoute.h"

@implementation SCDrivingRoute

+ (NSString *)primaryKey {
    
    return @"primaryId";
    
}

- (long long)primaryId {
    
    return (long long)_startTime.timeIntervalSinceReferenceDate;
    
}

@end