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

@interface UCThingAction : NSObject
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *objectType;
@property (nonatomic, strong) NSString *urlString;

- (id)initWithObject:(id)object;
@end

@implementation UCThingAction
- (id)initWithObject:(id)object {
    self = [super init];
    if (self) {
        self.action = object[@"action"];
        self.objectType = object[@"obj_type"];
        self.urlString = object[@"url"];
    }
    return self;
}
@end

@interface UCThing : NSObject

@property (nonatomic, strong) UCThingAction *action;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *objType;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, strong) NSString *title;

- (id)initWithObject:(id)object;
@end

@implementation UCThing

- (id)initWithObject:(id)object {
    self = [super init];
    if (self) {
        self.action = [[UCThingAction alloc] initWithObject:object[@"action"]];
        SetIfNotNull(self.mimeType, object[@"mimetype"])
        SetIfNotNull(self.thumbnail, object[@"thumbnail"])
        SetIfNotNull(self.title, object[@"title"]);
    }
    return self;
}

@end

@interface UCThingsCollection : NSObject

@property (nonatomic, strong) NSDictionary *nextPage;
@property (nonatomic, strong) NSDictionary *path;
@property (nonatomic, strong) NSDictionary *root;
@property (nonatomic, strong) NSArray<UCThing*> *things;

+ (instancetype)collectionFromDictionary:(NSDictionary *)dictionary;

@end

@implementation UCThingsCollection

+ (instancetype)collectionFromDictionary:(NSDictionary *)dictionary {
    UCThingsCollection *collection = [[UCThingsCollection alloc] initWithDeserializedObject:dictionary];
    return collection;
}

- (id)initWithDeserializedObject:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self updateWithDeserializedObject:dictionary];
    }
    return self;
}

- (void)updateWithDeserializedObject:(id)object {
    SetIfNotNull(self.nextPage, object[@"next_page"]);
    SetIfNotNull(self.path, object[@"path"])
    SetIfNotNull(self.root, object[@"root"])
    NSMutableArray *things = @[].mutableCopy;
    [object[@"things"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UCThing *thing = [[UCThing alloc] initWithObject:obj];
        if (thing) [things addObject:thing];
    }];
    self.things = things;
}

@end

@interface UCWidgetVC () <SFSafariViewControllerDelegate>
@property (nonatomic, strong) NSArray<UCSocialSource *> *tableData;
@property (nonatomic, strong) UCWebViewController *webVC;
@end

@implementation UCWidgetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self fetchSocialSources];
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
            NSLog(@"Response: %@", response);
        } else {
            [self handleError:error];
        }
    }];
}

- (void)loginUsingAddress:(NSString *)loginAddress {
    
//    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:loginAddress]];
//    svc.delegate = self;
//    [self.navigationController presentViewController:svc animated:YES completion:nil];
    
    self.webVC = [[UCWebViewController alloc] init];
    [self.navigationController presentViewController:self.webVC animated:YES completion:nil];
    [self.webVC loadUrl:[NSURL URLWithString:loginAddress] withLoadingBlock:^(NSURL *url) {
        if ([url.host isEqual:[[NSURL URLWithString:UCSocialAPIRoot] host]] && [url.lastPathComponent isEqual:@"endpoint"]) {
            [self.webVC dismissViewControllerAnimated:YES completion:nil];
        }
    }];

}

- (void)queryObjectOrLoginAddressForSource:(UCSocialSource *)source rootChunk:(UCSocialChunk *)rootChunk path:(id)path {
    
    __weak __typeof(self) weakSelf = self;
    [[UCClient defaultClient] performUCSocialRequest:[UCSocialEntriesRequest requestWithSource:source chunk:rootChunk] completion:^(id response, NSError *error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!error) {
            NSLog(@"Response: %@", response);
            NSString *loginAddress = [response objectForKey:@"login_link"];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (loginAddress) {
                    [strongSelf loginUsingAddress:loginAddress];
                } else if ([response[@"obj_type"] isEqualToString:@"error"]) {
                    
                } else {
                    
                }
            });

        } else {
            [self handleError:error];
        }
    }];
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

@end
