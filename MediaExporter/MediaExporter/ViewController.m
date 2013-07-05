//
//  ViewController.m
//  MediaExporter
//
//  Created by Jack Wu on 13-06-14.
//  Copyright (c) 2013 Jack Wu. All rights reserved.
//

#import "ViewController.h"
#import "MediaPickerController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)buttonPressed:(id)sender
{
    MediaPickerController* picker = [[MediaPickerController alloc] init];
    [picker start];
}

@end
