//
//  SCDrivingRecord.h
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCRoutesDataUpdateNotification @"SCRoutesDataUpdateNotification"

#define GetSCDrivingRoute(primaryKey) [SCDrivingRoute objectInRealm:\
            [RLMRealm realmWithURL:[SCDrivingRecord sharedInstance].routesFilePath]\
            forPrimaryKey:primaryKey];

typedef NS_ENUM(NSInteger, SCMotionType) {
    SCMotionTypeNotMoving = 1,
    SCMotionTypeWalking,
    SCMotionTypeRunning,
    SCMotionTypeAutomotive,
    SCMotionTypeCycling,
};

@interface SCDrivingRecord : NSObject

+(instancetype)sharedInstance;

-(instancetype) init __attribute__((unavailable("init not available")));

@property (nonatomic) CLLocationManager * locationManager;

@property (nonatomic, strong)NSURL *locationFilePath;
@property (nonatomic, strong)NSURL *activityFilePath;
@property (nonatomic, strong)NSURL *routesFilePath;

@property (nonatomic, assign)NSInteger    turnThreshold;
@property (nonatomic, assign)NSInteger    maxSpeed;
@property (nonatomic, assign)NSInteger    speedChangeThreshold;
@property (nonatomic, assign)NSInteger    suddenPeedThreshold;
@property (nonatomic, assign)NSInteger    maxDiscontinuityTime;
@property (nonatomic, assign)CGFloat      minValidDistance;

- (void)startMonitoringLocation:(BOOL)isLocationKey;
- (void)restartMonitoringLocation;
- (void)dataProcessing:(SCMotionType)motionType;
- (NSMutableArray *)getRoutes;

@end
