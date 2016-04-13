//
//  DetailViewController.m
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSMutableArray *logMessages;
@property (nonatomic, assign) BOOL didAppear;
- (IBAction)didPressClose:(id)sender;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.didAppear = YES;
    [self processPendingLogMessages];
}

- (IBAction)didPressClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)logMessages {
    if (!_logMessages) _logMessages = [NSMutableArray new];
    return _logMessages;
}

- (void)processPendingLogMessages {
    for (NSString *message in self.logMessages) {
        [self appendLogMessage:message];
    }
    [self.logMessages removeAllObjects];
}

- (void)appendLogMessage:(NSString *)logMessage {
    NSString *text = self.textView.text;
    if (!text) text = @"";
    self.textView.text = [text stringByAppendingString:[NSString stringWithFormat:@"%@\n", logMessage]];
    self.textView.contentOffset = CGPointMake(0, self.textView.contentSize.height - self.textView.frame.size.height);
}

#pragma mark - <LogDelegateProtocol>

- (void)didReceiveLogMessage:(NSString *)logMessage {
    if (self.didAppear) [self appendLogMessage:logMessage];
    else [self.logMessages addObject:logMessage];
}

@end
