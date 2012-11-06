//
//  UploadcareMenu.m
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCUploadViewController.h"
#import "UCAlbumsList.h"
#import "UploadcareServicesConfigurator.h"

#import "GRKConfiguration.h"
#import "GRKDeviceGrabber.h"
#import "GRKFacebookGrabber.h"
#import "GRKFlickrGrabber.h"
#import "GRKInstagramGrabber.h"

@interface UCUploadViewController ()
@property GRKServiceGrabber *grabber;
@property UCAlbumsList *albumList;
@end

@implementation UCUploadViewController

+ (void)initialize {
//    [GRKConfiguration initializeWithConfigurator:[[UploadcareServicesConfigurator alloc]init]];
}

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        /* ... */
        [GRKConfiguration initializeWithConfiguratorClassName:@"UploadcareServicesConfigurator"];
    }
    
    return self;
}

#pragma mark - Public interfaces

- (void)setNavigationTitle:(NSString *)navigationTitle {
    _navigationTitle = navigationTitle;
    self.navigationItem.title = navigationTitle;
}

#pragma mark - UITableViewController doodad

- (void)viewDidLoad {
    self.navigationItem.title = self.title ? self.title : NSLocalizedString(@"Upload", @"Uploadcare menu default navigation view title");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Menu declaration

+ (NSArray *)menuItems {
    static NSArray* _menuItems;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _menuItems = @[
                @{@"items": @[
                    @{ @"textLabel.text"          : @"Snap a Photo",
                       @"textLabel.textAlignment" : @(NSTextAlignmentCenter),
                       @"action"                  : @"uploadFromCamera"
                     },

                    @{ @"textLabel.text"          : @"Select from Library",
                       @"textLabel.textAlignment" : @(NSTextAlignmentCenter),
                       @"action"                  : @"uploadFromLibrary"
                     },
                 ],
                },

                @{@"items": @[
                    @{ @"textLabel.text"  : @"Facebook",
                       @"imageView.image" : [UIImage imageNamed:@"icon_facebook"],
                       @"action"          : @"uploadFromFacebook",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     },

                    @{ @"textLabel.text"  : @"Flickr",
                       @"imageView.image" : [UIImage imageNamed:@"icon_flickr"],
                       @"action"          : @"uploadFromFlickr",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     },

                    @{ @"textLabel.text"  : @"Instagram",
                       @"imageView.image" : [UIImage imageNamed:@"icon_instagram"],
                       @"action"          : @"uploadFromInstagram",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     },

                    @{ @"textLabel.text"  : @"Internet Link",
                       @"imageView.image" : [UIImage imageNamed:@"icon_url"],
                       @"action"          : @"uploadFromURL",
                       @"accessoryType"   : @(UITableViewCellAccessoryDisclosureIndicator),
                     },

                 ],
                 @"footer" : @"Powered by Uploadcare",
                },
        ];
    });
    return _menuItems;
}

- (NSArray *)menuItems {
    return [self.class menuItems];
}

#pragma mark - Menu handlers

- (void)uploadFromCamera {
    
}

- (void)uploadFromLibrary {
    /* TODO: reuse grabbers? */
    self.grabber = [[GRKDeviceGrabber alloc] init];
    self.albumList = [[UCAlbumsList alloc] initWithGrabber:self.grabber
                                                         serviceName:@"Library"];
    [self.navigationController pushViewController:self.albumList animated:YES];
}

- (void)uploadFromFacebook {
    self.grabber = [[GRKFacebookGrabber alloc] init];
    self.albumList = [[UCAlbumsList alloc] initWithGrabber:self.grabber
                                                         serviceName:@"Facebook"];
    [self.navigationController pushViewController:self.albumList animated:YES];
}

- (void)uploadFromFlickr {
    self.grabber = [[GRKFlickrGrabber alloc] init];
    self.albumList = [[UCAlbumsList alloc] initWithGrabber:self.grabber
                                                         serviceName:@"Flickr"];
    [self.navigationController pushViewController:self.albumList animated:YES];
}

- (void)uploadFromInstagram {
    self.grabber = [[GRKInstagramGrabber alloc] init];
    self.albumList = [[UCAlbumsList alloc] initWithGrabber:self.grabber
                                                         serviceName:@"Instagram"];
    [self.navigationController pushViewController:self.albumList animated:YES];
}

- (void)uploadFromURL {
    
}

@end
