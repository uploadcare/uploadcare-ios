//
//  UPCDraweViewController.m
//  Social Source
//
//  Created by Zoreslav Khimich on 03/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "UPCDrawerViewController.h"
#import "UploadcareSocialSource.h"
#import "UPCGradientView.h"

@interface UPCDrawerViewController ()

@property (strong, nonatomic) NSArray *chunks;
@property (strong, nonatomic) UIView *selectedCellBackgroundSubview;
@property (strong, nonatomic) NSString *serviceName;

@end

@implementation UPCDrawerViewController

- (id)initWithChunks:(NSArray *)chunks serviceName:(NSString *)serviceName
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _chunks = chunks;
        _serviceName = serviceName;
        
        self.tableView.rowHeight = 44.f;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.chunks.count;
    }else{
        return 1; // Sign out
    }
}

- (CGFloat)heightNeeded {
    return self.tableView.rowHeight * (1 + [self tableView:self.tableView numberOfRowsInSection:0]);
}

- (UIView *)selectedCellBackgroundSubview {
    if (!_selectedCellBackgroundSubview) {
        _selectedCellBackgroundSubview = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"UPCDrawerCellSelected"]resizableImageWithCapInsets:UIEdgeInsetsMake(15, 37, 15, 37)]];
    }
    return _selectedCellBackgroundSubview;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"UPCDrawerViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.backgroundView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"UPCDrawerCellNormal"]resizableImageWithCapInsets:UIEdgeInsetsMake(2, 37, 2, 37)] highlightedImage:[[UIImage imageNamed:@"UPCDrawerCellSelected"]resizableImageWithCapInsets:UIEdgeInsetsMake(15, 37, 15, 37)]];
        cell.selectedBackgroundView = self.selectedCellBackgroundSubview;

        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = [UIColor colorWithRed:193./255 green:201./255 blue:215./255 alpha:1.0f];
        cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
        cell.textLabel.shadowColor = [UIColor blackColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
    }
    
    if (indexPath.section == 0) {
        USSPathChunk *chunk = self.chunks[indexPath.row];
        cell.textLabel.text = chunk.title;
    }else{
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Disconnect %@", @"Sign out drawer menu item title"), self.serviceName];
    }
    
    return cell;
}

@end
