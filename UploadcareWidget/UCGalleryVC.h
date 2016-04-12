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

@protocol UCGalleryVCDelegate <NSObject>

- (void)fetchNextPageWithChunk:(UCSocialChunk *)chunk nextPagePath:(NSString *)nextPagePath;

- (void)fetchChunk:(UCSocialChunk *)chunk path:(UCSocialPath *)path newWindow:(BOOL)newWindow;

- (NSArray<UCSocialChunk*> *)availableSocialChunks;
@end

@interface UCGalleryVC : UICollectionViewController
@property (nonatomic, strong) UCSocialEntriesCollection *entriesCollection;
@property (nonatomic, weak) id<UCGalleryVCDelegate> delegate;

- (id)initWithMode:(UCGalleryMode)mode completion:(void(^)(UCSocialEntry *socialEntry))completion;

@end


