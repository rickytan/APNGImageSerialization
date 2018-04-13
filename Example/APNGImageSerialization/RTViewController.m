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
@property (weak, nonatomic) IBOutlet UIImageView *sampleImage;

@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.imageView.image = [UIImage animatedImageNamed:@"clock"];
    self.sampleImage.image = [UIImage animatedImageNamed:@"o_sample"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{        
        NSData *data = [APNGImageSerialization dataWithImages:self.imageView.image.images
                                                     duration:5
                                                        error:NULL];
        UIImage *image = UIAnimatedImageWithAPNGData(data);
        self.imageView.image = image;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSData *data = UIImageAPNGRepresentation([UIImage animatedImageNamed:@"clock"], 0.);
            UIImage *image = UIAnimatedImageWithAPNGData(data);
            self.imageView.image = image;
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
