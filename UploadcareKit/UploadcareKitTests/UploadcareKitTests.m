//
//  UploadcareKitTests.m
//  UploadcareKitTests
//
//  Created by Artyom Loenko on 8/1/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadcareKitTests.h"
#import "UploadcareKit.h"

@implementation UploadcareKitTests

- (void)setUp
{
    [super setUp];
    STAssertNotNil([UploadcareKit shared], @"singleton shouldn't be nil");
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testExample
{
    [[UploadcareKit shared] setPublicKey:@"fd939b2f0698f7e2ca4edd5064827c21a150c8534a2407d88f42bcff7d4f2c68"
                               andSecret:@"4b9f679057703b699cef2955a7a64a4fe21e03c1b9f221ff76ad262bc180ee1a"];
}

@end
