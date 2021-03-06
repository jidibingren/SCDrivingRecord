//
//  SCDrivingRecord.m
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import "SCDrivingRecord.h"
#import <CoreMotion/CoreMotion.h>


@interface SCDrivingRecord () <CLLocationManagerDelegate>

@property (nonatomic, strong)NSFileManager  *fileManager;
@property (nonatomic, strong)NSUserDefaults *userDefaults;
@property (nonatomic, strong)NSString       *documentsPath;
@property (nonatomic, strong)CLLocation     *lastLocation;

@end

@implementation SCDrivingRecord

+ (instancetype)sharedInstance {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    
    if (self = [super init]) {
        self.fileManager = [NSFileManager defaultManager];
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        self.documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        self.locationFilePath = [NSURL fileURLWithPath:[_documentsPath stringByAppendingPathComponent:@"locationFilePath.realm"]];
        
        self.activityFilePath = [NSURL fileURLWithPath:[_documentsPath stringByAppendingPathComponent:@"activityFilePath.realm"]];
        
        self.routesFilePath = [NSURL fileURLWithPath:[_documentsPath stringByAppendingPathComponent:@"routesFilePath.realm"]];
        
        self.turnThreshold = 90;
        self.speedChangeThreshold = 2;
        self.maxSpeed = 28;
        self.suddenPeedThreshold = 3;
        self.suddenPeedSubThreshold = 3;
        self.maxDiscontinuityTime = 60*3;
        self.minValidDistance = 100;
        
        [self readInfo];
    }
    
    return self;
}

- (void)saveInfo{
    
    [NSKeyedArchiver archiveRootObject:_lastLocation toFile:[_documentsPath stringByAppendingPathComponent:@"sc_driving_record_lastLocation"]];
    
}

- (void)readInfo{
    
    _lastLocation = [NSKeyedUnarchiver unarchiveObjectWithFile:[_documentsPath stringByAppendingPathComponent:@"sc_driving_record_lastLocation"]];
    
}

#pragma mark - CLLocationManager

- (void)startMonitoringLocation:(BOOL)isLocationKey {
    if (_locationManager){
        [_locationManager stopMonitoringSignificantLocationChanges];
        [_locationManager stopUpdatingLocation];
    }
    
    self.locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    
    if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
    }

    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    _locationManager.pausesLocationUpdatesAutomatically = NO;
//    isLocationKey ? [_locationManager startMonitoringSignificantLocationChanges] : [_locationManager startUpdatingLocation];
    [_locationManager startMonitoringSignificantLocationChanges];
    [_locationManager startUpdatingLocation];
    [self startMonitoringForRegionByLocation:_locationManager.location];
}

- (void)restartMonitoringLocation {
    
    [_locationManager stopMonitoringSignificantLocationChanges];
    
    [_locationManager stopUpdatingLocation];
    
    if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    
    [_locationManager startMonitoringSignificantLocationChanges];
    [_locationManager startUpdatingLocation];
}

- (void)startMonitoringForRegionByLocation:(CLLocation *)location{
    
    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:location.coordinate radius:1 identifier:@"TEST_REGION_ID"];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    [_locationManager startMonitoringForRegion:region];
}


#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager
didStartMonitoringForRegion:(CLRegion *)region{
    
}
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region{

}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region{
    
    [self startMonitoringForRegionByLocation:_locationManager.location];
}

- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(nullable CLRegion *)region
              withError:(NSError *)error{
    
    [self startMonitoringForRegionByLocation:_locationManager.location];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    if ([CMMotionActivityManager isActivityAvailable]) {
        CMMotionActivityManager *motionActivityManager = [[CMMotionActivityManager alloc] init];
        [motionActivityManager queryActivityStartingFromDate:[NSDate dateWithTimeIntervalSinceNow:-3600*24] toDate:[NSDate dateWithTimeIntervalSinceNow:0] toQueue:[NSOperationQueue new] withHandler:^(NSArray<CMMotionActivity *> * _Nullable activities, NSError * _Nullable error) {
            
            NSMutableArray *activitiesArray = [NSMutableArray new];
            
            for (CMMotionActivity *motion in activities) {
                
                SCDRActivity * activity = [[SCDRActivity alloc]init];
                activity.confidence = motion.confidence;
                if (motion.automotive) {
                    activity.motionType = SCMotionTypeAutomotive;
                }else if (motion.running) {
                    activity.motionType = SCMotionTypeRunning;
                }else if (motion.walking) {
                    activity.motionType = SCMotionTypeWalking;
                }else {
                    activity.motionType = SCMotionTypeNotMoving;
                    
                    if ([motion respondsToSelector:@selector(cycling)]) {
                        if (motion.cycling) {
                            activity.motionType = SCMotionTypeCycling;
                        }
                    }
                }
                
                activity.startDate = motion.startDate;
                
                [activitiesArray addObject:activity];
                
            }
            
            if (activitiesArray.count > 0) {
                
                RLMRealm *wrealm = [RLMRealm realmWithURL:self.activityFilePath];
                
                [wrealm beginWriteTransaction];
                [wrealm addOrUpdateObjectsFromArray:activitiesArray];
                [wrealm commitWriteTransaction];
     
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                    [self dataProcessing:SCMotionTypeAutomotive];
                }
                
            }
            
        }];
        
    }else{
        CLLocation *location = _locationManager.location;
        if ((location.speed >= 5 && _lastLocation.speed < 5) || (location.speed < 5 && _lastLocation.speed >= 5)) {
            
            SCDRActivity * activity = [[SCDRActivity alloc]init];
            if (_locationManager.location.speed > 5) {
                activity.motionType = SCMotionTypeAutomotive;
            }
            
            activity.startDate = _locationManager.location.timestamp;
            
            RLMRealm *wrealm = [RLMRealm realmWithURL:self.activityFilePath];
            
            [wrealm beginWriteTransaction];
            [wrealm addOrUpdateObject:activity];
            [wrealm commitWriteTransaction];
        }
    }


    NSMutableArray *locationsArray = [NSMutableArray new];
    
    NSMutableArray *tempLocations = [[NSMutableArray alloc]initWithArray:locations];
    
    if (locations.count == 1 && _locationManager.location) {
        tempLocations = [[NSMutableArray alloc]initWithObjects:_locationManager.location, nil];
    }
    
    for (CLLocation *location in tempLocations) {
        
        SCDRLocation * drLocation = [[SCDRLocation alloc] init];
        drLocation.latitude = location.coordinate.latitude;
        drLocation.longitude = location.coordinate.longitude;
        drLocation.altitude = location.altitude;
        drLocation.horizontalAccuracy = location.horizontalAccuracy;
        drLocation.verticalAccuracy = location.verticalAccuracy;
        drLocation.course = location.course;
        drLocation.speed = location.speed;
        drLocation.timestamp = location.timestamp;
        
        if (_lastLocation) {
            
            drLocation.distance = [location distanceFromLocation:_lastLocation];
            
        }
        
        [locationsArray addObject:drLocation];
        
        _lastLocation = location;
        
    }
    
    if (locationsArray.count > 0) {
        
        RLMRealm *wrealm = [RLMRealm realmWithURL:self.locationFilePath];
        
        [wrealm beginWriteTransaction];
        [wrealm addOrUpdateObjectsFromArray:locationsArray];
        [wrealm commitWriteTransaction];
        
    }
    
    [self saveInfo];
    
}

- (NSMutableArray *)getRoutes{
    
    RLMRealm *routesRealm = [RLMRealm realmWithURL:self.routesFilePath];
    
    RLMResults<SCDrivingRoute *> *activities = [[SCDrivingRoute allObjectsInRealm:routesRealm] sortedResultsUsingProperty:@"primaryId" ascending:NO];
    
    NSMutableArray *routes = [[NSMutableArray alloc]initWithCapacity:activities.count];
    
    for (NSUInteger i = 0, count = activities.count; i < count; i++) {
        [routes addObject:@([activities[i] primaryId])];
    }
    
    return routes.count > 0 ? routes : [NSMutableArray new];
}

- (void)dataProcessing:(SCMotionType)motionType{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        RLMRealm *activityRealm = [RLMRealm realmWithURL:self.activityFilePath];
        RLMRealm *locationsRealm = [RLMRealm realmWithURL:self.locationFilePath];
        RLMRealm *routesRealm = [RLMRealm realmWithURL:self.routesFilePath];
        
//        RLMResults<SCDRActivity *> *activities = [[SCDRActivity allObjectsInRealm:activityRealm] sortedResultsUsingProperty:@"primaryId" ascending:YES];
        
        RLMResults<SCDRActivity *> *activities = [[SCDRActivity objectsInRealm:activityRealm where:[NSString stringWithFormat:@"confidence > 0"]] sortedResultsUsingProperty:@"primaryId" ascending:YES];
        
        NSMutableArray <SCDrivingRoute *> *routesArray = [NSMutableArray new];
        
        NSMutableArray *tempActivities = [self filterActivities:activities type:motionType];
        
        for (NSUInteger i = 0, count = tempActivities.count; i < count; i++) {
            
            SCDRActivity *activitie = tempActivities[i];
            SCDRActivity *nextActivitie = nil;
            
            if (activitie.motionType != motionType || (i + 1 >= count)) {
                continue;
            }
            
            nextActivitie = tempActivities[i+1];
            
            RLMRealm *locationRealm = [RLMRealm realmWithURL:self.locationFilePath];
            
            RLMResults<SCDRLocation *> *locations = [[SCDRLocation objectsInRealm:locationRealm where:[NSString stringWithFormat:@"primaryId >= %lld AND primaryId <= %lld", activitie.primaryId, nextActivitie.primaryId]] sortedResultsUsingProperty:@"primaryId" ascending:YES];
//            RLMResults<SCDRLocation *> *locations = [[SCDRLocation objectsInRealm:locationRealm where:[NSString stringWithFormat:@"primaryId >= %lld AND primaryId <= %lld AND horizontalAccuracy <= 10 AND verticalAccuracy <= 15 AND speed >= 0 AND course >= 0", activitie.primaryId, nextActivitie.primaryId]] sortedResultsUsingProperty:@"primaryId" ascending:YES];
//            RLMResults<SCDRLocation *> *locations = [[SCDRLocation objectsInRealm:locationRealm where:[NSString stringWithFormat:@"primaryId >= %lld AND primaryId <= %lld AND horizontalAccuracy <= 200 AND verticalAccuracy <= 100", activitie.primaryId, nextActivitie.primaryId]] sortedResultsUsingProperty:@"primaryId" ascending:YES];
            
            if (!locations || locations.count < 2) {
    
                continue;
                
            }
            
            SCDrivingRoute *route = [SCDrivingRoute new];
            route.motionType = motionType;
            route.overspeeds = [self createSectionWithLocation:nil];
            route.suddenTurns = [self createSectionWithLocation:nil];
            route.speedUps = [self createSectionWithLocation:nil];
            route.speedDowns = [self createSectionWithLocation:nil];
            SCDRLocation *lastLocation = locations[0];
            route.startTime = lastLocation.timestamp;
            SCDrivingRouteSection *lastSection = [self createSectionWithLocation:lastLocation];
            
            for (NSUInteger i = 1, count = locations.count; i < count; i++) {
                
                SCDRLocation *location = locations[i];
                
                [self addPointFromLocation:location lastLocation:lastLocation toSection:lastSection];
                
                if ([self isSuddenTurn:lastLocation dest:location]) {
                    [self addPointFromLocation:location toSection:route.suddenTurns];
                }
                
                CGFloat accelerated = [self calculateAcceleratedSpeed:lastLocation destSpeed:location];
                
//                if (speedDiff > _suddenPeedThreshold && lastLocation.speed <= 3) {
//                    
//                    [self addPointFromLocation:location toSection:route.speedUps];
//                    
//                }else if (speedDiff < -_suddenPeedThreshold && location.speed < 1 ){
//                    
//                    [self addPointFromLocation:location toSection:route.speedDowns];
//                    
//                }

                if (accelerated > _suddenPeedThreshold) {
                    
                    [self addPointFromLocation:location toSection:route.speedUps];
                    
                }else if (accelerated < -_suddenPeedSubThreshold){
                    
                    [self addPointFromLocation:location toSection:route.speedDowns];
                    
                }

                if (location.speed > _maxSpeed) {
                    
                    [self addPointFromLocation:location toSection:route.overspeeds];
                    
                }
                
                if (location.speed > route.maxSpeed) {
                    
                    route.maxSpeed = location.speed;
                    
                }
                
                
                if ((ABS(location.speed-lastLocation.speed) > _speedChangeThreshold || [self isNeedAddSection:lastLocation.speed destSpeed:location.speed]) && i != (count - 1)) {
                    
                    [self addSection:lastSection ToRoute:route];
                    
                    lastSection = [self createSectionWithLocation:location];
                    
                }
                
                lastLocation = location;
                
            }
            
            [self addSection:lastSection ToRoute:route];
            
            if (route.distance > _minValidDistance && route.averageSpeed > [self minSpeedByMotionType:motionType]) {
                [routesArray addObject:route];
            }
        
        }
        
        if (routesArray.count > 0) {
            
            [routesRealm beginWriteTransaction];
            [routesRealm addOrUpdateObjectsFromArray:routesArray];
            [routesRealm commitWriteTransaction];
            
            RLMResults<SCDRLocation *> *locations = [SCDRLocation objectsInRealm:locationsRealm where:[NSString stringWithFormat:@"primaryId < %lld", (long long)[routesArray.lastObject.endTime timeIntervalSinceReferenceDate]]];
            [locationsRealm beginWriteTransaction];
            [locationsRealm deleteObjects:locations];
            [locationsRealm commitWriteTransaction];
            
            RLMResults<SCDRActivity *> *activities = [SCDRActivity objectsInRealm:activityRealm where:[NSString stringWithFormat:@"primaryId <= %lld", (long long)[routesArray.lastObject.endTime timeIntervalSinceReferenceDate]]];
            [activityRealm beginWriteTransaction];
            [activityRealm deleteObjects:activities];
            [activityRealm commitWriteTransaction];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SCRoutesDataUpdateNotification object:nil];
        }
        
        
    });
    
}

- (CGFloat)minSpeedByMotionType:(SCMotionType)motionType{
    
    CGFloat minSpeed = 0;
    
    switch (motionType) {
        case SCMotionTypeAutomotive:
            minSpeed = 3;
            break;
        case SCMotionTypeRunning:
            minSpeed = 1;
            break;
        case SCMotionTypeWalking:
            minSpeed = 0.5;
            break;
        case SCMotionTypeCycling:
            minSpeed = 1;
            break;
        default:
            break;
    }
    
    return minSpeed;
}

- (NSMutableArray<SCDRActivity*> *)filterActivities:(RLMResults<SCDRActivity*>*)activities type:(SCMotionType)motionType{
    NSMutableArray<SCDRActivity *> *tempActivities = [NSMutableArray new];
    
    for (NSUInteger i = 0, count = activities.count; i < count; ) {
        
        NSUInteger j = i;
        SCDRActivity *lastActivitie = nil;
        SCDRActivity *noAutomotiveActivitie = activities[j];
        for (; j < count; j++) {
            
            if ([activities[j] motionType] == motionType) {
                
                lastActivitie = activities[j];
                
                break;
                
            }
            
        }

        i = j + 1;
        
        if (lastActivitie) {
            
            [tempActivities addObject:lastActivitie];
            
            SCDRActivity *activitie = nil;
            
            NSUInteger k = j + 1;
            
            while (k < count) {
                for (; k < count; k++) {
                    
                    if ([activities[k] motionType] != motionType) {
                        
                        activitie = activities[k];
                        
                        break;
                        
                    }
                    
                }
                
                i = k;
                
                if (activitie) {
                    
                    SCDRActivity *nextActivitie = nil;
                    
                    NSUInteger h = k + 1;
                    
                    for (; h < count; h++) {
                        
                        if ([activities[h] motionType] == motionType) {
                            
                            nextActivitie = activities[h];
                            
                            break;
                            
                        }
                        
                    }
                    
                    i = h;
                    
                    if (nextActivitie) {
                        
                        if ( [nextActivitie.startDate timeIntervalSinceDate:activitie.startDate] > _maxDiscontinuityTime) {
                            
                            [tempActivities addObject:activitie];
                            
                            i = h - 1;
                            break;
                            
                        }else{

                            k = h + 1;
                            continue;
                        }
                        
                    }else{
                        [tempActivities addObject:activitie];
                        break;
                    }
                }else{
                    break;
                }
            }
            
            

        }else{
            [tempActivities addObject:noAutomotiveActivitie];
            break;
        }
        
    }
    
    if ([tempActivities.lastObject.startDate timeIntervalSinceNow] < -_maxDiscontinuityTime) {
        [tempActivities removeLastObject];
    }
    
    return tempActivities;
}

- (void)addSection:(SCDrivingRouteSection *)section ToRoute:(SCDrivingRoute *)route{
    
//    if (section.distance > 0) {
        section.speed = section.distance/[section.endTime timeIntervalSinceDate:section.startTime];
        SCDrivingRouteSection *lastSection = route.sections.lastObject;
        
        if (lastSection && ![self isNeedAddSection:lastSection.speed destSpeed:section.speed]) {
            
            lastSection.endTime = section.endTime;
            
            lastSection.distance += section.distance;
            
            [(NSMutableData*)lastSection.points appendBytes:section.points.bytes length:section.points.length];
            
        }else{
            
            [route.sections addObject:section];
            
        }
        route.distance += section.distance;
        route.endTime = section.endTime;
        route.averageSpeed = route.distance/[route.endTime timeIntervalSinceDate:route.startTime];
//    }
    
    return ;
}

- (CGFloat)calculateSpeedDiff:(double)orignSpeed destSpeed:(double)destSpeed{
    
    if (orignSpeed < 0 || destSpeed < 0) {
        return 0;
    }
    
    return destSpeed - orignSpeed;;
}

- (CGFloat)calculateAcceleratedSpeed:(SCDRLocation *)origin destSpeed:(SCDRLocation*)dest{
    
    if (origin.speed < 0 || dest.speed < 0 || ([dest.timestamp timeIntervalSinceDate:origin.timestamp] <= 0)) {
        return 0;
    }
    
    return (dest.speed - origin.speed)/([dest.timestamp timeIntervalSinceDate:origin.timestamp]);
}

- (BOOL)isNeedAddSection:(double)orignSpeed destSpeed:(double)destSpeed{
    
    if (orignSpeed < 0 || destSpeed < 0) {
        return NO;
    }
    
    return [self getSpeedLevelBySpeed:orignSpeed] != [self getSpeedLevelBySpeed:destSpeed];
    
}

- (BOOL)isSuddenTurn:(SCDRLocation *)orign dest:(SCDRLocation *)dest{
    
    if (orign.course < 0 || dest.course < 0 || [dest.timestamp timeIntervalSinceDate:orign.timestamp] <= 0) {
        return NO;
    }
    
    CGFloat headingOffset = ABS(dest.course - orign.course);
    
    if (headingOffset > 180) {
        headingOffset = 360 - headingOffset;
    }
    
    return  headingOffset/[dest.timestamp timeIntervalSinceDate:orign.timestamp] > _turnThreshold;
    
}

- (NSInteger)getSpeedLevelBySpeed:(double)speed{
    
    NSInteger level = 0;
    
    if (speed < 5.5) {
        level = 0;
    }else if (speed < 11.1) {
        level = 1;
    }else if (speed < 16.7) {
        level = 2;
    }else {
        level = 3;
    }
    
    return level;
}

- (SCDrivingRouteSection *)createSectionWithLocation:(SCDRLocation *)location{
    
    SCDrivingRouteSection *section = [SCDrivingRouteSection new];
    
    section.points = [NSMutableData new];
    
    if (location) {
        
        section.startTime = location.timestamp;
        
        [self addPointFromLocation:location toSection:section];
        
    }
    
    return section;
}

- (void)addPointFromLocation:(SCDRLocation *)location lastLocation:(SCDRLocation*)lastLocation toSection:(SCDrivingRouteSection*)section{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    CLLocationCoordinate2D lastCoordinate = CLLocationCoordinate2DMake(lastLocation.latitude, lastLocation.longitude);
    
    if (CLLocationCoordinate2DIsValid(coordinate) && CLLocationCoordinate2DIsValid(lastCoordinate)) {
#ifdef BAIDU_MAP
        NSDictionary* c = BMKConvertBaiduCoorFrom(coordinate, BMK_COORDTYPE_GPS);
        CLLocationCoordinate2D baiduCoordinate = BMKCoorDictionaryDecode(c);
#elif defined AMap3D
        CLLocationCoordinate2D baiduCoordinate = MACoordinateConvert(coordinate, MACoordinateTypeGPS);
        CLLocationCoordinate2D baiduCoordinate2 = MACoordinateConvert(lastCoordinate, MACoordinateTypeGPS);
        
        CGFloat distance = MAMetersBetweenMapPoints(MAMapPointForCoordinate(coordinate),MAMapPointForCoordinate(lastCoordinate));
#else
        CLLocationCoordinate2D baiduCoordinate = AMapCoordinateConvert(coordinate, AMapCoordinateTypeGPS);
#endif
        [(NSMutableData *)section.points appendBytes:&baiduCoordinate length:sizeof(CLLocationCoordinate2D)];
//        if (location.speed > 0 && location.course > 0 && location.horizontalAccuracy <= 100) {
//            section.distance += distance;
//        }
        if (location.horizontalAccuracy <= 10) {
            section.distance += distance;
        }

        section.endTime = location.timestamp;
        
    }
}

- (void)addPointFromLocation:(SCDRLocation *)location toSection:(SCDrivingRouteSection*)section{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    
    if (CLLocationCoordinate2DIsValid(coordinate)) {
#ifdef BAIDU_MAP
        NSDictionary* c = BMKConvertBaiduCoorFrom(coordinate, BMK_COORDTYPE_GPS);
        CLLocationCoordinate2D baiduCoordinate = BMKCoorDictionaryDecode(c);
#elif defined AMap3D
        CLLocationCoordinate2D baiduCoordinate = MACoordinateConvert(coordinate, MACoordinateTypeGPS);
#else
        CLLocationCoordinate2D baiduCoordinate = AMapCoordinateConvert(coordinate, AMapCoordinateTypeGPS);
#endif
        [(NSMutableData *)section.points appendBytes:&baiduCoordinate length:sizeof(CLLocationCoordinate2D)];
        if (location.speed > 0) {
            section.distance += location.distance;
        }
        section.endTime = location.timestamp;
        
    }
}

- (void)storeData:(id)data toFile:(NSString*)file{
    
    [NSKeyedArchiver archiveRootObject:data toFile:[_documentsPath stringByAppendingString:file]];
    
}

- (id)readDataFromFile:(NSString *)file{
    
    id temp = [NSKeyedUnarchiver unarchiveObjectWithFile:[_documentsPath stringByAppendingString:file]];
    
    return temp ;
}

@end
