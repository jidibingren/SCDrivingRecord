//
//  SCDrivingRouteSection.h
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import <Realm/Realm.h>

typedef NS_ENUM(NSInteger, SCDRSectionType) {
    SCDRSectionTypeNormal = 0,
    SCDRSectionTypeSpeedUp,
    SCDRSectionTypeSpeedDown,
    SCDRSectionTypeTurn,
};

RLM_ARRAY_TYPE(SCDrivingRouteSection)

@interface SCDrivingRouteSection : RLMObject

@property (nonatomic, assign)long long primaryId;

@property (nonatomic, assign)NSDate *startTime;

@property (nonatomic, assign)NSDate *endTime;

@property (nonatomic, strong)NSData *points;

@property (nonatomic, assign)NSInteger speed;

@property (nonatomic, assign)NSInteger type;

@property (nonatomic, assign)double distance;

@end
