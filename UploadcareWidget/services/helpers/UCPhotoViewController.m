//
//  UCPhotoViewController.m
//  WidgetExample
//
//  Created by Artyom Loenko on 9/10/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCPhotoViewController.h"

@interface UCPhotoViewController () {
    IBOutlet UIImageView *imageView;
}

@end

@implementation UCPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [imageView setImage:self.image];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
