//
//  ViewController.m
//  MobileMappers
//
//  Created by Michael Moss on 11/16/15.
//  Copyright © 2015 Mike. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
@interface ViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property MKPointAnnotation *mobileMakersAnnotation;
@property CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.mapView.showsUserLocation = YES;
    
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    double longitude = -122.402071;
    double latitude = 37.790752;
    self.mobileMakersAnnotation = [MKPointAnnotation new];
    self.mobileMakersAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    self.mobileMakersAnnotation.title = @"Mobile Makers";
    [self.mapView addAnnotation:self.mobileMakersAnnotation];
    [self findCoordinates:@"Golden Gate Bridge"];
    [self findCoordinates:@"Kenya"];
    [self findCoordinates:@"Paris"];
}

-(void) findCoordinates: (NSString *)item {
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder geocodeAddressString:item completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        for (CLPlacemark *place in placemarks) {
            MKPointAnnotation *annotation = [MKPointAnnotation new];
            annotation.coordinate = place.location.coordinate;
            annotation.title = place.name;
            [self.mapView addAnnotation:annotation];
        }
            [self updateRegionToPins];
    }];
}

-(void) updateRegionToPins{
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, .001, .001);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [self.mapView setRegion:MKCoordinateRegionForMapRect(zoomRect)];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    CLLocationCoordinate2D centerCoordinate = view.annotation.coordinate;
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = 0.01;
    coordinateSpan.longitudeDelta = 0.01;
    MKCoordinateRegion region;
    region.center = centerCoordinate;
    region.span = coordinateSpan;
    [self.mapView setRegion:region];
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isEqual:self.mapView.userLocation]) {
        return nil;
    }
    MKAnnotationView *pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    if([annotation isEqual:self.mobileMakersAnnotation]){
        pin.image = [UIImage imageNamed:@"mobilemakers"];
    }else{
        pin.image = [UIImage imageNamed:@"redAnnotation"];
    }
    
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return pin;
}
-(void)reverseGeoCodeLocation:(CLLocation *)location{
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        CLPlacemark *placeMark = placemarks.firstObject;
        NSString *address = [NSString stringWithFormat:@"%@ %@\n%@",placeMark.subThoroughfare, placeMark.thoroughfare,placeMark.locality];
        NSLog(@"%@", address);
    }];
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = locations.firstObject;
    if(location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000){
        [self reverseGeoCodeLocation:location];
    }
    [self.locationManager stopUpdatingLocation];
}

@end
