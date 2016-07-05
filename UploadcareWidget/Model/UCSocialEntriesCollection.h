//
//  UCSocialEntriesCollection.h
//  ExampleProject
//
//  Created by Yury Nechaev on 07.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialObject.h"
#import "UCSocialPath.h"

@class UCSocialEntry;
@class UCSocialChunk;

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

@interface UCSocialEntriesCollection : UCSocialObject

@property (nonatomic, strong) UCSocialPath *nextPage;
@property (nonatomic, strong) UCSocialPath *path;
@property (nonatomic, strong) UCSocialChunk *root;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSArray<UCSocialEntry*> *entries;
@property (nonatomic, assign, readonly) UCGalleryMode galleryMode;
@end
