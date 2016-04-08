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
- (void)fetchPath:(NSString *)path forCollection:(UCSocialEntriesCollection *)collection;
@end

@interface UCGalleryVC : UICollectionViewController
@property (nonatomic, strong) UCSocialEntriesCollection *entriesCollection;
@property (nonatomic, weak) id<UCGalleryVCDelegate> delegate;

- (id)initWithCompletion:(void(^)(UCSocialEntry *socialEntry))completion;

@end


