//
//  USViewController.m
//  ushare
//
//  Created by Zoreslav Khimich on 12/9/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "USViewController.h"
#import "UIView+USHelpers.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "ARChromeActivity.h"
#import "TUSafariActivity.h"

#import "UPCUpload.h"
#import <UPCUploadController.h>

#import <QuartzCore/QuartzCore.h>

@interface USViewController ()

@property BOOL justStarted;

@end

@implementation USViewController

#pragma mark - Button actions

- (IBAction)share:(id)sender {
    ARChromeActivity *openInChrome = [[ARChromeActivity alloc]init];
    TUSafariActivity *openInSafari = [[TUSafariActivity alloc]init];
    /* note: The URL *must* be the last object in the activity items array or else 'open in Chrome' activity won't work (...don't get me started) */
    UIActivityViewController *actions = [[UIActivityViewController alloc]initWithActivityItems:@[self.publicURL.absoluteString, self.publicURL] applicationActivities:@[openInSafari, openInChrome]];
    [self presentViewController:actions animated:YES completion:nil];
}

- (IBAction)upload:(id)sender {
    self.uploadButtonHint.hidden = YES;
    self.uploadButtonHintArrow.hidden = YES;
    [self presentUploadViewController];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setJustStarted:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
    /* thumbnail view */
    
    self.thumbnailImageView.layer.cornerRadius = 4.0f;
    self.thumbnailImageView.layer.masksToBounds = YES;
    
    /* share button */
    
    [self.shareButton setBackgroundImage:[[UIImage imageNamed:@"USSilverButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)] forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:[[UIImage imageNamed:@"USSilverButtonDepressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)] forState:UIControlStateHighlighted];
    
    /* Uploadcare widget initialization */
    
    self.uploadWidget = [[UPCUploadController alloc]initWithUploadcarePublicKey:@"ea0c5eaa31bbaf62ebad"];
    self.uploadWidget.maximumImageSize = CGSizeMake(1024, 1024);
    self.uploadWidget.uploadDelegate = self;
    self.uploadWidget.navigationBar.barStyle = UIBarStyleBlack;
    

}

- (void)viewDidAppear:(BOOL)animated {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.uploadButtonHint slideInUsing:kCATransitionFromBottom];
        [self.uploadButtonHintArrow slideInUsing:kCATransitionFromBottom];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - Uploading

/**
 * Show the Uploadcare menu in a modal view on iPhone or in a popover on iPad */
- (void)presentUploadViewController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.uploadWidget animated:YES completion:nil];
    }else{
        UIPopoverController *popover = [[UIPopoverController alloc]initWithContentViewController:self.uploadWidget];
        self.uploadWidget.popover = popover;
        self.popover = popover;
        [popover presentPopoverFromBarButtonItem:self.toolbar.items[1] permittedArrowDirections: UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)uploadDidStart:(UPCUpload *)upload {
    self.promptLabel.text = nil;
    [self addShadowAroundTheThumbnail];
    [UIView animateWithDuration:0.25f animations:^{
        self.thumbnailImageView.image = upload.thumbnail ? upload.thumbnail : [UIImage imageNamed:@"USCloud"];
        self.thumbnailImageView.frame = self.uploadingAnchor.frame;
    }];
    [self.progressBar setProgress:0 animated:NO];
    self.progressLabel.text = upload.filename;
    [self.progressBar slideInUsing:kCATransitionFromRight];
    [self.progressLabel slideInUsing:kCATransitionFromRight];
    [self.shareButton slideOutUsing:kCATransitionFromBottom];
    [self.toolbar slideOutUsing:kCATransitionFromBottom];
}

- (void)upload:(UPCUpload *)upload didTransferTotalBytes:(long long)totalBytesTransfered expectedTotalBytes:(long long)expectedTotalBytes {
    float progress = (float)totalBytesTransfered / expectedTotalBytes;
    [self.progressBar setProgress:progress animated:YES];
    [self.progressLabel setText:[NSString stringWithFormat:@"%@ %.0f%%", upload.filename, progress * 100.f]];
}

/**
 * Upload complete, request a public file URL from the service */
- (void)uploadDidFinish:(UPCUpload *)upload destinationFileId:(NSString *)fileId {
    self.promptLabel.text = NSLocalizedString(@"Almost there...", @"post-upload pre-store text");
    /* Request our back-end to store the file and return the public URL */
    NSURLRequest *request = [[USViewController sharedHTTPClient] requestWithMethod:@"POST" path:@"/files/upload/" parameters:@{@"file_obj" : fileId}];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self didPublishFileAtAddress:JSON[@"url"]];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"FAILURE! Request:\n\n%@", fileId);
        [self upload:upload didFailWithError:error];
    }];
    [op start];
}

/**
 * Sharing complete, show a congratulatory message and the share/open-in button */
- (void)didPublishFileAtAddress:(NSString*)publicAddress {
    [UIView animateWithDuration:0.25f animations:^{
        self.thumbnailImageView.frame = self.restingAnchor.frame;
        [self.progressBar slideOutUsing:kCATransitionFromLeft];
        [self.progressLabel slideOutUsing:kCATransitionFromLeft];
    }];
    self.publicURL = [NSURL URLWithString:publicAddress];
    self.promptLabel.text = NSLocalizedString(@"✅ Uploaded!", @"Upload success text");
    [self.shareButton slideInUsing:kCATransitionFromTop];
    [self.toolbar slideInUsing:kCATransitionFromTop];
}

- (void)upload:(UPCUpload *)upload didFailWithError:(NSError *)error {
    NSLog(@"Upload failed: %@", error);
    self.promptLabel.text = NSLocalizedString(@"❌ We are terribly sorry, but something went wrong. Please try again in a few moments.", @"Upload failure text");
    [UIView animateWithDuration:0.25f animations:^{
        self.thumbnailImageView.frame = self.restingAnchor.frame;
        [self.progressBar slideOutUsing:kCATransitionFromLeft];
        [self.progressLabel slideOutUsing:kCATransitionFromLeft];
    }];
    [self.toolbar slideInUsing:kCATransitionFromTop];
}

#pragma mark - Utility

/**
 * AFHTTPClient shared instance */
+ (AFHTTPClient *)sharedHTTPClient {
    static AFHTTPClient *_sharedUploadClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUploadClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://www.ushare.io"]];
    });
    return _sharedUploadClient;
}

- (void)addShadowAroundTheThumbnail {
    /* Do this once */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CALayer *shadowLayer = [CALayer layer];
        [shadowLayer addSublayer:self.thumbnailImageView.layer];
        shadowLayer.frame = self.view.bounds;
        shadowLayer.shadowOffset = CGSizeMake(0, 2);
        shadowLayer.shadowOpacity = .75f;
        shadowLayer.shadowRadius = 3.75f;
        [self.view.layer addSublayer:shadowLayer];
    });
}

@end
