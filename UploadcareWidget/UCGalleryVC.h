//
//  UCGalleryVC.h
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCSocialEntriesCollection.h"

@protocol UCGalleryVCDelegate <NSObject>

- (void)fetchNextPagePath:(NSString *)path forCollection:(UCSocialEntriesCollection *)collection;
- (void)fetchChunk:(UCSocialChunk *)chunk forCollection:(UCSocialEntriesCollection *)collection;
@end

@interface UCGalleryVC : UICollectionViewController
@property (nonatomic, strong) UCSocialEntriesCollection *entriesCollection;
@property (nonatomic, weak) id<UCGalleryVCDelegate> delegate;
@property (nonatomic, strong) UCSocialChunk *root;

- (id)initWithCompletion:(void(^)(UCSocialEntry *socialEntry))completion;

@end


