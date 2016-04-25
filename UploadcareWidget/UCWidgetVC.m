//
//  UCWidgetVC.m
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCWidgetVC.h"
#import "UCClient+Social.h"
#import "UCSocialSourcesRequest.h"
#import "UCSocialMacroses.h"
#import "UCSocialSource.h"
#import "UCSocialChunk.h"
#import "UCSocialConstantsHeader.h"
#import "UCSocialEntriesCollection.h"
#import "UCGalleryVC.h"
#import "UCSocialEntry.h"
#import "UCConstantsHeader.h"
#import "UCSocialManager.h"
#import "UCSocialSourceCell.h"

@interface UCWidgetVC ()
@property (nonatomic, strong) NSArray<UCSocialSource *> *tableData;
@property (nonatomic, strong) UCSocialSource *source;
@property (nonatomic, copy) void (^completionBlock)(NSString *fileId, NSError *error);
@property (nonatomic, copy) void (^progressBlock)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend);
@end

@implementation UCWidgetVC

- (id)initWithProgress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progress
            completion:(void(^)(NSString *fileId, NSError *error))completion {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _completionBlock = completion;
        _progressBlock = progress;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"UCSocialSourceCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self fetchSocialSources];
    [self setupNavigationItems];
}

- (void)setupNavigationItems {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(didPressClose:)];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

- (void)didPressClose:(id)sender {
    [self closeControllerWithCompletion:nil];
}

- (void)closeControllerWithCompletion:(void(^)())completion {
    __weak __typeof(self) weakSelf = self;
    void (^dismissBlock)() = ^void() {
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:completion];
    };
    
    if ([[NSThread currentThread] isMainThread]) {
        dismissBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            dismissBlock();
        });
    }

}

- (void)fetchSocialSources {
    __weak __typeof(self) weakSelf = self;
    [SharedSocialManager fetchSocialSourcesWithCompletion:^(NSArray<UCSocialSource *> *response, NSError *error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (response) {
            strongSelf.tableData = response;
            [strongSelf.tableView reloadData];
        } else if (error) {
            [strongSelf handleError:error];
        }
    }];
}

- (void)showGalleryWithSource:(UCSocialSource *)source {
    self.source = source;
    UCGalleryVC *gallery = [[UCGalleryVC alloc] initWithMode:self.currentMode
                                                      source:source
                                                   rootChunk:source.rootChunks.firstObject
                                                    progress:self.progressBlock
                                                  completion:self.completionBlock];
    if (self.navigationController) {
        [self.navigationController pushViewController:gallery animated:YES];
    } else {
        [self presentViewController:gallery animated:YES completion:nil];
    }
}

- (UCGalleryMode)currentMode {
    NSArray *fileProviders = @[@"box", @"skydrive", @"dropbox", @"gdrive"];
    return [fileProviders containsObject:self.source.sourceName] ? UCGalleryModeList : UCGalleryModeGrid;
}

- (void)handleError:(NSError *)error {
    if (self.completionBlock) self.completionBlock(nil, error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Social sources";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UCSocialSourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UCSocialSource *social = self.tableData[indexPath.row];
    cell.socialName.text = social.sourceName;
    UIImage *image = [UIImage imageNamed:social.sourceName];
    [cell.socialImage setImage:image];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UCSocialSource *social = self.tableData[indexPath.row];
    [self showGalleryWithSource:social];
}

@end
