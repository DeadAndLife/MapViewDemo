//
//  ViewController.m
//  MapViewDemo
//
//  Created by qingyun on 16/7/4.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "QYAnnotation.h"

@interface ViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic)CLLocationManager *manager;

@property (nonatomic, strong)CLLocation *nowLocation;

@property (nonatomic, strong)NSMutableArray *allLcations;//定位到的所有的点

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.allLcations = [NSMutableArray array];

    
    self.manager = [[CLLocationManager alloc] init];
    //设置位置管理器的Delegate
    self.manager.delegate = self;
    //向用户申请权限
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.manager requestWhenInUseAuthorization];
    }
    
    //手机定位服务是否开启
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"在设置中打开GPS");
    }
    
    //配置location属性
    //精确度
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    //距离的频率
    self.manager.distanceFilter = 20.f;
    
    //开启定位
    [self.manager startUpdatingLocation];
}

#pragma mark - mapview delegate

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"%f, %f", mapView.region.center.latitude, mapView.region.center.longitude);
}

//根据添加的标注返回标注视图
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[QYAnnotation class]]) {
        QYAnnotation *anno = (QYAnnotation *)annotation;
        //首先从复用队列查找,如果没有,初始化
        NSString *identfier = @"qyAnnotaion";
        MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:identfier];
        if (!view) {
            view = [[MKAnnotationView alloc] initWithAnnotation:anno reuseIdentifier:identfier];
        }
        
        //绑定数据
        view.annotation = annotation;
        view.image = [UIImage imageNamed:@"anotation"];
        view.centerOffset = CGPointMake(0, -10);
        return view;
        
        
    }
    return nil;
}

//返回覆盖层的渲染图层
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    //判断是否使我们自己添加的
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        //模型对象,对应的渲染视图
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        renderer.lineWidth = 3.f;
        renderer.strokeColor = [UIColor blueColor];
        return renderer;
    }
    return nil;
}

#pragma  mark - location delegate

//授权状态改变的响应方法
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"%d", status);
}
//更新位置
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"%@", locations);
    CLLocation *location = [locations lastObject];
    //经纬度
    CLLocationCoordinate2D coordinate = [location coordinate];
    self.nowLocation = location;
    
    [self.allLcations addObject:location];
    
    
    
    //添加曲线覆盖层
    CLLocationCoordinate2D coordinates[self.allLcations.count];
    for (int i = 0; i < self.allLcations.count; i ++) {
        coordinates[i] = [self.allLcations[i] coordinate];
    }
    
    MKPolyline *poly = [MKPolyline polylineWithCoordinates:coordinates count:self.allLcations.count];
    
    [self.mapView addOverlay:poly];
    
    
    
//    配置mapView,设置显示区域(range)
    
        //区域的中心点
    CLLocationCoordinate2D center = location.coordinate;
        //设置区域的跨度
        MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
        //设置区域,
        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
        [self.mapView setRegion:region];
        self.mapView.delegate = self;
    
    
    //添加系统自带的标注
//    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
//    anno.coordinate = location.coordinate;
//    anno.title = @"郑州";
//    anno.subtitle = @"欢迎您!";
//    [self.mapView addAnnotation:anno];
    
    //添加自定义的标注
//    QYAnnotation *anno = [[QYAnnotation alloc] init];
//    anno.coordinate = location.coordinate;
//    anno.title = @"青云";
//    anno.subtitle = @"欢迎你!";
//    [self.mapView addAnnotation:anno];
}

//失败,或者出错
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}

@end
