//
//  UCMenuViewController.m
//  ExampleProject
//
//  Created by Yury Nechaev on 22.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCMenuViewController.h"
#import "UCWidgetVC.h"
#import "UCSocialManager.h"

@interface UCMenuViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *socialButton;
@property (nonatomic, strong) IBOutlet UIButton *localFileButton;
@property (nonatomic, strong) UCWidgetVC *widget;
@property (nonatomic, copy) UCWidgetCompletionBlock completionBlock;
@property (nonatomic, copy) UCProgressBlock progressBlock;

@end

@implementation UCMenuViewController

- (id)initWithProgress:(UCProgressBlock)progress completion:(UCWidgetCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.completionBlock = completion;
        self.progressBlock = progress;
    }
    return self;
}

- (void)presentFrom:(UIViewController *)controller {
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:self];
    navc.modalPresentationStyle = UIModalPresentationFormSheet;
    [controller presentViewController:navc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Uploadcare";
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didPressClose:)]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:20]];
}

- (void)didPressClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.socialButton.layer.cornerRadius = self.socialButton.frame.size.height / 2;
    self.socialButton.layer.borderWidth = 1.0;
    self.socialButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    
    self.localFileButton.layer.cornerRadius = self.localFileButton.frame.size.height / 2;
}

#pragma mark - Actions

- (IBAction)didPressLocalFile:(id)sender {
    UIDocumentMenuViewController *menu = [SharedSocialManager documentControllerFrom:self progress:self.progressBlock completion:self.completionBlock];
    menu.popoverPresentationController.sourceView = sender;
    menu.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    [self presentViewController:menu animated:YES completion:nil];
}

- (IBAction)didPressSocial:(id)sender {
    self.widget = [[UCWidgetVC alloc] initWithProgress:self.progressBlock completion:self.completionBlock];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:self.widget];
    navc.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navc animated:YES completion:nil];
}

- (IBAction)didPressUploadcare:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://uploadcare.com/"]];
}

@end
