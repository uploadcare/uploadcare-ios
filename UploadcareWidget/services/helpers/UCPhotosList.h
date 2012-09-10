//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRKServiceGrabber.h"
#import "GRKAlbum.h"

enum {
    UCPhotosListStateInitial = 0,
    UCPhotosListStateConnecting,
    UCPhotosListStateConnected,
    UCPhotosListStateGrabbing,
    UCPhotosListStatePhotosGrabbed,
    UCPhotosListStateAllPhotosGrabbed,
    UCPhotosListStateError = 99
};
typedef NSUInteger UCPhotosListState;

@interface UCPhotosList : UITableViewController {
    GRKServiceGrabber *_grabber;
    GRKAlbum *_album;
    UCPhotosListState state;
    
    NSUInteger _lastLoadedPageIndex;
    NSUInteger _nextPageIndexToLoad;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGrabber:(GRKServiceGrabber*)grabber andAlbum:(GRKAlbum*)album;

@end
