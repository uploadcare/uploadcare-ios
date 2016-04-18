//
//  UCWidgetVC.h
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This is example implementation of UIViewController which can lead to the root level of presentation.
 At this layer user selects appropriate social network source and opens UCGalleryVC controller.
 */
@interface UCWidgetVC : UITableViewController

- (id)initWithProgress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progress
            completion:(void(^)(NSString *fileId, NSError *error))completion;

@end
