//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadcareWidget.h"

#import "UploadcareKit.h"

#define SECTION_URL         0
#define SECTION_LOCAL       1
#define SECTION_SERVICES    2
#define SECTION_UPLOADS     3

@interface UploadcareWidget () {
    NSMutableDictionary *dataSource;
}

@end

@implementation UploadcareWidget

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dataSource = [[NSMutableDictionary alloc] init];
        [dataSource setObject:[[NSMutableArray alloc] init]
                       forKey:[NSNumber numberWithInt:SECTION_URL]];
        [dataSource setObject:[[NSMutableArray alloc] initWithObjects:
                               NSLocalizedString(@"Take Photo", nil),
                               NSLocalizedString(@"Take Video", nil),
                               NSLocalizedString(@"Choose from Library", nil),
                               nil]
                       forKey:[NSNumber numberWithInt:SECTION_LOCAL]];
        [dataSource setObject:[[NSMutableArray alloc] initWithObjects:
                               NSLocalizedString(@"Facebook", nil),
                               NSLocalizedString(@"Flickr", nil),
                               NSLocalizedString(@"Instagram", nil),
                               NSLocalizedString(@"Picasa", nil),
                               NSLocalizedString(@"Upload from URL", nil),
                               nil]
                       forKey:[NSNumber numberWithInt:SECTION_SERVICES]];
        [dataSource setObject:[[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"My uploads", nil), nil]
                       forKey:[NSNumber numberWithInt:SECTION_UPLOADS]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(dismiss:)];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
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

- (IBAction)dismiss:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dataSource objectForKey:[NSNumber numberWithInt:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        switch ([indexPath section]) {
            case SECTION_URL: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textAlignment = UITextAlignmentLeft;
                break;
            }
            case SECTION_LOCAL: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                break;
            }
            case SECTION_SERVICES: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.textAlignment = UITextAlignmentLeft;
                break;
            }
            case SECTION_UPLOADS: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor grayColor];
                break;
            }
                
            default:
                DLog(@"Warning! UITableView section can not be recognized.")
                break;
        }
    }
    
    cell.textLabel.text = [[dataSource objectForKey:[NSNumber numberWithInt:[indexPath section]]] objectAtIndex:[indexPath row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
