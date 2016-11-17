//
//  RTViewController.m
//  APNGImageSerialization
//
//  Created by Ricky Tan on 11/17/2016.
//  Copyright (c) 2016 Ricky Tan. All rights reserved.
//

#import <APNGImageSerialization/APNGImageSerialization.h>

#import "RTViewController.h"

@interface RTViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"clock" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.imageView.image = UIAnimatedImageWithAPNGData(data, 1.4);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
