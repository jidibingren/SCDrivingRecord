//
//  SCDrivingRoute.h
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import <Realm/Realm.h>

@interface SCDrivingRoute : RLMObject

@property (nonatomic, assign)long long primaryId;

@property (nonatomic, strong)NSDate *startTime;

@property (nonatomic, strong)NSDate *endTime;

@property (nonatomic, assign)NSInteger maxSpeed;

@property (nonatomic, assign)NSInteger averageSpeed;

@property (nonatomic, assign)NSInteger speedUpCount;

@property (nonatomic, assign)NSInteger speedDownCount;

@property (nonatomic, assign)NSInteger turnCount;

@property (nonatomic, assign)double distance;

@property (nonatomic, strong)RLMArray<SCDrivingRouteSection*><SCDrivingRouteSection> *sections;

@property (nonatomic, strong)SCDrivingRouteSection *speedUps;

@property (nonatomic, strong)SCDrivingRouteSection *speedDowns;

@property (nonatomic, strong)SCDrivingRouteSection *suddenTurns;

@property (nonatomic, strong)SCDrivingRouteSection *overspeeds;

@end