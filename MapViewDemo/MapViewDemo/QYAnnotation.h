//
//  QYAnnotation.h
//  MapViewDemo
//
//  Created by qingyun on 16/7/4.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface QYAnnotation : NSObject<MKAnnotation>

@property(nonatomic)CLLocationCoordinate2D coordinate;

@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *subtitle;

@end
