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
#import "UCSocialEntriesRequest.h"
#import "UCWebViewController.h"
#import <SafariServices/SafariServices.h>
#import "UCSocialConstantsHeader.h"
#import "UCSocialEntriesCollection.h"
#import "UCGalleryVC.h"
#import "UCSocialEntry.h"
#import "UCRemoteFileUploadRequest.h"
#import "UCSocialEntryRequest.h"
#import "UCConstantsHeader.h"

@interface UCWidgetVC () <SFSafariViewControllerDelegate, UCGalleryVCDelegate>
@property (nonatomic, strong) NSArray<UCSocialSource *> *tableData;
@property (nonatomic, strong) UCWebViewController *webVC;
@property (nonatomic, strong) UCGalleryVC *gallery;
@property (nonatomic, strong) UCSocialSource *source;
@property (nonatomic, strong) UCSocialChunk *chunk;
@property (nonatomic, copy) void (^completionBlock)(BOOL completed, NSString *fileId, NSError *error);
@property (nonatomic, copy) void (^progressBlock)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend);
@property (nonatomic, copy) void (^responseBlock)(id response, NSError *error);
@end

@implementation UCWidgetVC

- (id)initWithProgress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progress
            completion:(void(^)(BOOL completed, NSString *fileId, NSError *error))completion {
    self = [super init];
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
    [self closeController];
}

- (void)closeController {
    __weak __typeof(self) weakSelf = self;
    void (^dismissBlock)() = ^void() {
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
    };
    
    if ([[NSThread currentThread] isMainThread]) {
        dismissBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            dismissBlock();
        });
    }

}

- (void(^)(id response, NSError *error))responseBlock {
    if (!_responseBlock) {
        __weak __typeof(self) weakSelf = self;
        _responseBlock = ^(id response, NSError *error){
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    NSString *loginAddress = [response objectForKey:@"login_link"];
                    if (loginAddress) {
                        [strongSelf loginUsingAddress:loginAddress];
                    } else if ([response[@"obj_type"] isEqualToString:@"error"]) {
                        NSError *error = [NSError errorWithDomain:[UCClient socialErrorDomain] code:UCErrorUploadcare
                                                         userInfo:@{NSLocalizedDescriptionKey : response[@"error"]}];
                        [strongSelf handleError:error];
                    } else {
                        [strongSelf processData:response];
                    }
                    
                } else {
                    [strongSelf handleError:error];
                }
            });
        };
    }
    return _responseBlock;
}

- (void)fetchSocialSources {
    __weak __typeof(self) weakSelf = self;
    [[UCClient defaultClient] performUCSocialRequest:[UCSocialSourcesRequest new] completion:^(id response, NSError *error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!error) {
            NSArray *sources = response[@"sources"];
            NSMutableArray *result = @[].mutableCopy;
            for (id source in sources) {
                UCSocialSource *socialSource = [[UCSocialSource alloc] initWithSerializedObject:source];
                if (socialSource) [result addObject:socialSource];
            }
            strongSelf.tableData = result.copy;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            [strongSelf handleError:error];
        }
    }];
}

- (void)loginUsingAddress:(NSString *)loginAddress {
    __weak __typeof(self) weakSelf = self;

//    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
//        SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:loginAddress]];
//        svc.delegate = self;
//        [self.navigationController pushViewController:svc animated:YES];
//    } else {
    [self.navigationController popToRootViewControllerAnimated:YES];
        self.webVC = [[UCWebViewController alloc] initWithURL:[NSURL URLWithString:loginAddress] loadingBlock:^(NSURL *url) {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            NSLog(@"URL: %@", url);
            if ([url.host isEqual:UCSocialAPIRoot] && [url.lastPathComponent isEqual:@"endpoint"]) {
                [strongSelf.webVC dismissViewControllerAnimated:YES completion:nil];
                [strongSelf queryObjectOrLoginAddressForSource:strongSelf.source rootChunk:strongSelf.chunk path:nil];
            }
        }];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:self.webVC];
    [self.navigationController presentViewController:navc animated:YES completion:nil];
//    }
}

- (void)queryObjectOrLoginAddressForSource:(UCSocialSource *)source rootChunk:(UCSocialChunk *)rootChunk path:(NSString *)path {
    self.source = source;
    self.chunk = rootChunk;
    [[UCClient defaultClient] performUCSocialRequest:[UCSocialEntriesRequest requestWithSource:source chunk:rootChunk path:path] completion:self.responseBlock];
}

- (void)processData:(id)responseData {
    UCSocialEntriesCollection *collection = [[UCSocialEntriesCollection alloc] initWithSerializedObject:responseData];
    [self appendGalleryCollection:collection];
}

- (void)appendGalleryCollection:(UCSocialEntriesCollection *)collection {
    self.gallery.entriesCollection = collection;
}

- (void)showGalleryWithRoot:(UCSocialChunk *)root {
    __weak __typeof(self) weakSelf = self;
    self.gallery = [[UCGalleryVC alloc] initWithMode:self.currentMode completion:^(UCSocialEntry *socialEntry) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf uploadSocialEntry:socialEntry];
    }];
    self.gallery.delegate = self;
    [self.navigationController pushViewController:self.gallery animated:YES];
}

- (UCGalleryMode)currentMode {
    NSArray *fileProviders = @[@"box", @"skydrive", @"dropbox", @"gdrive"];
    return [fileProviders containsObject:self.source.sourceName] ? UCGalleryModeList : UCGalleryModeGrid;
}

- (void)uploadSocialEntry:(UCSocialEntry *)entry {
    __weak __typeof(self) weakSelf = self;
    UCSocialEntryRequest *req = [UCSocialEntryRequest requestWithSource:self.source file:entry.action.urlString];
    [[UCClient defaultClient] performUCSocialRequest:req completion:^(id response, NSError *error) {
        if (!error && [response isKindOfClass:[NSDictionary class]]) {
            NSString *fileURL = response[@"url"];
            UCRemoteFileUploadRequest *request = [UCRemoteFileUploadRequest requestWithRemoteFileURL:[NSURL URLWithString:fileURL]];
            [[UCClient defaultClient] performUCRequest:request progress:^(NSUInteger totalBytesSent, NSUInteger totalBytesExpectedToSend) {
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                if (strongSelf.progressBlock) strongSelf.progressBlock (totalBytesSent, totalBytesExpectedToSend);
            } completion:^(id response, NSError *error) {
                __strong __typeof__(weakSelf) strongSelf = weakSelf;
                if (!error) {
                    if (strongSelf.completionBlock) strongSelf.completionBlock(YES, response[@"file_id"], nil);
                } else {
                    if (strongSelf.completionBlock) strongSelf.completionBlock(NO, response, error);
                }
                [strongSelf closeController];
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleError:error];
            });
        }
    }];
}

- (void)handleError:(NSError *)error {
    if (self.completionBlock) self.completionBlock(NO, nil, error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UCSocialSource *social = self.tableData[indexPath.row];
    cell.textLabel.text = social.sourceName;
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UCSocialSource *social = self.tableData[indexPath.row];
    UCSocialChunk *chunk = social.rootChunks.firstObject;
    [self queryObjectOrLoginAddressForSource:social rootChunk:chunk path:nil];
    [self showGalleryWithRoot:chunk];
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

#pragma mark - <UCGalleryVCDelegate>
- (void)fetchNextPageWithChunk:(UCSocialChunk *)chunk nextPagePath:(NSString *)nextPagePath {
    [self queryObjectOrLoginAddressForSource:self.source rootChunk:chunk path:nextPagePath];
}

- (void)fetchChunk:(UCSocialChunk *)chunk path:(UCSocialPath *)path newWindow:(BOOL)newWindow {
    if (newWindow) [self showGalleryWithRoot:chunk];
    [self queryObjectOrLoginAddressForSource:self.source rootChunk:chunk path:path.fullPath];
}

- (NSArray<UCSocialChunk*> *)availableSocialChunks {
    return self.source.rootChunks;
}

@end
