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
#import "UIImage+Bundle.h"

#define SCREEN_NAME @"Social sources"

NSString * const UCWidgetResponseLocalThumbnailResponseKey = @"local_thumbnail";

@interface UCWidgetVC ()

@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;
@property (nonatomic, strong) NSArray<UCSocialSource *> *tableData;
@property (nonatomic, strong) UCSocialSource *source;
@property (nonatomic, copy) UCWidgetCompletionBlock completionBlock;
@property (nonatomic, copy) UCProgressBlock progressBlock;

@end

@implementation UCWidgetVC

- (id)initWithProgress:(UCProgressBlock)progress
            completion:(UCWidgetCompletionBlock)completion {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _completionBlock = completion;
        _progressBlock = progress;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(UCSocialSourceCell.class) bundle:[NSBundle bundleForClass:UCSocialSourceCell.class]] forCellReuseIdentifier:@"cell"];
    self.navigationItem.title = SCREEN_NAME;

    [self setupLoadingSpinner];
    [self setupNavigationItems];
    [self fetchSocialSources];
}

- (void)setupLoadingSpinner {
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingSpinner.color = [UIColor lightGrayColor];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loadingSpinner];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingSpinner
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingSpinner
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1 constant:0]];
}

- (void)setupNavigationItems {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(didPressClose:)];
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

    [self.loadingSpinner startAnimating];
    self.tableView.scrollEnabled = NO;

    __weak __typeof(self) weakSelf = self;
    [SharedSocialManager fetchSocialSourcesWithCompletion:^(NSArray<UCSocialSource *> *response, NSError *error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        self.tableView.scrollEnabled = YES;
        [self.loadingSpinner stopAnimating];
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
    UCGalleryVC *gallery = [[UCGalleryVC alloc] initWithSource:source
                                                     rootChunk:source.rootChunks.firstObject
                                                      progress:self.progressBlock
                                                    completion:self.completionBlock];
    if (self.navigationController) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

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
    if (self.completionBlock) self.completionBlock(nil, nil, error);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UCSocialSourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UCSocialSource *social = self.tableData[indexPath.row];
    NSString *socialName = [social.sourceName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                              withString:[[social.sourceName substringToIndex:1] capitalizedString]];
    cell.socialName.text = socialName;
    cell.socialImage.image = [UIImage imageNamed:[social.sourceName stringByAppendingPathExtension:@"png"] inBundle:[NSBundle bundleForClass:self.class]];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UCSocialSource *social = self.tableData[indexPath.row];
    [self showGalleryWithSource:social];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
