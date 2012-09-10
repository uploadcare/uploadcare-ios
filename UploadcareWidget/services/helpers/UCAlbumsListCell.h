//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "GRKAlbum.h"

@interface UCAlbumsListCell : UITableViewCell {
    GRKAlbum * _album;    
}

@property (nonatomic, strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic, strong) IBOutlet UILabel *labelAlbumName;
@property (nonatomic, strong) IBOutlet UILabel *labelPhotosCount;
@property (nonatomic, strong) IBOutlet UILabel *labelDateCreated;

-(void)setAlbum:(GRKAlbum*)_newAlbum ;

@end
