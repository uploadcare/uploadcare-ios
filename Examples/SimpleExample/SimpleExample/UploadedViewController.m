//
//  UploadedViewController.m
//  SimpleExample
//
//  Created by Artyom Loenko on 8/2/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadedViewController.h"

#import "UploadcareKit.h"
#import "UploadcareKit+Deprecated.h"
#import "DisclosureViewController.h"

@interface UploadedViewController () {
    IBOutlet UITableView *tableview;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    NSArray *datasource;
}

@end

@implementation UploadedViewController

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.showLocal) {
        datasource = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"uploadcare_storage"]];
        [tableview reloadData];
        [activityIndicator stopAnimating];
    } else {
        [activityIndicator startAnimating];
        [[UploadcareKit shared] requestFileListWithSuccess:^(NSHTTPURLResponse *response, id JSON, NSArray *files) {
            datasource = [[NSArray alloc] initWithArray:files];
            [tableview reloadData];
            [activityIndicator stopAnimating];
        } andFailure:^(id responseObject, NSError *error) {
            [activityIndicator stopAnimating];
        }];
    }
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dismiss:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myIdentifier = @"FileTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:12.f];
    }
    
    if (self.showLocal) {
        cell.textLabel.text = [datasource objectAtIndex:[indexPath row]];
    } else {
        UploadcareFile *file = [datasource objectAtIndex:[indexPath row]];
        cell.textLabel.text = [file file_id];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DisclosureViewController *disclosureViewController = [[DisclosureViewController alloc] init];
    if (self.showLocal) {
        [disclosureViewController setFile_id:[datasource objectAtIndex:[indexPath row]]];
    } else {
        UploadcareFile *file = [datasource objectAtIndex:[indexPath row]];
        [disclosureViewController setFile_id:[file file_id]];
    }
    [self presentModalViewController:disclosureViewController animated:YES];
}

@end
