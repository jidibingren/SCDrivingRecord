//
//  SCRoutingListController.m
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import "SCRoutingListController.h"

@interface SCRoutingListController (){
    __weak SCRoutingListController *wself;
}

//@property (nonatomic, strong)NSMutableArray<SCDrivingRoute*>* dataArray;
@property (nonatomic, strong)NSMutableArray<NSNumber*>* dataArray;
@end

@implementation SCRoutingListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"历史数据";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    wself = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    //    self.dataArray = [SCRoutingDataManager sharedInstance].routingsArray;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        wself.dataArray = [[SCDrivingRecord sharedInstance] getRoutes];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.tableView reloadData];
        });
    
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiHandler:) name:SCRoutesDataUpdateNotification object:nil];
}

- (void)notiHandler:(NSNotification*)noti{
    
    if ([noti.name isEqual:SCRoutesDataUpdateNotification]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
            wself.dataArray = [[SCDrivingRecord sharedInstance] getRoutes];
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.tableView reloadData];
            });

            
        });
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return _dataArray.count;
    //    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    
    // Configure the cell...
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if (indexPath.row < self.dataArray.count) {
        SCDrivingRoute *route = GetSCDrivingRoute(self.dataArray[indexPath.row]);
        cell.textLabel.text = [dateFormatter stringFromDate:route.startTime];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SCDrivingRoute *route = nil;
    if (indexPath.row < self.dataArray.count) {
        
        route = [SCDrivingRoute objectInRealm:[RLMRealm realmWithURL:[SCDrivingRecord sharedInstance].routesFilePath] forPrimaryKey:self.dataArray[indexPath.row]];
    }

    SCRoutingDetailController *rdC = [SCRoutingDetailController new];
    rdC.primaryId = route.primaryId;
    
    [self.navigationController pushViewController:rdC animated:YES];
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
