//
//  ViewController.m
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "UCKit.h"

#define RLog(fmt, ...)  { [self presentLogMessage:[NSString stringWithFormat:fmt, ##__VA_ARGS__]];}

static NSString * const testRemoteImagePath  = @"https://breezometer.com/wordpress/wp-content/uploads/2016/01/nature_big_tree_hd.jpg";
static NSString * const testRemoteDataPath  = @"http://download.thinkbroadband.com/100MB.zip";
static NSString * const testRemoteBigDataPath  = @"http://download.thinkbroadband.com/200MB.zip";


typedef NS_ENUM(NSUInteger, kCellType) {
    kCellTypeUploadData,
    kCellTypeUploadRemote,
    kCellTypeUploadBigRemote,
    kCellTypeUploadVeryBigRemote,
    kCellTypeGetFileInfo,
    kCellTypeCreateGroup,
    kCellTypeGetGroupInfo
};

#define ROWS_COUNT 7

@interface ViewController () <UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        DetailViewController *dvc = [segue destinationViewController];
        self.delegate = dvc;
        [self performRequestForCellType:indexPath.row];
    }
}

#pragma mark - <UITableViewDelegate>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ROWS_COUNT;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell.textLabel setText:cellTitleForType(indexPath.row)];
    return cell;
}

#pragma mark - Uploadcare requests

- (void)performRequestForCellType:(kCellType)cellType {
    switch (cellType) {
        case kCellTypeUploadData: {
            [self testDataUpload:[self localFileData] completion:nil];
            break;
        }
        case kCellTypeUploadRemote: {
            [self testRemoteURL:[NSURL URLWithString:testRemoteImagePath] completion:nil];
            break;
        }
        case kCellTypeGetFileInfo: {
            [self testDataUpload:[self localFileData] completion:^(NSString *fileID) {
                [self testFileInfo:fileID];
            }];
            break;
        }
        case kCellTypeUploadBigRemote: {
            [self testRemoteURL:[NSURL URLWithString:testRemoteDataPath] completion:nil];
            break;
        }
        case kCellTypeUploadVeryBigRemote: {
            [self testRemoteURL:[NSURL URLWithString:testRemoteBigDataPath] completion:nil];
            break;
        }
        case kCellTypeCreateGroup: {
            [self testDataUpload:[self localFileData] completion:^(NSString *fileID) {
                [self testGroupCreate:@[fileID] completion:nil];
            }];
            break;
        }
        case kCellTypeGetGroupInfo: {
            [self testDataUpload:[self localFileData] completion:^(NSString *fileID) {
                [self testGroupCreate:@[fileID] completion:^(NSString *groupID) {
                    [self testGroupInfo:groupID];
                }];
            }];
            break;
        }
    }
}



- (void)testDataUpload:(NSData *)data completion:(void(^)(NSString *fileID))completion {
    UCFileUploadRequest *request = [UCFileUploadRequest requestWithFileData:[self localFileData] fileName:@"file" mimeType:@"image/jpeg"];
    if (request) RLog(@"Local file upload request created: %@", request);
    [[UCClient defaultClient] performUCRequest:request progress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        float progress = (float)totalBytesSent / (float)totalBytesExpectedToSend;
        RLog(@"Progress: %f", progress);
    } completion:^(id response, NSError *error) {
        if (!error) {
            RLog(@"Response: %@", response);
            if (completion) completion(response[@"file" ]);
        } else {
            RLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)testRemoteURL:(NSURL *)remoteURL completion:(void(^)(NSString *fileID))completion  {
    
    UCRemoteFileUploadRequest *req = [UCRemoteFileUploadRequest requestWithRemoteFileURL:remoteURL];
    if (req) RLog(@"Remote url request created: %@", req);
    [[UCClient defaultClient] performUCRequest:req progress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        float progress = (float)totalBytesSent / (float)totalBytesExpectedToSend;
        RLog(@"Progress: %f", progress);
    } completion:^(id response, NSError *error) {
        
        if (!error) {
            RLog(@"Response: %@", response);
        } else {
            RLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)testFileInfo:(NSString *)fileID {
    UCFileInfoRequest *request = [UCFileInfoRequest requestWithFileID:fileID];
    if (request) RLog(@"File info request created: %@", request);
    [[UCClient defaultClient] performUCRequest:request progress:nil completion:^(id response, NSError *error) {
        if (!error) {
            RLog(@"Response: %@", response);
        } else {
            RLog(@"Error: %@", error);
        }
    }];
}

- (void)testGroupInfo:(NSString *)groupInfo {
    UCGroupInfoRequest *req = [UCGroupInfoRequest requestWithGroupID:groupInfo];
    if (req) RLog(@"Group info request created: %@", req);
    [[UCClient defaultClient] performUCRequest:req progress:nil
                                    completion:^(id response, NSError *error) {
                                        if (!error) {
                                            RLog(@"Response: %@", response);
                                        } else {
                                            RLog(@"Error: %@", error.localizedDescription);
                                        }
                                    }];
}

- (void)testGroupCreate:(NSArray *)ids completion:(void(^)(NSString *groupID))completion {
    UCGroupPostRequest *req = [UCGroupPostRequest requestWithFileIDs:ids];
    if (req) RLog(@"Group post request created: %@", req);
    [[UCClient defaultClient] performUCRequest:req progress:nil
                                    completion:^(id response, NSError *error) {
                                        if (!error) {
                                            RLog(@"Response: %@", response);
                                            NSString *groupID = response[@"id"];
                                            if (completion) completion(groupID);
                                        } else {
                                            RLog(@"Error: %@", error.localizedDescription);
                                        }
    }];
}

- (void)presentLogMessage:(NSString *)logMessage {
    void (^block)(NSString *message) = ^void(NSString *message) {
        NSLog(@"%@", logMessage);
        if ([self.delegate respondsToSelector:@selector(didReceiveLogMessage:)]) {
            [self.delegate didReceiveLogMessage:logMessage];
        }
    };
    if ([[NSThread currentThread] isMainThread]) {
        block(logMessage);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(logMessage);
        });
    }
}

#pragma mark - Utilities

- (NSData *)localFileData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"testimage" ofType:@"jpg"];
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:path];
    return fileData;
}

NSString *cellTitleForType(kCellType type) {
    NSString *returnedValue = nil;
    switch (type) {
        case kCellTypeUploadData: {
            returnedValue = @"Upload data";
            break;
        }
        case kCellTypeUploadRemote: {
            returnedValue = @"Upload remote image url";
            break;
        }
        case kCellTypeUploadBigRemote: {
            returnedValue = @"Upload 100mb remote file";
            break;
        }
        case kCellTypeUploadVeryBigRemote: {
            returnedValue = @"Upload 200mb remote file";
            break;
        }
        case kCellTypeGetFileInfo: {
            returnedValue = @"Get file info";
            break;
        }
        case kCellTypeCreateGroup: {
            returnedValue = @"Create group";
            break;
        }
        case kCellTypeGetGroupInfo: {
            returnedValue = @"Get group info";
            break;
        }
    }
    return returnedValue;
}

@end
