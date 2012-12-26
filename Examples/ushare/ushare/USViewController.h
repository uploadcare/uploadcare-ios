//
//  USViewController.h
//  ushare
//
//  Created by Zoreslav Khimich on 12/9/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UCWidget.h>

@interface USViewController : UIViewController<UCWidgetDelegate, UINavigationControllerDelegate>

- (IBAction)share:(id)sender;
- (IBAction)upload:(id)sender;

@property (nonatomic, strong) NSURL *publicURL;
@property (nonatomic, strong) NSString *fileName;
@property (strong, nonatomic) UCWidget *uploadWidget;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIView *uploadingAnchor;
@property (weak, nonatomic) IBOutlet UIView *restingAnchor;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadButtonHint;
@property (weak, nonatomic) IBOutlet UILabel *uploadButtonHintArrow;

@end
