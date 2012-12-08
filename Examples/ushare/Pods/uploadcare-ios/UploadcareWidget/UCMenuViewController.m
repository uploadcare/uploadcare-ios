//
//  UCServicesMenu.m
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/4/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCMenuViewController.h"

@interface UCMenuViewController ()
@end

@implementation UCMenuViewController
- (NSArray*)menuItems {
    /* not implemented */
    return nil;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.menuItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.menuItems[section] objectForKey:@"items"]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    // Configure the cell...
    NSDictionary *section = self.menuItems[indexPath.section];
    NSArray *items = section[@"items"];
    NSDictionary *item = items[indexPath.row];
    for (NSString *key in item) {
        if (![key isEqualToString:@"action"]) {
            [cell setValue:item[key] forKeyPath:key];
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.menuItems[section] objectForKey:@"header"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [self.menuItems[section] objectForKey:@"footer"];
}

#pragma mark - Table view delegate

#pragma GCC diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath].accessoryType != UITableViewCellAccessoryDisclosureIndicator) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    NSString *actionString = [[[self.menuItems[indexPath.section] objectForKey:@"items"]objectAtIndex:indexPath.row]objectForKey:@"action"];
    
    id target = self;
    [target performSelector:NSSelectorFromString(actionString)];
}
#pragma GCC diagnostic pop

@end
