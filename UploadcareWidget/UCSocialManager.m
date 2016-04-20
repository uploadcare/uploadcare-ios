//
//  UCSocialManager.m
//  ExampleProject
//
//  Created by Yury Nechaev on 14.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialManager.h"
#import "UCSocialEntry.h"
#import "UCSocialEntryRequest.h"
#import "UCClient+Social.h"
#import "UCRemoteFileUploadRequest.h"
#import "UCSocialSourcesRequest.h"
#import "UCSocialSource.h"
#import "NSString+EncodeRFC3986.h"
#import "UCFileUploadRequest.h"

@interface UCSocialManager () <UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, weak) UIViewController *rootController;
@property (nonatomic, copy) void(^progressBlock)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend);
@property (nonatomic, copy) void(^completionBlock)(NSString *fileId, NSError *error);
@end

static UCSocialManager *instanceSocialManager = nil;

@implementation UCSocialManager

+ (instancetype)  sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceSocialManager = [[UCSocialManager alloc] init];
    });
    return instanceSocialManager;
}

- (void)fetchSocialSourcesWithCompletion:(void(^)(NSArray<UCSocialSource*> *response, NSError *error))completion {
    [[UCClient defaultClient] performUCSocialRequest:[UCSocialSourcesRequest new] completion:^(id response, NSError *error) {
        if (!error) {
            NSArray *sources = response[@"sources"];
            NSMutableArray *result = @[].mutableCopy;
            for (id source in sources) {
                UCSocialSource *socialSource = [[UCSocialSource alloc] initWithSerializedObject:source];
                if (socialSource) [result addObject:socialSource];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(result.copy, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, error);
            });
        }
    }];
}

- (void)presentDocumentControllerFrom:(UIViewController *)viewController
                             progress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progressBlock
                           completion:(void(^)(NSString *fileId, NSError *error))completionBlock {
    self.completionBlock = completionBlock;
    self.progressBlock = progressBlock;
    self.rootController = viewController;
    UIDocumentMenuViewController *menu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    [menu addOptionWithTitle:@"Photo and video" image:nil order:UIDocumentMenuOrderFirst handler:^{
    [menu addOptionWithTitle:@"Photo and video" image:[UIImage imageNamed:@"film-icon"] order:UIDocumentMenuOrderFirst handler:^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.modalPresentationStyle = UIModalPresentationFormSheet;
        [viewController presentViewController:picker animated:YES completion:nil];
    }];
    menu.delegate = self;
    [viewController presentViewController:menu animated:YES completion:nil];    
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.85);
    if (imageData) {
        if (self.progressBlock) self.progressBlock (0, NSUIntegerMax);
        UCFileUploadRequest *req = [UCFileUploadRequest requestWithFileData:imageData fileName:@"image" mimeType:@"image/jpeg"];
        [[UCClient defaultClient] performUCRequest:req
                                          progress:^(NSUInteger totalBytesSent, NSUInteger totalBytesExpectedToSend) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if (self.progressBlock) self.progressBlock(totalBytesSent, totalBytesExpectedToSend);
                                              });
                                          } completion:^(id response, NSError *error) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if (self.completionBlock) self.completionBlock (response[@"file"], error);
                                              });
                                          }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UIDocumentMenuDelegate>

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker {
    documentPicker.delegate = self;
    [self.rootController presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - <UIDocumentPickerDelegate>

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (self.progressBlock) self.progressBlock (0, NSUIntegerMax);
    UCFileUploadRequest *req = [UCFileUploadRequest requestWithFileURL:url];
    [[UCClient defaultClient] performUCRequest:req progress:^(NSUInteger totalBytesSent, NSUInteger totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progressBlock) self.progressBlock(totalBytesSent, totalBytesExpectedToSend);
        });
    } completion:^(id response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completionBlock) self.completionBlock (response[@"file"], error);
        });
    }];
}

@end
