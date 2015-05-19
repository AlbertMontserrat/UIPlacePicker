//
//  ViewController.m
//  UIPlacePickerDemo
//
//  Created by Albert Montserrat on 5/5/15.
//  Copyright (c) 2015 Albert Montserrat. All rights reserved.
//

#import "ViewController.h"
#import "UIPlacePicker.h"

@interface ViewController ()<UIPlacePickerDelegate>{
    UIPlacePicker *picker;
    UIPlace *place;
    
}

@end

@implementation ViewController

-(IBAction)pickPlace:(id)sender{
    picker = [[UIPlacePicker alloc] initWithUIPlace:nil];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

-(IBAction)showPlace:(id)sender{
    if(!place)
        return;
    
    picker = [[UIPlacePicker alloc] initWithUIPlace:place];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

-(IBAction)showPlaceVisitor:(id)sender{
    if(!place)
        return;
    
    picker = [[UIPlacePicker alloc] initWithUIPlaceOnlyVisitor:place];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

-(void)placePickerDidSelectPlace:(UIPlace *)__place{
    place = __place;
    self.buttonView.enabled = YES;
    self.buttonViewVisitor.enabled = YES;
    [self hidePlacePicker];
}

-(void)placePickerDidCancel{
    [self hidePlacePicker];
}

-(void)hidePlacePicker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.buttonNew.enabled = YES;
    self.buttonView.enabled = NO;
    self.buttonViewVisitor.enabled = NO;
    
}

@end
