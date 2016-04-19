//
//  UCGalleryVC.h
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCSocialEntriesCollection.h"

/**
 *  Gallery presentation mode.
 */
typedef NS_ENUM(NSUInteger, UCGalleryMode) {
    /**
     *  Cells are presented in grid manner, best suitable for image providers,
     *  such as instagram etc.
     */
    UCGalleryModeGrid,
    /**
     *  Cells are presented in list manner, best suitable for file providers,
     *  such as dropbox etc.
     */
    UCGalleryModeList,
    /**
     *  Cells are presented in list manner, with rounded images of bigger size.
     */
    UCGalleryModePersonList,
    /**
     *  Cells are presented in grid manner with spacing, allowing to put album
     *  information below the image.
     */
    UCGalleryModeAlbumsGrid
};

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
 *  @param mode       UCGalleryMode mode of the gallery.
 *  @param source     UCSocialSource object instance carrying all necessary root chunks information
 *  and url schemes.
 *  @param rootChunk  UCSocialChunk object instance is used for determining which root chunk 
 *  exactly is used in the current UCSocialSource source.
 *  @param progress   Progress handler for controlling upload progress flow.
 *  @param completion Completion handler is invoked when the request is finished.
 *
 *  @return UCGalleryVC instance.
 */
- (id)initWithMode:(UCGalleryMode)mode
            source:(UCSocialSource *)source
         rootChunk:(UCSocialChunk *)rootChunk
          progress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progress
        completion:(void(^)(NSString *fileId, NSError *error))completion;

@end
