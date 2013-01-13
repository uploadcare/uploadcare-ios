//
//  USViewController.m
//  ushare
//
//  Created by Zoreslav Khimich on 12/9/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "USViewController.h"
#import "UIView+USHelpers.h"
#import "UploadcareWidget.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "ARChromeActivity.h"
#import "TUSafariActivity.h"

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
    self.uploadWidget = [[UPCUploadController alloc]initWithUploadcarePublicKey:@"demopublickey"];
    self.uploadWidget.delegate = self;
    __weak USViewController *viewController = self;
    self.uploadWidget.navigationBar.barStyle = UIBarStyleBlack;
    
    /* Social stuff */
    [self.uploadWidget enableFacebook];
    [self.uploadWidget enableFlickrWithAPIKey:@"2522a6f8bbff8fbb1826d335cad7d9b1" flickrAPISecret:@"4ab550f59749ca42"];
    [self.uploadWidget enableInstagramWithClientId:@"e2a6987a814d4f5d96b24b6971f9eb89"];
    
    /* Handlers */
    self.uploadWidget.uploadCompletionBlock = ^(NSString *fileId) {
        [viewController didUploadFileWithId:fileId];
    };
    self.uploadWidget.uploadProgressBlock = ^(long long bytesDone, long long bytesTotal) {
        float progress = (float)bytesDone / bytesTotal;
        [self.progressBar setProgress:progress animated:YES];
        self.progressLabel.text = [NSString stringWithFormat:@"%@ %.0f%%", self.fileName, progress * 100.f];
    };
    self.uploadWidget.uploadFailureBlock = ^(NSError *error) {
        [viewController didFailToUploadBecauseOfError:error];
    };
}

- (void)viewDidAppear:(BOOL)animated {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.uploadButtonHint moveInFrom:kCATransitionFromBottom];
        [self.uploadButtonHintArrow moveInFrom:kCATransitionFromBottom];
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

/**
 * Dismiss the view controller that was presented using presentUploadViewController */
- (void)dismissUploadViewController:(BOOL)animated completion:(void(^)(void))completionBlock {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:completionBlock];
    }else{
        [self.popover dismissPopoverAnimated:YES];
        completionBlock();
    }
}

/**
 * User selected a file to upload, dismiss the view controller and animate in the progress bar */
- (void)uploadcareWidget:(UPCUploadController*)widget didStartUploadingFileNamed:(NSString*)fileName fromURL:(NSURL*)url withThumbnail:(UIImage*)thumbnail {
    [self dismissUploadViewController:YES completion:^{
        self.fileName = fileName;
        self.promptLabel.text = nil;
        [self addShadowAroundTheThumbnail];
        [UIView animateWithDuration:0.25f animations:^{
            self.thumbnailImageView.image = thumbnail;
            self.thumbnailImageView.frame = self.uploadingAnchor.frame;
        }];
        [self.progressBar setProgress:0 animated:NO];
        self.progressLabel.text = fileName;
        [self.progressBar moveInFrom:kCATransitionFromRight];
        [self.progressLabel moveInFrom:kCATransitionFromRight];
        [self.shareButton moveOutFrom:kCATransitionFromBottom];
        [self.toolbar moveOutFrom:kCATransitionFromBottom];
    }];
}

/**
 * Upload complete, request a public file URL from the service */
- (void)didUploadFileWithId:(NSString*)fileId {
    self.promptLabel.text = NSLocalizedString(@"Almost there...", @"post-uploading pre-store text");
    /* Request our back-end to store the file and return the public URL */
    NSURLRequest *request = [[USViewController sharedHTTPClient] requestWithMethod:@"POST" path:@"http://ushare.whitescape.com/files/upload/" parameters:@{@"file_obj" : fileId}];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self didPublishFileAtAddress:JSON[@"url"]];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self didFailToUploadBecauseOfError:error];
    }];
    [op start];
}

/**
 * Sharing complete, show a congratulatory message and the share/open-in button */
- (void)didPublishFileAtAddress:(NSString*)publicAddress {
    [UIView animateWithDuration:0.25f animations:^{
        self.thumbnailImageView.frame = self.restingAnchor.frame;
        [self.progressBar moveOutFrom:kCATransitionFromLeft];
        [self.progressLabel moveOutFrom:kCATransitionFromLeft];
    }];
    self.publicURL = [NSURL URLWithString:publicAddress];
    self.promptLabel.text = NSLocalizedString(@"✅ The file has been successfully uploaded!", @"Upload success text");
    [self.shareButton moveInFrom:kCATransitionFromTop];
    [self.toolbar moveInFrom:kCATransitionFromTop];
}

- (void)didFailToUploadBecauseOfError:(NSError*)error {
    self.promptLabel.text = NSLocalizedString(@"❌ Oops, something went wrong. Try again?", @"Upload failure text");
    [self.uploadWidget dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utility

/**
 * AFHTTPClient shared instance */
+ (AFHTTPClient *)sharedHTTPClient {
    static AFHTTPClient *_sharedUploadClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUploadClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://ushare.whitescape.com"]];
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
