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

@interface UCWidgetVC ()
@property (nonatomic, strong) NSArray<UCSocialSource *> *tableData;
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

- (void)queryObjectOrLoginAddressForSourceBase:(NSString *)sourceBase rootChunkPath:(NSString *)rootChunkPath path:(id)path {
    
//    NSString *absolutePath;
//    absolutePath = [[USSBaseAddress stringByAppendingPathComponent:sourceBase] stringByAppendingPathComponent:rootChunkPath];
//    
//    [self.client getPath:absolutePath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        assert([responseObject isKindOfClass:[NSDictionary class]]);
//        NSString *loginAddress = [responseObject objectForKey:USSLoginAddressKey];
//        if (loginAddress) {
//            resultBlock(nil, loginAddress, nil);
//        }else if([[responseObject objectForKey:@"obj_type"]isEqualToString:@"error"]) {
//            resultBlock(nil, nil, [NSError errorWithDomain:USSErrorDomain code:1 userInfo:responseObject]);
//        }else {
//            USSThingSet *thingSet = [[USSThingSet alloc]initWithJSON:responseObject];
//            resultBlock(thingSet, nil, nil);
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        resultBlock(nil, nil, error);
//    }];
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
    [self queryObjectOrLoginAddressForSourceBase:social.urls[@"source_base"] rootChunkPath:social.rootChunks.firstObject[@"path_chunk"] path:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
