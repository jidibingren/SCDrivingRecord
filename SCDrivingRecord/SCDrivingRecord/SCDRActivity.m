//
//  SCDRActivity.m
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import "SCDRActivity.h"

@implementation SCDRActivity

+ (NSString *)primaryKey {
    
    return @"primaryId";
    
}

- (long long)primaryId {
    
    //    return [NSString stringWithFormat:@"%lf",_startDate.timeIntervalSinceReferenceDate];
    return (long long)_startDate.timeIntervalSinceReferenceDate;
    
}

@end