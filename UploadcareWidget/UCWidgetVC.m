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

@interface UCWidgetVC () <SFSafariViewControllerDelegate, UCGalleryVCDelegate>
@property (nonatomic, strong) NSArray<UCSocialSource *> *tableData;
@property (nonatomic, strong) UCWebViewController *webVC;
@property (nonatomic, strong) UCGalleryVC *gallery;
@property (nonatomic, strong) UCSocialSource *source;
@property (nonatomic, strong) UCSocialChunk *chunk;
@property (nonatomic, copy) void (^responseBlock)(id response, NSError *error);
@end

@implementation UCWidgetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self fetchSocialSources];
}

- (void(^)(id response, NSError *error))responseBlock {
    if (!_responseBlock) {
        __weak __typeof(self) weakSelf = self;
        _responseBlock = ^(id response, NSError *error){
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            if (!error) {
                NSString *loginAddress = [response objectForKey:@"login_link"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (loginAddress) {
                        [strongSelf loginUsingAddress:loginAddress];
                    } else if ([response[@"obj_type"] isEqualToString:@"error"]) {
                        
                    } else {
                        [strongSelf processData:response];
                    }
                });
                
            } else {
                [strongSelf handleError:error];
            }
        };
    }
    return _responseBlock;
}

- (void)fetchSocialSources {
    [[UCClient defaultClient] performUCSocialRequest:[UCSocialSourcesRequest new] completion:^(id response, NSError *error) {
        if (!error) {
            NSArray *sources = response[@"sources"];
            NSMutableArray *result = @[].mutableCopy;
            for (id source in sources) {
                UCSocialSource *socialSource = [[UCSocialSource alloc] initWithSerializedObject:source];
                if (socialSource) [result addObject:socialSource];
            }
            self.tableData = result.copy;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            [self handleError:error];
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
        self.webVC = [[UCWebViewController alloc] initWithURL:[NSURL URLWithString:loginAddress] loadingBlock:^(NSURL *url) {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            NSLog(@"URL: %@", url);
            if ([url.host isEqual:UCSocialAPIRoot] && [url.lastPathComponent isEqual:@"endpoint"]) {
                [strongSelf.navigationController popViewControllerAnimated:YES];
                [strongSelf queryObjectOrLoginAddressForSource:strongSelf.source rootChunk:strongSelf.chunk path:nil];
            }
        }];
        [self.navigationController pushViewController:self.webVC animated:YES];
//    }
}

- (void)queryObjectOrLoginAddressForSource:(UCSocialSource *)source rootChunk:(UCSocialChunk *)rootChunk path:(NSString *)path {
    self.source = source;
    self.chunk = rootChunk;
    [[UCClient defaultClient] performUCSocialRequest:[UCSocialEntriesRequest requestWithSource:source chunk:rootChunk path:path] completion:self.responseBlock];
}

- (void)queryNextPageForSource:(UCSocialSource *)source entries:(UCSocialEntriesCollection *)entries path:(NSString *)path {
    [[UCClient defaultClient] performUCSocialRequest:[UCSocialEntriesRequest nextPageRequestWithSource:source entries:entries path:path] completion:self.responseBlock];
}

- (void)processData:(id)responseData {
    UCSocialEntriesCollection *collection = [[UCSocialEntriesCollection alloc] initWithSerializedObject:responseData];
    if (![self.gallery.entriesCollection.path.chunks isEqual:collection.path.chunks]) {
        [self showGalleryWithCollection:collection];
    } else {
        [self appendGalleryCollection:collection];
    }
}

- (void)appendGalleryCollection:(UCSocialEntriesCollection *)collection {
    self.gallery.entriesCollection = collection;
}

- (void)showGalleryWithCollection:(UCSocialEntriesCollection *)collection {
    self.gallery = [[UCGalleryVC alloc] initWithCompletion:^(UCSocialEntry *socialEntry) {
        NSLog(@"Completed with %@", socialEntry);
    }];
    self.gallery.entriesCollection = collection;
    self.gallery.delegate = self;
    [self.navigationController pushViewController:self.gallery animated:YES];
}

- (void)handleError:(NSError *)error {
    
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
    self.gallery = nil;
    [self queryObjectOrLoginAddressForSource:social rootChunk:chunk path:nil];
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

- (void)fetchNextPagePath:(NSString *)path forCollection:(UCSocialEntriesCollection *)collection {
    [self queryNextPageForSource:self.source entries:collection path:path];
}

- (void)fetchPath:(NSString *)path forCollection:(UCSocialEntriesCollection *)collection {
    [self queryObjectOrLoginAddressForSource:self.source rootChunk:collection.root path:path];
}

@end
