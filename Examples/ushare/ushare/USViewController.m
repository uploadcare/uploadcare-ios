//
//  USViewController.m
//  ushare
//
//  Created by Zoreslav Khimich on 12/9/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "USViewController.h"

#import "UploadcareWidget.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"

#import <QuartzCore/QuartzCore.h>

@interface USViewController ()

@property BOOL justStarted;

@end

@implementation USViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setJustStarted:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.justStarted) {
        self.justStarted = NO;
        [self doTheBussiness];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ushareTapped:(id)sender {
    [self doTheBussiness];
}

+ (AFHTTPClient *)sharedHTTPClient {
    static AFHTTPClient *_sharedUploadClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUploadClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://ushare.whitescape.com"]];
    });
    return _sharedUploadClient;
}


- (void)onUploadedFileWithId:(NSString *)fileId {
    /* Request our back-end to store the file and return the public URL */
    NSURLRequest *request = [[USViewController sharedHTTPClient] requestWithMethod:@"POST" path:@"http://ushare.whitescape.com/files/upload/" parameters:@{@"file_obj" : fileId}];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self onUploadCompleteWithPublicAddress:JSON[@"url"]];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self onFailedToUploadBecauseOfError:error];
    }];
    [op start];
}


- (void)blockUserInteraction:(BOOL)block {
    if (block) {
        self.view.layer.opacity = 0.3f;
        self.view.userInteractionEnabled = NO;
    } else {
        self.view.layer.opacity = 1.0f;
        self.view.userInteractionEnabled = YES;
    }
}

- (void)uploadcareWidgetDidCancel:(UCWidget *)widget {
    self.promptLabel.text = NSLocalizedString(@"uShare lets you upload files for free. Please keep the file sizes reasonable.", @"Uploadcare menu has been dismissed");
    [self blockUserInteraction:NO];
}

- (void)doTheBussiness {
    /* Setup the view controller */
    UCWidget *uploadcare = [[UCWidget alloc]initWithUploadcarePublicKey:@"demopublickey"];
    uploadcare.delegate = self;
    [uploadcare setUploadCompletionBlock:^(NSString *fileId) {
        [self blockUserInteraction:NO];
        [self onUploadedFileWithId:fileId];
    }];
    
    /* Social stuff */
    [uploadcare enableFacebook];
    [uploadcare enableFlickrWithAPIKey:@"2522a6f8bbff8fbb1826d335cad7d9b1" flickrAPISecret:@"4ab550f59749ca42"];
    [uploadcare enableInstagramWithClientId:@"e2a6987a814d4f5d96b24b6971f9eb89"];
    
    /* Handlers */
    [uploadcare setUploadFailureBlock:^(NSError *error) {
        [self blockUserInteraction:NO];
        [self onFailedToUploadBecauseOfError:error];
    }];
    [self presentViewController:uploadcare animated:YES completion:^{
        self.promptLabel.text = NSLocalizedString(@"Just a moment please...", @"Uploading in progress text");
        [self blockUserInteraction:YES];
    }];
}

- (void)onUploadCompleteWithPublicAddress:(NSString *)publicAddress {
    [UIPasteboard generalPasteboard].string = publicAddress;
    self.promptLabel.text = NSLocalizedString(@"✅ Success! The public link has been copied to your pasteboard.", @"Upload success text");
}

- (void)onFailedToUploadBecauseOfError:(NSError *)error {
    self.promptLabel.text = NSLocalizedString(@"❌ Oops, something went wrong. Maybe try again?", @"Upload failure text");
}

- (void)viewDidUnload {
    [self setPromptLabel:nil];
    [super viewDidUnload];
}
@end
