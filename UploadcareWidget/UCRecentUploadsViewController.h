//
//  UCRecentUploadsViewController.h
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/18/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UploadcareKit.h>

@interface UCRecentUploadsViewController : UITableViewController

@property (strong) UploadcareSuccessBlock uploadCompletionBlock;
@property (strong) UploadcareFailureBlock uploadFailureBlock;


@end
