//
//  UCGalleryVC.h
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCSocialEntriesCollection.h"

typedef NS_ENUM(NSUInteger, UCGalleryMode) {
    UCGalleryModeGrid,
    UCGalleryModeList
};

@class UCSocialSource;

@interface UCGalleryVC : UICollectionViewController
@property (nonatomic, strong) UCSocialEntry *entry;

- (id)initWithMode:(UCGalleryMode)mode
            source:(UCSocialSource *)source
         rootChunk:(UCSocialChunk *)rootChunk
          progress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progress
        completion:(void(^)(NSString *fileId, NSError *error))completion;

@end
