//
//  UCWidgetVC.m
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCWidgetVC.h"
#import "UCClient+Social.h"
#import "UCSocialRequest.h"

@interface UCSocialSource : NSObject

@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, strong) NSArray *rootChunks;
@property (nonatomic, strong) NSArray *urls;

+ (instancetype)sourceFromDictionary:(NSDictionary *)dictionary;

@end

@implementation UCSocialSource

+ (instancetype)sourceFromDictionary:(NSDictionary *)dictionary {
    UCSocialSource *source = [[UCSocialSource alloc] initWithDictionary:dictionary];
    return source;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    self = [super init];
    if (self) {
        [self updateWithDeserializedObject:dictionary];
    }
    return self;
}

- (void)updateWithDeserializedObject:(id)object {
    self.sourceName = object[@"name"];
    self.rootChunks = object[@"root_chunks"];
    self.urls = object[@"urls"];
    NSLog(@"Object: %@", object);
}

@end

@interface UCWidgetVC ()
@property (nonatomic, strong) NSArray<UCSocialSource *> *tableData;
@end

@implementation UCWidgetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [[UCClient defaultClient] performUCSocialRequest:[UCSocialRequest new] completion:^(id response, NSError *error) {
        if (!error) {
            NSArray *sources = response[@"sources"];
            NSMutableArray *result = @[].mutableCopy;
            for (id source in sources) {
                UCSocialSource *socialSource = [UCSocialSource sourceFromDictionary:source];
                [result addObject:socialSource];
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
