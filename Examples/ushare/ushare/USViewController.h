//
//  USViewController.h
//  ushare
//
//  Created by Zoreslav Khimich on 12/9/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <uploadcare-ios/UPCUploadController.h>

@interface USViewController : UIViewController<UPCUploadDelegate>

- (IBAction)share:(id)sender;
- (IBAction)upload:(id)sender;

@property (nonatomic, strong) NSURL *publicURL;
@property (nonatomic, strong) UPCUploadController *uploadWidget;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UIView *uploadingAnchor;
@property (nonatomic, weak) IBOutlet UIView *restingAnchor;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIProgressView *progressBar;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UILabel *uploadButtonHint;
@property (nonatomic, weak) IBOutlet UILabel *uploadButtonHintArrow;

@end
