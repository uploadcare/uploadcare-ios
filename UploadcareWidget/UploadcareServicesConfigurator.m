//
//  UploadcareServicesConfigurator.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/7/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadcareServicesConfigurator.h"

@implementation UploadcareServicesConfigurator

// Facebook - https://developers.facebook.com/apps

- (NSString *)facebookAppId {
	return @"442253875803433";
}

// Flickr - http://www.flickr.com/services/apps/create/apply/

- (NSString *)flickrApiKey {
    return @"640dd6a955dd11005c7ebe3b04f8aa72";
}

- (NSString *)flickrApiSecret {
    return @"562666552347ceaa";
}

- (NSString *)flickrRedirectUri{
    return @"uploadcareflickrtestapp://";
}

// Instragram - http://instagram.com/developer/clients/register/

- (NSString *)instagramAppId {
    return @"240acb84ad6d45fda3db9cf16ec48603";
}

- (NSString *)instagramRedirectUri {
    return @"uploadcareinstagramdemo://";
}

// Picasa - https://code.google.com/apis/console/

- (NSString *)picasaClientId {
    return @"781274321002.apps.googleusercontent.com";
}

- (NSString *)picasaClientSecret {
    return @"bmBVXblsxJO5X6WONXBatgRK";
}

- (NSString*) facebookTaggedPhotosAlbumName {
    return nil;
}


@end
