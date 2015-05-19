//
//  placePickerViewController.h
//  UIPlacePicker
//
//  Created by Albert Montserrat on 07/11/11.
//  Copyright (c) 2011 Albert Montserrat. All rights reserved.
//

#import "UIPlacePicker.h"


@implementation UIPlace

@end


@interface UIPlacePickerAnnotation (){
    CLLocationCoordinate2D coordinate;
}
@end

@implementation UIPlacePickerAnnotation
@synthesize coordinate;

-(NSString *)subtitle{
    return self.mySubtitle;
}

-(NSString *)title{
    return self.myTitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)c{
    coordinate=c;
    return self;
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    coordinate = newCoordinate;
}

-(void)setTitle:(NSString *)title{
    self.myTitle=title;
}

-(void)setSubtitle:(NSString *)subtitle{
    self.mySubtitle=subtitle;
}

@end

@interface UIPlacePicker () <UITextFieldDelegate, MKMapViewDelegate, UIAlertViewDelegate>{
    
    BOOL onlyVisitor;
    BOOL firstLoad;
    BOOL firstTime;
    UIAlertView *nameAlertView;
    UIPlacePickerAnnotation *annotation;
    
}

@end

@implementation UIPlacePicker

-(void)acceptLocation{
    UIPlace *place = [[UIPlace alloc] init];
    [place setPlaceName:[fieldName text]];
    [place setLocation:self.myLocation];
    [place setCompleteAddress:textField.text];
    [self.delegate placePickerDidSelectPlace:place];
}
-(IBAction)cancel:(id)sender{
    [self.delegate placePickerDidCancel];
}

-(IBAction)showPlaceNameAlert:(id)sender{
    viewFieldName.hidden = NO;
    [((UIView *)self.view.subviews[0]) bringSubviewToFront:viewFieldName];
}

-(IBAction)acceptName:(id)sender{
    
    [self closePlaceNameAlert:nil];
    
    if([fieldName.text compare:@""]!=NSOrderedSame){
        [self acceptLocation];
    }
    
}

-(IBAction)closePlaceNameAlert:(id)sender{
    [fieldName resignFirstResponder];
    viewFieldName.hidden = YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView==nameAlertView && [fieldName.text compare:@""]!=NSOrderedSame){
        [self acceptLocation];
    }
}

-(void)updatePin{
    
    if(!annotation){
        for(UIPlacePickerAnnotation *annotationToDelete in [map annotations]){
            [map removeAnnotation:annotationToDelete];
        }
        annotation = [[UIPlacePickerAnnotation alloc] init];
        [annotation setTitle:@"Place"];
        
        [map addAnnotation:annotation];
    }
    
    CLLocationCoordinate2D location2;
    location2.latitude=self.myLocation.coordinate.latitude;
    location2.longitude=self.myLocation.coordinate.longitude;
    annotation.coordinate = location2;
    
}

-(void)updateMap{
    MKCoordinateRegion region;
    region.center=self.myLocation.coordinate;
    MKCoordinateSpan span;
    if(firstTime){
        span.latitudeDelta=156.234365f;
        span.longitudeDelta=225.000000f;
        firstTime =NO;
    }else{
        span.latitudeDelta=0.01f;
        span.longitudeDelta=0.01f;
    }
    region.span = span;
    
    [map setRegion:region animated:NO];
    [map regionThatFits:region];
    
    [self updatePin];
}

-(void)updateMapWithPlace{
    MKCoordinateRegion region;
    region.center=self.myLocation.coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta=0.01f;
    span.longitudeDelta=0.01f;
    region.span = span;
    
    [map setRegion:region animated:NO];
    [map regionThatFits:region];
    
    [self updatePin];
}

-(void)getAddressWithCurrentLocation{
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?address=%.7f,%.7f&sensor=false",self.myLocation.coordinate.latitude,self.myLocation.coordinate.longitude];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(connectionError || !data){
            textField.text = @"";
            return;
        }
        
        NSError *error;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if(error || !responseDict || [responseDict allKeys].count == 0){
            textField.text = @"";
            return;
        }
        
        NSLog(@"");
        
        NSArray *results = [responseDict objectForKey:@"results"];
        if(!results || results.count == 0){
            textField.text = @"";
            return;
        }
        
        NSDictionary *result1 = [results objectAtIndex:0];
        if(!result1){
            textField.text = @"";
            return;
        }
        
        NSString *formatted_address = [result1 objectForKey:@"formatted_address"];
        if(!formatted_address){
            textField.text = @"";
            return;
        }
        
        textField.text = formatted_address;
        
    }];

}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if(!firstLoad){
        firstLoad = YES;
        [self getAddressWithCurrentLocation];
    }
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) ann{
    if(ann == annotation){
        MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
        annView.pinColor = MKPinAnnotationColorRed;
        annView.canShowCallout = NO;
        if(!onlyVisitor)
            annView.draggable = YES;
        return annView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        self.myLocation = [[CLLocation alloc]initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
        [self updatePin];
        [self getAddressWithCurrentLocation];
    }
}

-(void)getLocationWithAddress{
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?address=%@&sensor=false",textField.text];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(connectionError || !data){
            textField.text = @"";
            return;
        }
        
        NSError *error;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if(error || !responseDict || [responseDict allKeys].count == 0){
            [self updateMap];
            return;
        }
        
        NSLog(@"");
        
        NSArray *results = [responseDict objectForKey:@"results"];
        if(!results || results.count == 0){
            [self updateMap];
            return;
        }
        
        NSDictionary *result1 = [results objectAtIndex:0];
        if(!result1){
            [self updateMap];
            return;
        }
        
        NSDictionary *geometry = [result1 objectForKey:@"geometry"];
        if(!geometry){
            [self updateMap];
            return;
        }
        
        NSDictionary *location = [geometry objectForKey:@"location"];
        if(!location){
            [self updateMap];
            return;
        }
        
        NSDecimalNumber *lat = [location objectForKey:@"lat"];
        NSDecimalNumber *lng = [location objectForKey:@"lng"];
        
        if(lng && lng){
            self.myLocation = [[CLLocation alloc] initWithLatitude:[lat floatValue]
                                                         longitude:[lng floatValue]];
            
        }
        [self updateMap];
        
    }];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)_textField{
    if(_textField == fieldName){
        [fieldName resignFirstResponder];
    }else{
        [self getLocationWithAddress];
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [self observeKeyboard];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self forgetKeyboard];
}

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)forgetKeyboard {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    CGRect f = ((UIView *)self.view.subviews[0]).frame;
    f.size.height = self.view.frame.size.height - keyboardBounds.size.height;
    ((UIView *)self.view.subviews[0]).frame = f;
    
    [UIView commitAnimations];
    
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    CGRect f = ((UIView *)self.view.subviews[0]).frame;
    f.size.height = self.view.frame.size.height;
    ((UIView *)self.view.subviews[0]).frame = f;
    
    [UIView commitAnimations];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        onlyVisitor = NO;
    }
    return self;
}

- (id)initWithUIPlace:(UIPlace*)place
{
    self = [super initWithNibName:@"UIPlacePicker" bundle:[NSBundle mainBundle]];
    if (self) {
        self.place = place;
        onlyVisitor = NO;
    }
    return self;
}

- (id)initWithUIPlaceOnlyVisitor:(UIPlace*)place
{
    self = [super initWithNibName:@"UIPlacePicker" bundle:[NSBundle mainBundle]];
    if (self) {
        self.place = place;
        onlyVisitor = YES;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    buttonOk.title = NSLocalizedString(@"Ok",@"");
    buttonCancel.title = NSLocalizedString(@"Cancel",@"");
    labelfieldName.text = NSLocalizedString(@"Write the location name",@"");
    [buttonfieldName setTitle:NSLocalizedString(@"Ok",@"") forState:UIControlStateNormal];
    
    ((UIView *)viewFieldName.subviews[0]).layer.cornerRadius = 10;
    
    firstTime=YES;
    if(self.place==nil){
        [labelTitle setText:@""];
        self.myLocation = [[CLLocation alloc]initWithLatitude:map.region.center.latitude longitude:map.region.center.longitude];
        [self updateMap];
    }else{
        [labelTitle setText:self.place.placeName];
        self.myLocation = [self.place location]; 
        [self updateMapWithPlace];
    }
    if(onlyVisitor){
        [labelTitle setText:self.place.placeName];
        NSMutableArray *items = [toolBarSuperior.items mutableCopy];
        [items removeObject:buttonOk];
        [toolBarSuperior setItems:items];
        //[self.buttonOk setEnabled:NO];
        [textField setUserInteractionEnabled:NO];
        firstLoad = NO;
    }
    
}

@end
