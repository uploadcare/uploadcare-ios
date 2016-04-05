//
//  ViewController.h
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LogDelegateProtocol <NSObject>

- (void)didReceiveLogMessage:(NSString *)logMessage;

@end

@interface ViewController : UIViewController

@property (nonatomic, weak) id<LogDelegateProtocol> delegate;

@end



