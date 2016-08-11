//
//  SCMapViewController.h
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCMapViewController : UIViewController

@property (nonatomic, assign)long long primaryId;
@property (nonatomic, strong)SCDrivingRoute *routingData;

@end
