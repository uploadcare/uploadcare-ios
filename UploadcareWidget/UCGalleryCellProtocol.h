//
//  UCGalleryCellProtocol.h
//  ExampleProject
//
//  Created by Yury Nechaev on 19.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UCSocialEntry;

@protocol UCGalleryCellProtocol <NSObject>
@property (nonatomic, strong) UCSocialEntry *socialEntry;
@end
