//
//  DisclosureViewController.m
//  SimpleExample
//
//  Created by Artyom Loenko on 8/2/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "DisclosureViewController.h"

#import "UploadcareKit.h"
#import "UploadcareKit+Deprecated.h"

@interface DisclosureViewController () {
    IBOutlet UITextView *fileDescriptionView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    UploadcareFile *uploadcareFile;
}

@end

@implementation DisclosureViewController

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
    
    [activityIndicator startAnimating];
    
    [[UploadcareKit shared] requestFile:self.file_id withSuccess:^(NSHTTPURLResponse *response, id JSON, UploadcareFile *file) {
        uploadcareFile = file;
        [fileDescriptionView setText:[[uploadcareFile info] description]];
        [activityIndicator stopAnimating];
    } andFailure:^(id responseObject, NSError *error) {
        [fileDescriptionView setText:[NSString stringWithFormat:@"%@\n%@", responseObject, error]];
        [activityIndicator stopAnimating];
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)dismiss:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)keep:(id)sender {
    [activityIndicator startAnimating];
    
    [[UploadcareKit shared] keep:YES forFile:uploadcareFile
                         success:^(NSHTTPURLResponse *response, id JSON, UploadcareFile *file) {
                             [fileDescriptionView setText:[[uploadcareFile info] description]];
                             [activityIndicator stopAnimating];
                         }
                      andFailure:^(NSHTTPURLResponse *response, NSError *error) {
                          [fileDescriptionView setText:[NSString stringWithFormat:@"%@ \n %@", response, error]];
                          [activityIndicator stopAnimating];
                      }];
    
}

- (IBAction)delete:(id)sender {
    [activityIndicator startAnimating];
    
    [[UploadcareKit shared] deleteFile:uploadcareFile
                               success:^(NSHTTPURLResponse *response) {
                                   [self removeFromStorage:[uploadcareFile file_id]];
                                   [activityIndicator stopAnimating];
                                   [self dismiss:nil];
                               } andFailure:^(NSHTTPURLResponse *response, NSError *error) {
                                   [fileDescriptionView setText:[NSString stringWithFormat:@"%@ \n %@", response, error]];
                                   [activityIndicator stopAnimating];
                               }];
}

- (void)removeFromStorage:(NSString *)file_id {
    NSMutableArray *storage = [[NSMutableArray alloc] initWithArray:
                               [[NSUserDefaults standardUserDefaults] arrayForKey:@"uploadcare_storage"]];
    [storage removeObject:file_id];
    [[NSUserDefaults standardUserDefaults] setObject:storage forKey:@"uploadcare_storage"];    
}

@end
