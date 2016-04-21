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
#import <SafariServices/SafariServices.h>
#import "UCSocialConstantsHeader.h"
#import "UCSocialEntriesCollection.h"
#import "UCGalleryVC.h"
#import "UCSocialEntry.h"
#import "UCConstantsHeader.h"
#import "UCSocialManager.h"

@interface UCWidgetVC () <SFSafariViewControllerDelegate>
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
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

- (void)showDocumentPicker:(UITableViewCell *)sender {
    UIDocumentMenuViewController *menu = [SharedSocialManager documentControllerFrom:self progress:self.progressBlock completion:self.completionBlock];
    menu.popoverPresentationController.sourceView = sender.contentView;
    menu.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    [self presentViewController:menu animated:YES completion:nil];
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
    if (section == 0) {
        return @"Social sources";
    } else {
        return @"Local sources";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.tableData.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        UCSocialSource *social = self.tableData[indexPath.row];
        cell.textLabel.text = social.sourceName;
    } else {
        cell.textLabel.text = @"Choose local file";
    }

    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UCSocialSource *social = self.tableData[indexPath.row];
        [self showGalleryWithSource:social];
    } else {
        [self showDocumentPicker:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

#pragma mark - <SFSafariViewControllerDelegate>

- (NSArray<UIActivity *> *)safariViewController:(SFSafariViewController *)controller activityItemsForURL:(NSURL *)URL title:(nullable NSString *)title {
    NSLog(@"SF URL: %@", URL.absoluteString);
    return nil;
}

/*! @abstract Delegate callback called when the user taps the Done button. Upon this call, the view controller is dismissed modally. */
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    NSLog(@"SF DID FINISH");
}

/*! @abstract Invoked when the initial URL load is complete.
 @param success YES if loading completed successfully, NO if loading failed.
 @discussion This method is invoked when SFSafariViewController completes the loading of the URL that you pass
 to its initializer. It is not invoked for any subsequent page loads in the same SFSafariViewController instance.
 */
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    NSLog(@"SF DID COMPLETE INITIAL: %@", didLoadSuccessfully ? @"YES" : @"NO");
}

@end
