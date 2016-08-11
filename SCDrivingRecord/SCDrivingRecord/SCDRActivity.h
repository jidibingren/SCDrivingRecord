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

@property (nonatomic, assign)BOOL   stationary;

@property (nonatomic, assign)BOOL   walking;

@property (nonatomic, assign)BOOL   running;

@property (nonatomic, assign)BOOL   automotive;

@property (nonatomic, assign)BOOL   cycling;

@property (nonatomic, strong)NSDate *startDate;

@end
