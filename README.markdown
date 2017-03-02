# Uploadcare for iOS

[![Build Status](https://travis-ci.org/uploadcare/uploadcare-ios.svg?branch=master)](https://travis-ci.org/uploadcare/uploadcare-ios)
[![Pod Version](https://img.shields.io/cocoapods/v/Uploadcare.svg)](http://cocoadocs.org/docsets/Uploadcare)
[![Pod Platform](https://img.shields.io/cocoapods/p/Uploadcare.svg)](http://cocoadocs.org/docsets/Uploadcare)
[![Pod License](http://img.shields.io/cocoapods/l/Uploadcare.svg)](https://github.com/uploadcare/uploadcare-ios/blob/master/LICENSE)


[Uploadcare](https://uploadcare.com) is a
[PaaS](https://en.wikipedia.org/wiki/Platform_as_a_service)
providing file handling mechanisms for websites and apps.
This also includes on-the-fly image processing
with Uploadcare [CDN API](https://uploadcare.com/documentation/cdn/).

**Uploadcare for iOS** is an open source Objective-C component that
powers your iOS apps with Uploadcare features.
It's made up of the two key parts: **UploadcareKit** and **Uploadcare Widget**.

**UploadcareKit** is a core-level abstract layer responsible
for API communications within upload and download tasks.

**Uploadcare Widget** is a modern and cloud-aware file picker for iOS.
Well, it could be if iOS had a notion of files. Since it doesn't, you
can think of [Uploadcare Widget](https://uploadcare.com/documentation/widget/)
as a *stuff* picker — a drop-in component that allows your users to pick
and upload their digital *stuff* (photos, docs, and whatnot) to your website
or app.

Here's what it looks like,

![Uploadcare for iOS menu](https://ucarecdn.com/6fd1868d-6cda-4282-b932-683fd1c0b837/-/stretch/off/-/resize/250x/) ![Facebook albums](https://ucarecdn.com/81da28a4-1522-4b44-8d03-8eea18b94dd4/-/stretch/off/-/resize/250x/)
![Instagram gallery](https://ucarecdn.com/2405cae1-e653-424f-af21-c244dda2d77f/-/stretch/off/-/resize/250x/)

## Quickstart

### Install

Uploadcare for iOS uses [CocoaPods](http://cocoapods.org),
a library dependency management tool for Objective-C projects.
Implementing Uploadcare into your project is as simple as adding
the following line to your
[Podfile](https://github.com/CocoaPods/CocoaPods/wiki/A-Podfile),

```ruby
pod 'Uploadcare'
```

Then, run `pod install` in your project directory.

Make sure to use the `.xcworkspace` file from now on.

### Setup
#### Environment

Import `Uploadcare.h` header to your implementation.
[Grab](http://kb.uploadcare.com/article/234-uc-project-and-account)
your Uploadcare API keys and use a public key
as follows in your application delegate,

```objc
#import <Uploadcare/Uploadcare.h>

/* ... */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UCClient defaultClient] setPublicKey:<#your key#>];
    return YES;
}
```

#### iCloud entitlements
Uploadcare Widget uses `UIDocumentMenuViewController`,
so you need to enable iCloud in your application. 
Go to **Target** -> **Capabilities** and enable iCloud.
Enable both `Key-value storage` and `iCloud Documents` options,
![iCloud settings](https://ucarecdn.com/738d9b6f-517d-417c-b048-d0d08a411e80/)

#### Custom URL scheme
Uploadcare Widget uses `SFSafariViewController` on iOS 9+ and
`UIWebView` on prior versions for authentification.
This allows it to handle URL callbacks through a custom URL
scheme from application delegate methods,

```objc
// IOS 9+
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [[UCClient defaultClient] handleURL:url];
}

// IOS 8
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[UCClient defaultClient] handleURL:url];
}
```
Adding a custom URL scheme requires taking the following steps:

* Go to **Target** -> **Info** -> **URL types**.
* Add a new URL scheme formatted like this, uc-\<public key\>.
* The final result should look similar to this,

![Custom url scheme](https://ucarecdn.com/7426b014-7888-49dc-a44d-3c8655567796/)

#### `NSPhotoLibraryUsageDescription` on iOS 10
Uploadcare Widget uses `UIImagePickerController` to upload files
from Camera Roll. Don't forget to add `NSPhotoLibraryUsageDescription`
key to your project `Info.plist` file to prevent an app from crashing
in runtime.

### Show
#### Init and present widget

Displaying Uploadcare Widget is done via creating and initializing
an instance of 
[`UCMenuViewController`](https://github.com/uploadcare/uploadcare-ios/UploadcareWidget/UCMenuViewController.h)
by invoking the `initWithProgress:completion:` method,

```objc
#import <Uploadcare/Uploadcare.h>

/* ... */

UCMenuViewController *menu = [[UCMenuViewController alloc] initWithProgress:^(NSUInteger bytesSent, NSUInteger bytesExpectedToSend) {
    // handle progress here
} completion:^(NSString *fileId, id response, NSError *error) {
    if (!error) {
        // handle success
    } else {
        // handle error
    }
}];
```

Then, present it with the `presentFrom:` method,

```objc
[menu presentFrom:self];
```

### Customization

You can easily customize the appearance of a social sources list
by implementing your own menu.
In order to receive available social sources, you can use the
`fetchSocialSourcesWithCompletion:` method from `UCSocialManager`.
Upon receiving a list of social sources,
you can choose one and use it for instantiating
`UCGalleryVC` via the following method,

```objc
- (id)initWithSource:(UCSocialSource *)source
           rootChunk:(UCSocialChunk *)rootChunk
            progress:(UCProgressBlock)progress
          completion:(UCWidgetCompletionBlock)completion;
```

### Core level features only

In order to integrate core level features only such as local
and remote file upload operations, you can use the following subspec:

```ruby
pod 'Uploadcare/Core'
```

Please note, `Uploadcare.h` header won't be included in this case,
and you'll have to use `UploadcareKit.h` instead.

## Sample App

Here's the [Example Project](https://github.com/uploadcare/uploadcare-ios/tree/master/Example). 

## Contact

If you got any questions, bug reports or suggestions —
[drop us a line](mailto:hello@uploadcare.com).

## Contributors

- [@zrxq](https://github.com/zrxq)
- [@ynechaev](https://github.com/ynechaev)
- [@dive](https://github.com/dive)
- [@rusik](https://github.com/rusik)
- [@dmitry-mukhin](https://github.com/dmitry-mukhin)
- [@markbao](https://github.com/markbao)
- [@homm](https://github.com/homm)

## Security issues

If you think you ran into something in Uploadcare libraries
which might have security implications, please hit us up at
[bugbounty@uploadcare.com](mailto:bugbounty@uploadcare.com)
or Hackerone.

We'll contact you personally in a short time to fix an issue
through co-op and prior to any public disclosure.

## License 

Uploadcare iOS is licensed under the MIT license (see `LICENSE`).
