//
//  SCDRLocation.m
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import "SCDRLocation.h"

@implementation SCDRLocation

+ (NSString *)primaryKey {
    
    return @"primaryId";
    
}

- (long long)primaryId {
    
    //    return [NSString stringWithFormat:@"%lf",_timestamp.timeIntervalSinceReferenceDate];
    return (long long)_timestamp.timeIntervalSinceReferenceDate;
    
}

@end
