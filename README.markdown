# Uploadcare for iOS

## What it is

**Uploadcare** is a one-stop service for dealing with files on the web. You should probably visit [the site](http://uploadcare.com).

**Uploadcare for iOS** is an open source Objective-C library that brings Uploadcare features to your iOS apps.

**Uploadcare Widget**, a major component of Uploadcare for iOS, is what a modern, cloud-aware file picker for iOS would be, if iOS had a notion of files. Since iOS doesn't, you can think of Uploadcare Widget as a *thing* picker – a drop-in component, that allows your users to select and upload their *things* (photos, documents, whatever you want them to) to your service, via Uploadcare.

Here's what it looks like:

![Uploadcare for iOS menu](https://ucarecdn.com/a51ee0de-b775-40fb-98e3-81f683938431/-/stretch/off/-/resize/250x/) ![Facebook albums](https://ucarecdn.com/81da28a4-1522-4b44-8d03-8eea18b94dd4/-/stretch/off/-/resize/250x/)
![Instagram gallery](https://ucarecdn.com/2405cae1-e653-424f-af21-c244dda2d77f/-/stretch/off/-/resize/250x/)

## Quickstart

### Installation

Uploadcare for iOS uses [CocoaPods](http://cocoapods.org), a library dependency management tool for Objective-C projects. To install Uploadcare for iOS in your project, just add the following line to your [Podfile](https://github.com/CocoaPods/CocoaPods/wiki/A-Podfile):

```ruby
pod 'Uploadcare'
```

Then, run `pod install` in your project directory.

Make sure to use the `.xcworkspace` file from now on.

### Widget quick install guide
#### Setup environment

Import `Uploadcare.h` header to your implementation.
Set up uploadcare public key as following in your application delegate:
```objc
#import <Uploadcare/Uploadcare.h>

/* ... */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UCClient defaultClient] setPublicKey:<#your key#>];
    return YES;
}
```

#### Set up iCloud entitlements
Uploadcare widget uses `UIDocumentMenuViewController`, so you need to enable iCloud in your application. 
Go to **Target** -> **Capabilities** and enable iCloud. Set both `Key-value storage` and `iCloud Documents` options enabled:
![iCloud settings](https://ucarecdn.com/738d9b6f-517d-417c-b048-d0d08a411e80/)

#### Set up custom url scheme
Uploadcare widget uses `SFSafariViewController` on IOS 9 and `UIWebView` on prior versions
for authentification. In this case it should handle url callbacks through custom url
scheme from application delegate methods:

```objc
// IOS 9
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [[UCClient defaultClient] handleURL:url];
}

// IOS 8
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[UCClient defaultClient] handleURL:url];
}
```
In order to add custom url scheme, perform the following steps:
* Go to **Target** -> **Info** -> **URL types**
* Add new url scheme with the following format: uploadcare\<public key\>
* The final result should look similar to this:

![Custom url scheme](https://ucarecdn.com/1738621a-8016-44c4-918d-d90f8e23336f/)

#### Init and present widget

To display the Uploadcare Widget, you must create and initialize an instance of [`UCMenuViewController`](https://github.com/uploadcare/uploadcare-ios/blob/core-refactoring/UploadcareWidget/UCMenuViewController.h) by invoking `initWithProgress:completion:` method:

```objc
#import <Uploadcare/Uploadcare.h>

/* ... */

UCMenuViewController *menu = [[UCMenuViewController alloc] initWithProgress:^(NSUInteger bytesSent, NSUInteger bytesExpectedToSend) {
    // handle progress here
} completion:^(NSString *fileId, NSError *error) {
    if (!error) {
        // handle success
    } else {
        // handle error
    }
}];
    
    
```

Then, present it with `presentFrom:` method:

```objc
[menu presentFrom:self];
```

### Customization

You can easily customize your social networks list apperance by implementing your own menu.
In order to receive available social sources, you can use `fetchSocialSourcesWithCompletion:` method from
`UCSocialManager`.
After you receive a list of social sources, you can choose one and use it for instantiating
`UCGalleryVC` with the following method:
```objc
- (id)initWithMode:(UCGalleryMode)mode
            source:(UCSocialSource *)source
         rootChunk:(UCSocialChunk *)rootChunk
          progress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progress
        completion:(void(^)(NSString *fileId, NSError *error))completion;
```

## Sample App

Please take a look at the [Example Project](https://github.com/uploadcare/uploadcare-ios/tree/core-refactoring/Examples/ExampleProject). 

## Contact

If you have any questions, bug reports or suggestions, [drop us a line](hello@uploadcare.com).

## License 

Uploadcare iOS is licensed under the MIT license (see `LICENSE`).
