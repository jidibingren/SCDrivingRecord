//
//  SCMapViewController.m
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import "SCMapViewController.h"

typedef NS_ENUM(NSInteger, SCDRAnnotationType) {
    SCDRAnnotationTypeNormal = 0,
    SCDRAnnotationTypeSpeedUp,
    SCDRAnnotationTypeSpeedDown,
    SCDRAnnotationTypeTurn,
    SCDRAnnotationTypeOrigin,
    SCDRAnnotationTypeEnd,
};

#ifdef BAIDU_MAP
@interface SCAnnotation : BMKPointAnnotation
#else
@interface SCAnnotation : MAPointAnnotation
#endif

@property (nonatomic, assign)SCDRAnnotationType type;
@property (nonatomic, strong)NSString *imageName;

@end

@implementation SCAnnotation

@end

#ifdef BAIDU_MAP
@interface SCPolyline : BMKPolyline
#else
@interface SCPolyline : MAPolyline
#endif
@property (nonatomic, assign)double speed;

@end

@implementation SCPolyline

@end

#ifdef BAIDU_MAP
@interface SCMapViewController ()<BMKMapViewDelegate>{
    BMKMapView *_mapView;
}
#else
@interface SCMapViewController ()<MAMapViewDelegate>{
    MAMapView *_mapView;
}
#endif

@end

@implementation SCMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地图";
    // Do any additional setup after loading the view.
    self.routingData = GetSCDrivingRoute(@(self.primaryId));
}

- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
#ifdef BAIDU_MAP
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.frame];
    [_mapView setMapType:BMKMapTypeStandard];
    
    // 定位
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    
    //    显示比例尺
    _mapView.showMapScaleBar = YES;
#else
    _mapView = [[MAMapView alloc] initWithFrame:self.view.frame];
    [_mapView setMapType:MAMapTypeStandard];
#ifdef AMap3D
    _mapView.rotateEnabled = NO;
    _mapView.skyModelEnable = NO;
    _mapView.showsBuildings = NO;
    _mapView.cameraDegree = 0;
#else
#endif
    // 定位
    _mapView.userTrackingMode = MAUserTrackingModeNone;
    
    //    显示比例尺
    _mapView.showsScale = YES;
    
#endif
    _mapView.delegate = self;
//    _mapView.zoomLevel = 19.0;
    
    [self.view addSubview:_mapView];
    
    [self addAnnotationAndOverlay];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
#ifdef BAIDU_MAP
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
#endif

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
#ifdef BAIDU_MAP
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _mapView.showsUserLocation = NO;
#endif
}

- (void)addAnnotationAndOverlay{
    
    if (self.routingData) {
        
        NSMutableArray *overlaysArray = [NSMutableArray new];
        NSMutableArray *annotationsArray = [NSMutableArray new];
        
        for (SCDrivingRouteSection *section in self.routingData.sections) {
            
            NSUInteger count = section.points.length / sizeof(CLLocationCoordinate2D);
            
            if (count > 0) {
                
                CLLocationCoordinate2D * points = (CLLocationCoordinate2D *)(section.points.bytes);
#ifdef BAIDU_MAP
                SCPolyline *polyline = [[SCPolyline alloc]init];
                [polyline setPolylineWithCoordinates:points count:count];
#else
                SCPolyline *polyline = [SCPolyline polylineWithCoordinates:points count:count];;
#endif
                polyline.speed = section.speed;
                [overlaysArray addObject:polyline];
                
                //                if (section.type == SCSectionTypeNormal) {
                //
                //                    SCAnnotation *annotation = [SCAnnotation new];
                //                    annotation.type = section.type;
                //                    annotation.coordinate = points[count-1];
                //                    [annotationsArray addObject:annotation];
                //
                //                }
            }
        }
        
        if (overlaysArray.count > 0) {
            
            [_mapView addOverlays:overlaysArray];
            
        }
        
        SCDrivingRouteSection *section = _routingData.sections.firstObject;
        CLLocationCoordinate2D *points = (CLLocationCoordinate2D *)section.points.bytes;
        SCAnnotation *startAnnotation = [SCAnnotation new];
        startAnnotation.imageName = @"an_start";
        startAnnotation.type = SCDRAnnotationTypeOrigin;
        startAnnotation.coordinate = points[0];
        [annotationsArray addObject:startAnnotation];
        
        section = _routingData.sections.lastObject;
        points = (CLLocationCoordinate2D *)section.points.bytes;
        NSUInteger count = section.points.length/sizeof(CLLocationCoordinate2D);
        SCAnnotation *stopAnnotation = [SCAnnotation new];
        stopAnnotation.imageName = @"an_end";
        stopAnnotation.type = SCDRAnnotationTypeEnd;
        stopAnnotation.coordinate = points[count-1];
        [annotationsArray addObject:stopAnnotation];
        
        
        [self addAnnotationsFromSection:_routingData.speedUps imageName:@"an_l_accspeed"];
        
        [self addAnnotationsFromSection:_routingData.speedDowns imageName:@"an_l_break"];
        
        [self addAnnotationsFromSection:_routingData.suddenTurns imageName:@"an_l_turn"];
        
        [self addAnnotationsFromSection:_routingData.overspeeds imageName:@"an_l_overspeed"];
        
        if (annotationsArray.count > 0) {
            
            [_mapView addAnnotations:annotationsArray];
            
            [_mapView showAnnotations:annotationsArray animated:YES];
        }

    }
    
}

- (void)addAnnotationsFromSection:(SCDrivingRouteSection *)section imageName:(NSString *)imageName{
    
    NSInteger count = section.points.length / sizeof(CLLocationCoordinate2D);
    
    if (count > 0) {
        NSMutableArray *annotatons = [NSMutableArray new];
        CLLocationCoordinate2D *points = (CLLocationCoordinate2D *)section.points.bytes;
        for (NSUInteger i = 0; i < count; i++) {
            SCAnnotation *annotation = [SCAnnotation new];
            annotation.imageName = imageName;
            annotation.coordinate = points[i];
            [annotatons addObject:annotation];
        }
        
        if (annotatons.count > 0) {
            
            [_mapView addAnnotations:annotatons];
            
//            [_mapView showAnnotations:annotatons animated:YES];
        }
    }
    
}

#pragma mark - BMKMapViewDelegate
#ifdef BAIDU_MAP
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    BMKPinAnnotationView *annotationView = [BMKAnnotationView new];
    
    if ([annotation isKindOfClass:[SCAnnotation class]]) {
        SCAnnotation *scannotation = annotation;
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"SCBMKAnnotationView"];
        if (!annotationView) {
            annotationView = [[BMKPinAnnotationView alloc]initWithAnnotation:scannotation reuseIdentifier:@"SCBMKAnnotationView"];
            
        }
        
        annotationView.image = [UIImage imageNamed:scannotation.imageName];
        if (scannotation.type != SCDRAnnotationTypeOrigin && scannotation.type != SCDRAnnotationTypeEnd) {
            
            CGPoint center = annotationView.centerOffset;
            center.x += annotationView.image.size.width/4;
            annotationView.centerOffset = center;
        }
        
    }
    
    return annotationView;
}

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    
    BMKPolylineView *overlayView = [BMKPolylineView new];
    
    if ([overlay isKindOfClass:[SCPolyline class]]) {
        
        static NSArray *colors = nil;
        
        if (!colors) {
            colors = @[[UIColor redColor],[UIColor yellowColor],[UIColor greenColor],[UIColor greenColor]];
        }
        
        SCPolyline *polyline = overlay;
        overlayView = [[BMKPolylineView alloc]initWithPolyline:polyline];
        if (polyline.speed < 5.5) {
            overlayView.strokeColor = colors[0];
        }else if (polyline.speed < 11.1) {
            overlayView.strokeColor = colors[1];
        }else if (polyline.speed < 16.7) {
            overlayView.strokeColor = colors[2];
        }else {
            overlayView.strokeColor = colors[3];
        }
        
        overlayView.lineWidth = 4;
        //        overlayView.fillColor = [UIColor greenColor];
        overlayView.layer.borderWidth = 2;
        overlayView.layer.borderColor = [UIColor greenColor].CGColor;
        overlayView.layer.cornerRadius = 2;
        overlayView.layer.masksToBounds = YES;
        //        overlayView.isFocus = NO;
        
        
    }
    
    return overlayView;
}
#else
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation{
    MAPinAnnotationView *annotationView = [MAAnnotationView new];
    
    if ([annotation isKindOfClass:[SCAnnotation class]]) {
        SCAnnotation *scannotation = annotation;
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"SCBMKAnnotationView"];
        if (!annotationView) {
            annotationView = [[MAPinAnnotationView alloc]initWithAnnotation:scannotation reuseIdentifier:@"SCBMKAnnotationView"];
            
        }
        
        annotationView.image = [UIImage imageNamed:scannotation.imageName];
        
        CGPoint center = CGPointMake(annotationView.image.size.width/4, annotationView.image.size.height/4);
        
        if (scannotation.type != SCDRAnnotationTypeOrigin && scannotation.type != SCDRAnnotationTypeEnd) {
            
            center.x -= 5 - annotationView.image.size.width/2;
            center.y -= annotationView.image.size.height/2 + 7;

        }else{
            
            center.x -= 5;
            center.y -= annotationView.image.size.height/2 + 7;
    
        }
        
        annotationView.centerOffset = center;
        
    }
    
    return annotationView;
}

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay{
    
    MAPolylineView *overlayView = [MAPolylineView new];
    
    if ([overlay isKindOfClass:[SCPolyline class]]) {
        
        static NSArray *colors = nil;
        
        if (!colors) {
            colors = @[[UIColor redColor],[UIColor yellowColor],[UIColor greenColor],[UIColor greenColor]];
        }
        
        SCPolyline *polyline = overlay;
        overlayView = [[MAPolylineView alloc]initWithPolyline:polyline];
        if (polyline.speed < 5.5) {
            overlayView.strokeColor = colors[0];
        }else if (polyline.speed < 11.1) {
            overlayView.strokeColor = colors[1];
        }else if (polyline.speed < 16.7) {
            overlayView.strokeColor = colors[2];
        }else {
            overlayView.strokeColor = colors[3];
        }
        
        overlayView.lineWidth = 6;
        //        overlayView.fillColor = [UIColor greenColor];
        overlayView.layer.borderWidth = 2;
        overlayView.layer.borderColor = [UIColor greenColor].CGColor;
        overlayView.layer.cornerRadius = 2;
        overlayView.layer.masksToBounds = YES;
#ifdef AMap3D
        overlayView.lineCapType = kMALineCapRound;
        overlayView.lineJoinType = kMALineJoinRound;
#else
        
        overlayView.lineCap = kCGLineCapRound;
        overlayView.lineJoin = kCGLineJoinRound;
#endif
        //        overlayView.isFocus = NO;
        
        
    }
    
    return overlayView;
}
#endif

@end
