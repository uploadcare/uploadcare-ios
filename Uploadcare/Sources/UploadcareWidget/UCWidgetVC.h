//
//  UCWidgetVC.h
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCClient.h"

// You can fetch thumbmail image in UIImage format from response dictionary for remote uploads
extern NSString * const UCWidgetResponseLocalThumbnailResponseKey;

/**
 * Completion block for all types of operations.

 * @param fileId   Uploaded to Uploadcare file id
 * @param response Response serialized value. May be nil. For remote uploads contains useful information about uploaded file.
 * @param error    Error object which can contain API-dependent failure information, or come from Foundation issue, discovered during client request process.
 */
typedef void (^UCWidgetCompletionBlock)(NSString *fileId, id response, NSError *error);

/**
 This is example implementation of UIViewController which can lead to the root level of presentation.
 At this layer user selects appropriate social network source and opens UCGalleryVC controller.
 */
@interface UCWidgetVC : UITableViewController

- (id)initWithProgress:(UCProgressBlock)progress
            completion:(UCWidgetCompletionBlock)completion;

@end
