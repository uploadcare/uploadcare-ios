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

- (void)fetchNextPageForCollection:(UCSocialEntriesCollection *)collection;

@end

@interface UCGalleryVC : UICollectionViewController
@property (nonatomic, strong) UCSocialEntriesCollection *entriesCollection;
@property (nonatomic, weak) id<UCGalleryVCDelegate> delegate;

- (id)initWitSocialEntriesCollection:(UCSocialEntriesCollection *)collection;

@end


