//
//  UCWebViewController.h
//  ExampleProject
//
//  Created by Yury Nechaev on 06.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCWebViewController : UIViewController

- (void)loadUrl:(NSURL *)url withLoadingBlock:(void(^)(NSURL *url))loadingBlock;

@end
