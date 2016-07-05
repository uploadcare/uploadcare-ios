//
//  UCGalleryVC.h
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCSocialEntriesCollection.h"

@class UCSocialSource;

@interface UCGalleryVC : UICollectionViewController

/**
 *  This object determines if additional entry is used in path construction of this gallery instance.
 *  When this value is not nil, full path is extracted from it and used during initial fetch.
 */
@property (nonatomic, strong) UCSocialEntry *entry;

/**
 *  Initializes gallery with provided settings and values.
 *
 *  @param source     UCSocialSource object instance carrying all necessary root chunks information
 *  and url schemes.
 *  @param rootChunk  UCSocialChunk object instance is used for determining which root chunk 
 *  exactly is used in the current UCSocialSource source.
 *  @param progress   Progress handler for controlling upload progress flow.
 *  @param completion Completion handler is invoked when the request is finished.
 *
 *  @return UCGalleryVC instance.
 */
- (id)initWithSource:(UCSocialSource *)source
           rootChunk:(UCSocialChunk *)rootChunk
            progress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progress
          completion:(void(^)(NSString *fileId, NSError *error))completion;

@end
