//
//  SCDRActivity.h
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import <Realm/Realm.h>

@interface SCDRActivity : RLMObject

@property (nonatomic, assign)long long primaryId;

@property (nonatomic, assign)int    confidence;

@property (nonatomic, assign)int    motionType;

@property (nonatomic, strong)NSDate *startDate;

@end
