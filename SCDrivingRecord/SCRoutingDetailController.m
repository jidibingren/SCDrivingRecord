//
//  SCRoutingDetailController.m
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import "SCRoutingDetailController.h"

@interface SCRoutingDetailController ()

@end

@implementation SCRoutingDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"路线详情";
    
    self.routingData = GetSCDrivingRoute(@(self.primaryId));
    
    [self setupSubviews];
    
}

- (void)setupSubviews{
    CGFloat marginLeft = 20;
    CGFloat marginRight = -20;
    UIView *tempView = self.view;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    UILabel *speedUpLabel = [UILabel new];
    speedUpLabel.font = [UIFont systemFontOfSize:15];
    [tempView addSubview:speedUpLabel];
    [speedUpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tempView).offset(20+64);
        make.left.mas_equalTo(tempView).offset(marginLeft);
        make.right.mas_equalTo(tempView.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    speedUpLabel.text = [NSString stringWithFormat:@"急加速:%ld次",self.routingData.speedUps.points.length/sizeof(CLLocationCoordinate2D)];
    
    UILabel *speedDownLabel = [UILabel new];
    speedDownLabel.font = [UIFont systemFontOfSize:15];
    [tempView addSubview:speedDownLabel];
    [speedDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tempView).offset(20+64);
        make.right.mas_equalTo(tempView).offset(marginRight);
        make.left.mas_equalTo(tempView.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    speedDownLabel.text = [NSString stringWithFormat:@"急减速:%ld次",self.routingData.speedDowns.points.length/sizeof(CLLocationCoordinate2D)];
    
    UILabel *speedLabel = [UILabel new];
    speedLabel.font = [UIFont systemFontOfSize:15];
    [tempView addSubview:speedLabel];
    [speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(speedUpLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(tempView).offset(marginLeft);
        make.right.mas_equalTo(tempView.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    speedLabel.text = [NSString stringWithFormat:@"最大速度:%ldm/s",self.routingData.maxSpeed];
    
    UILabel *aSpeedLabel = [UILabel new];
    aSpeedLabel.font = [UIFont systemFontOfSize:15];
    [tempView addSubview:aSpeedLabel];
    [aSpeedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(speedUpLabel.mas_bottom).offset(20);
        make.right.mas_equalTo(tempView).offset(marginRight);
        make.left.mas_equalTo(tempView.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    aSpeedLabel.text = [NSString stringWithFormat:@"平均速度:%ldm/s",self.routingData.averageSpeed];
    
    UILabel *turnLabel = [UILabel new];
    turnLabel.font = [UIFont systemFontOfSize:15];
    [tempView addSubview:turnLabel];
    [turnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(speedLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(tempView).offset(marginLeft);
        make.right.mas_equalTo(tempView.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    turnLabel.text = [NSString stringWithFormat:@"急转弯:%ld次",self.routingData.suddenTurns.points.length/sizeof(CLLocationCoordinate2D)];
    
    UILabel *distanceLabel = [UILabel new];
    distanceLabel.font = [UIFont systemFontOfSize:15];
    [tempView addSubview:distanceLabel];
    [distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(speedLabel.mas_bottom).offset(20);
        make.right.mas_equalTo(tempView).offset(marginRight);
        make.left.mas_equalTo(tempView.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    distanceLabel.text = [NSString stringWithFormat:@"路程:%ldm",(long)self.routingData.distance];
    
    UILabel *startTimeLabel = [UILabel new];
    startTimeLabel.font = [UIFont systemFontOfSize:15];
    [tempView addSubview:startTimeLabel];
    [startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(turnLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(tempView).offset(marginLeft);
        make.right.mas_equalTo(tempView).offset(marginRight);
        make.height.mas_equalTo(30);
    }];
    //    startTimeLabel.text = [NSString stringWithFormat:@"开始时间:%@",[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:self.routingData.startTime]];
    
    startTimeLabel.text = [NSString stringWithFormat:@"开始时间:%@",[dateFormatter stringFromDate:self.routingData.startTime]];
    
    UILabel *endTimeLabel = [UILabel new];
    endTimeLabel.font = [UIFont systemFontOfSize:15];
    [tempView addSubview:endTimeLabel];
    [endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(startTimeLabel.mas_bottom).offset(20);
        make.right.mas_equalTo(tempView).offset(marginRight);
        make.left.mas_equalTo(tempView).offset(marginLeft);
        make.height.mas_equalTo(30);
    }];
    //    endTimeLabel.text = [NSString stringWithFormat:@"结束时间:%@",[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:self.routingData.endTime]];
    
    endTimeLabel.text = [NSString stringWithFormat:@"结束时间:%@",[dateFormatter stringFromDate:self.routingData.endTime]];
    
    
    UILabel *scanRouteLabel = [UILabel new];
    scanRouteLabel.font = [UIFont systemFontOfSize:15];
    [tempView addSubview:scanRouteLabel];
    [scanRouteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(endTimeLabel.mas_bottom).offset(20);
        make.left.mas_equalTo(tempView).offset(marginLeft);
        make.right.mas_equalTo(tempView.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    
    __weak SCRoutingDetailController *wSelf = self;
    scanRouteLabel.text = @"查看路线";
    scanRouteLabel.userInteractionEnabled = YES;
    [scanRouteLabel bk_whenTapped:^{
        SCMapViewController *mapVC = [SCMapViewController new];
//        mapVC.routingData = wSelf.routingData;
        mapVC.primaryId = wSelf.routingData.primaryId;
        [wSelf.navigationController pushViewController:mapVC animated:YES];
    }];
    
}

@end
