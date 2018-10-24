//
//  InterfaceController.m
//  APNGwatchOSDemo Extension
//
//  Created by Ricky on 2018/10/24.
//  Copyright © 2018年 Ricky Tan. All rights reserved.
//

#import <APNGImageSerialization/APNGImageSerialization.h>

#import "InterfaceController.h"


@interface InterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceImage *image;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    [self.image setImage:[UIImage animatedImageNamed:@"progress"]];
    [self.image startAnimating];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



