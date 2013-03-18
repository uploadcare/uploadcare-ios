//
//  UPCWidgetMenuViewController.h
//  uShare
//
//  Created by Zoreslav Khimich on 18/03/2013.
//  Copyright (c) 2013 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPCWidgetMenuViewController : UITableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (id)initWithUploadcarePublicKey:(NSString *)publicKey;

@end
