//
//  placePickerViewController.h
//  UIPlacePicker
//
//  Created by Albert Montserrat on 07/11/11.
//  Copyright (c) 2011 Albert Montserrat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>



@interface UIPlace : NSObject
@property(nonatomic,retain) NSString *placeName;
@property(nonatomic,retain) CLLocation *location;
@property(nonatomic,retain) NSString *completeAddress;
@end






@interface UIPlacePickerAnnotation : NSObject<MKAnnotation>

@property (nonatomic,retain) NSString *myTitle;
@property (nonatomic,retain) NSString *mySubtitle;
@property (nonatomic,retain) UIPlace *place;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c;

-(void)setTitle:(NSString *)title;
-(void)setSubtitle:(NSString *)subtitle;

@end






@protocol UIPlacePickerDelegate;


@interface UIPlacePicker : UIViewController{
    IBOutlet MKMapView *map;
    IBOutlet UITextField *textField;
    IBOutlet UIToolbar *toolBarSearch;
    IBOutlet UILabel *labelTitle;
    IBOutlet UIToolbar *toolBarSuperior;
    IBOutlet UIView *viewFieldName;
    IBOutlet UILabel *labelfieldName;
    IBOutlet UITextField *fieldName;
    IBOutlet UIButton *buttonfieldName;
    IBOutlet UIBarButtonItem *buttonOk;
    IBOutlet UIBarButtonItem *buttonCancel;
}

@property(nonatomic,retain) CLLocation *myLocation;
@property (nonatomic, assign) id <UIPlacePickerDelegate> delegate;
@property(nonatomic,retain) UIPlace *place;

-(void)acceptLocation;
-(IBAction)showPlaceNameAlert:(id)sender;
-(IBAction)cancel:(id)sender;
- (id)initWithUIPlace:(UIPlace*)place;
- (id)initWithUIPlaceOnlyVisitor:(UIPlace*)place;

@end

@protocol UIPlacePickerDelegate
- (void)placePickerDidSelectPlace:(UIPlace *)place;
- (void)placePickerDidCancel;
@end

