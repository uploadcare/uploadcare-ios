//
//  ViewController.m
//  SimpleExample
//
//  Created by Artyom Loenko on 8/1/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "ViewController.h"

#import "UploadcareKit.h"
#import "UploadedViewController.h"

@interface ViewController () {
    IBOutlet UITextView *logView;
    IBOutlet UIProgressView *progressView;
    IBOutlet UILabel *percentLabel;
    IBOutlet UIBarButtonItem *uploadedButton;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    // init UploadcareKit with public and secret
    [[UploadcareKit shared] setPublicKey:@"fd939b2f0698f7e2ca4edd5064827c21a150c8534a2407d88f42bcff7d4f2c68"
                               andSecret:@"4b9f679057703b699cef2955a7a64a4fe21e03c1b9f221ff76ad262bc180ee1a"];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkStorageAndUpdateStatus];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions

- (IBAction)uploadFileFromPhotoLibrary:(id)sender {
    [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)uploadFromUrl:(id)sender {
    UIAlertView *uploadFromUrlDialog = [[UIAlertView alloc] initWithTitle:@"Please enter URL:" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Upload", nil];
    [uploadFromUrlDialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [uploadFromUrlDialog show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self uploadFromURL:[[alertView textFieldAtIndex:0] text]];
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        [self startMediaBrowserFromViewController:nil withSourceType:sourceType usingDelegate:self];
    }
}

- (BOOL) startMediaBrowserFromViewController:(UIViewController*) controller
                              withSourceType:(UIImagePickerControllerSourceType)sourceType
                               usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    DLog(@"delegate = %@, controller = %@", delegate ? @"FINE" : @"NIL", controller ? @"FINE" : @"NIL");
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil))
        return NO;

    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = sourceType;
    
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = delegate;
    
    [self presentModalViewController:mediaUI animated:YES];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    
    DLog(@"File Info = %@", info);
    
    [self uploadFromFile:UIImagePNGRepresentation([info valueForKey:UIImagePickerControllerOriginalImage])
                withName:[info valueForKey:@"UIImagePickerControllerOriginalImage"]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Uploadcare

- (void)uploadFromFile:(NSData *)data withName:(NSString *)name {
    [self performSelectorOnMainThread:@selector(appendTextToLog:)
                           withObject:[NSString stringWithFormat:@"start uploading...\n"]
                        waitUntilDone:YES];
    
    [[UploadcareKit shared] uploadFileWithName:name andData:data uploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        float progress = (totalBytesWritten / (totalBytesExpectedToWrite / 100.f)) / 100.f;
        [progressView setProgress:progress animated:YES];
        [percentLabel setText:[NSString stringWithFormat:@"%.2f%%", progress * 100.f]];
        
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UploadcareFile *file) {
        
        [self performSelectorOnMainThread:@selector(appendTextToLog:)
                               withObject:[NSString stringWithFormat:@"upload success! with id %@\n", [file file_id]]
                            waitUntilDone:NO];
        
        [progressView setProgress:.0f animated:YES];
        [percentLabel setText:@"0.0%"];
        
        [self addToStorage:[file file_id]];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
        [self performSelectorOnMainThread:@selector(appendTextToLog:)
                               withObject:[NSString stringWithFormat:@"upload failed! %@\n", error]
                            waitUntilDone:NO];
        
    }];
}

- (void)uploadFromURL:(NSString *)url {
    [[UploadcareKit shared] uploadFileWithURL:url success:^(NSURLRequest *request, NSHTTPURLResponse *response, UploadcareFile *file) {
        
        [self performSelectorOnMainThread:@selector(appendTextToLog:)
                               withObject:[NSString stringWithFormat:@"upload success! for %@\n", url]
                            waitUntilDone:NO];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
        [self performSelectorOnMainThread:@selector(appendTextToLog:)
                               withObject:[NSString stringWithFormat:@"upload failed! %@\n", error]
                            waitUntilDone:NO];
        
    }];
}

#pragma mark - Tools

- (void)appendTextToLog:(NSString *)text {
    [logView setText:[logView.text stringByAppendingString:text]];
}

#pragma mark - Uploaded Tools

- (IBAction)showOnlineFileList:(id)sender {
    UploadedViewController *uploadedViewController = [[UploadedViewController alloc] init];
    [uploadedViewController setShowLocal:NO];
    [self presentModalViewController:uploadedViewController animated:YES];
}

- (IBAction)showUploaded:(id)sender {
    UploadedViewController *uploadedViewController = [[UploadedViewController alloc] init];
    [uploadedViewController setShowLocal:YES];
    [self presentModalViewController:uploadedViewController animated:YES];
}

- (void)checkStorageAndUpdateStatus {
    NSArray *storage = [[NSUserDefaults standardUserDefaults] arrayForKey:@"uploadcare_storage"];
    if (!storage) {
        [uploadedButton setTitle:@"Local History"];
        [uploadedButton setEnabled:NO];
    } else {
        [uploadedButton setEnabled:YES];
        [uploadedButton setTitle:[NSString stringWithFormat:@"Local History: %d file[s]", [storage count]]];
    }
}

- (void)addToStorage:(NSString *)file_id {
    NSArray *storage = [[NSUserDefaults standardUserDefaults] arrayForKey:@"uploadcare_storage"];
    NSMutableArray *_storage = [[NSMutableArray alloc] initWithArray:storage];
    [_storage addObject:file_id];
    
    [[NSUserDefaults standardUserDefaults] setObject:_storage forKey:@"uploadcare_storage"];
    [self checkStorageAndUpdateStatus];
}

@end
