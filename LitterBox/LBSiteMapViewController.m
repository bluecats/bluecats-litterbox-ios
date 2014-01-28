//
//  LBSiteMapViewController.m
//  LitterBox
//
//  Created by Cody Singleton on 11/18/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBSiteMapViewController.h"
#import "BCMicroLocationManager.h"
#import "BCMapView.h"
#import "BCSite.h"
#import "BCBeacon.h"
#import "BCImageMapAnnotationView.h"
#import "BCCalloutMapAnnotationView.h"
#import "BCCalloutMapAnnotation.h"
#import "BCCalloutCell.h"
#import "BCMicroLocation.h"

@interface LBSiteMapViewController () <BCMapViewDelegate, BCMicroLocationManagerDelegate>

@property (nonatomic, strong) BCMapView *mapView;
@property (nonatomic, strong) BCMicroLocationManager *microLocationManager;
@property (nonatomic, strong) UIImage *beaconImage;
@property (nonatomic, strong) BCCalloutMapAnnotation *calloutAnnotationForParentAnnotationView;
@property (nonatomic, strong) BCMapAnnotationView *parentAnnotationView;

@end

@implementation LBSiteMapViewController

- (BCMapView *)mapView
{
    if (!_mapView) {
        
        _mapView = [[BCMapView alloc] initWithFrame:self.view.frame];
        _mapView.delegate = self;
    }
    return _mapView;
}

- (BCMicroLocationManager *)microLocationManager
{
    if (!_microLocationManager) {
        _microLocationManager = [[BCMicroLocationManager alloc] init];
    }
    return _microLocationManager;
}

- (UIImage *)beaconImage
{
    if (!_beaconImage) {
        _beaconImage = [UIImage imageNamed:@"beacon-icon-black"];
    }
    return _beaconImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.mapView.site = self.site;
    [self.view addSubview:self.mapView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.microLocationManager.delegate = self;
    [self.microLocationManager startRangingBeaconsInSite:self.site];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.microLocationManager stopMonitoringAllSites];
    self.microLocationManager.delegate = nil;
    _microLocationManager = nil;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        UIEdgeInsets currentInsets = self.mapView.contentInsets;
        self.mapView.contentInsets = (UIEdgeInsets){
            .top = self.topLayoutGuide.length,
            .bottom = currentInsets.bottom,
            .left = currentInsets.left,
            .right = currentInsets.right
        };
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BCBeacon *)findBeaconWithCompositeKey:(NSString *)compositeKey inBeacons:(NSArray *)beacons
{
    if (!beacons || beacons.count <= 0 || compositeKey.length <= 0) return nil;
    
    for (BCBeacon *beacon in beacons) {
        
        if ([beacon.compositeKey isEqualToString:compositeKey]) {
            return beacon;
        }
    }
    return nil;
}

- (id <BCMapAnnotation>)annotationForCompositeKey:(NSString *)compositeKey
{
    for (id <BCMapAnnotation> annotation in self.mapView.annotations) {
        
        if ([annotation.identifier isEqualToString:compositeKey]) {
            return annotation;
        }
    }
    return nil;
}

- (void)addAnnotationsForBeacons:(NSArray *)beacons
{
    if (!beacons || beacons.count <= 0) return;
    
    NSString *compositeKey;
    for (BCBeacon *beacon in beacons) {
        
        if (beacon.mapPoint) {
            
            compositeKey = beacon.compositeKey;
            
            id <BCMapAnnotation> annotation = [self annotationForCompositeKey:compositeKey];
            if (!annotation) {
                
                BCCalloutMapAnnotation *calloutMapAnnotation = [BCCalloutMapAnnotation annotationWithMapPoint:beacon.mapPoint title:compositeKey];
                calloutMapAnnotation.identifier = compositeKey;
                [self.mapView addAnnotation:calloutMapAnnotation];
            }
        }
    }
}

- (void)updateAnnotationViewsWithBeacons:(NSArray *)beacons
{
    for (id <BCMapAnnotation> annotation in self.mapView.annotations) {
        
        BCMapAnnotationView *annotationView = [self.mapView viewForAnnotation:annotation];
        if (annotationView) {
            
            BCBeacon *beacon = [self findBeaconWithCompositeKey:annotation.identifier inBeacons:beacons];
            if (beacon) {
                annotationView.alpha = [self alphaForProximity:beacon.proximity];
            }
            else {
                annotationView.alpha = 0.0f;
            }

        }
    }
}

- (CGFloat)alphaForProximity:(BCProximity)proximity
{
    CGFloat alpha = 1.0f;
    switch (proximity) {
        
        case BCProximityImmediate:
            alpha = 1.0f;
            break;
        case BCProximityNear:
            alpha = 0.85f;
            break;
        case BCProximityFar:
            alpha = 0.70f;
            break;
        case BCProximityUnknown:
        default:
            alpha = 0.55f;
            break;
    }
    return alpha;
}


#pragma mark - BCMicroLocationManagerDelegate methods

- (void)microLocationManager:(BCMicroLocationManager *)microLocationManger didRangeBeacons:(NSArray *)beacons inSite:(BCSite *)site
{
    [self addAnnotationsForBeacons:beacons];
    
    [self updateAnnotationViewsWithBeacons:beacons];
}

#pragma mark - BCMapViewDelegate methods

- (BCMapAnnotationView *)mapView:(BCMapView *)mapView viewForAnnotation:(id<BCMapAnnotation>)annotation
{
    if (![annotation conformsToProtocol:@protocol(BCMapAnnotation)]) return nil;

//    if (annotation == self.calloutAnnotationForParentAnnotationView) {
//        
//        BCCalloutMapAnnotationView *annotationView = [BCCalloutMapAnnotationView annotationViewWithAnnotation:annotation parentAnnotationView:self.parentAnnotationView onCalloutCellAccessoryTapped:^(BCCalloutCell *cell, UIControl *control, NSDictionary *userData) {
//
//        }];
//        return annotationView;
//    }
//    else {
        BCImageMapAnnotationView *annotationView = [BCImageMapAnnotationView annotationViewWithAnnotation:annotation];
        annotationView.image = self.beaconImage;
        return annotationView;
//    }
}

- (void)mapView:(BCMapView *)mapView didSelectAnnotationView:(BCMapAnnotationView *)annotationView
{
//    if (![annotationView.annotation conformsToProtocol:@protocol(BCMapAnnotation)]) return;
//    
//    if ([annotationView isKindOfClass:[BCCalloutMapAnnotationView class]]) return;
//    
//    if (!self.calloutAnnotationForParentAnnotationView) {
//        
//        BCCalloutMapAnnotation *calloutMapAnnotation = [[BCCalloutMapAnnotation alloc] init];
//        [calloutMapAnnotation copyPropertiesFromAnnotation:annotationView.annotation];
//        
//        self.calloutAnnotationForParentAnnotationView = calloutMapAnnotation;
//
//        [mapView addAnnotation:calloutMapAnnotation];
//    }
//    
//    self.parentAnnotationView = annotationView;
}

- (void)mapView:(BCMapView *)mapView didDeselectAnnotationView:(BCMapAnnotationView *)annotationView
{
//    if (![annotationView.annotation conformsToProtocol:@protocol(BCMapAnnotation)]) return;
//    
//    if ([annotationView isKindOfClass:[BCCalloutMapAnnotationView class]]) return;
//    
//    if (self.calloutAnnotationForParentAnnotationView && !annotationView.preventSelectionChange) {
//        
//        [mapView removeAnnotation:self.calloutAnnotationForParentAnnotationView];
//        self.calloutAnnotationForParentAnnotationView = nil;
//    }
}

@end
