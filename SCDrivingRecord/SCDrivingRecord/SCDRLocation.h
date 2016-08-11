//
//  SCDRLocation.h
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import <Realm/Realm.h>

@interface SCDRLocation : RLMObject

@property (nonatomic, assign)long long primaryId;

@property (nonatomic, assign)double latitude;

@property (nonatomic, assign)double longitude;

@property (nonatomic, assign)double altitude;

@property (nonatomic, assign)double horizontalAccuracy;

@property (nonatomic, assign)double verticalAccuracy;

@property (nonatomic, assign)double course;

@property (nonatomic, assign)double speed;

@property (nonatomic, strong)NSDate *timestamp;

@property (nonatomic, assign)double distance;

@end