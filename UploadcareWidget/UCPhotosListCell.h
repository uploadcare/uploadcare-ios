//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UCPhotosList.h"

@interface UCPhotosListCell : UITableViewCell {
    NSArray * _photos;
    
    __strong IBOutlet UIImageView *photoThumbnail0;
    __strong IBOutlet UIImageView *photoThumbnail1;
    __strong IBOutlet UIImageView *photoThumbnail2;
    __strong IBOutlet UIImageView *photoThumbnail3;
}

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) UCPhotosList *photoList;
@property (nonatomic, strong) NSString *serviceName;

- (void)updateThumbnails;

@end
