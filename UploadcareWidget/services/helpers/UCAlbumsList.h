//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRKServiceGrabber.h"

enum {
    UCAlbumsListStateInitial = 0,
    UCAlbumsListStateConnecting,
    UCAlbumsListStateConnected,
    UCAlbumsListStateGrabbing,
    UCAlbumsListStateAlbumsGrabbed,
    UCAlbumsListStateAllAlbumsGrabbed,
    UCAlbumsListStateError = 99
};
typedef NSUInteger UCAlbumsListState;


@interface UCAlbumsList : UITableViewController {
    GRKServiceGrabber * _grabber;
    NSString * _serviceName;
    NSMutableArray * _albums;
    NSUInteger _lastLoadedPageIndex;
    BOOL allAlbumsGrabbed;
    UCAlbumsListState state;
}

-(id) initWithGrabber:(id)grabber andServiceName:(NSString *)serviceName;

@end
