//
//  USViewController.h
//  ushare
//
//  Created by Zoreslav Khimich on 12/9/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UCWidget.h>

@interface USViewController : UIViewController<UCWidgetDelegate, UINavigationControllerDelegate>
- (IBAction)ushareTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@end
