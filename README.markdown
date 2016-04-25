# Uploadcare for iOS

## What it is

**Uploadcare** is a one-stop service for dealing with files on the web. You should probably visit [the site](http://uploadcare.com).

**Uploadcare for iOS** is an open source Objective-C library that brings Uploadcare features to your iOS apps.

**Uploadcare Widget**, a major component of Uploadcare for iOS, is what a modern, cloud-aware file picker for iOS would be, if iOS had a notion of files. Since iOS doesn't, you can think of Uploadcare Widget as a *thing* picker – a drop-in component, that allows your users to select and upload their *things* (photos, documents, whatever you want them to) to your service, via Uploadcare.

Here's what it looks like:

![Uploadcare for iOS menu](https://ucarecdn.com/dcc15365-1cb7-4428-876d-be39b7d2b480/-/stretch/off/-/resize/210x/) ![Instagram gallery](https://ucarecdn.com/a9ff39d2-1eed-4e23-8005-d39751070c28/-/stretch/off/-/resize/210x/) ![Facebook album list with the drawer opened](https://ucarecdn.com/16a8a1d7-d346-4201-a507-8dd484f53398/-/stretch/off/-/resize/210x/) ![Google drive](https://ucarecdn.com/33b4c383-b53c-450a-a1eb-c18fd84e6ef1/-/stretch/off/-/resize/210x/)

## Quickstart

### Installation

Uploadcare for iOS uses [CocoaPods](http://cocoapods.org), a library dependency management tool for Objective-C projects. To install Uploadcare for iOS in your project, just add the following line to your [Podfile](https://github.com/CocoaPods/CocoaPods/wiki/A-Podfile):

```ruby
pod 'uploadcare-ios'
```

Then, run `pod install` in your project directory.

Make sure to use the `.xcworkspace` file from now on.

### Widget quick install guide
#### Setup environment

Import `UCClient+Social.h` header to your implementation.
Set up uploadcare public key as following in your application delegate:
```objc
#import "UCClient+Social.h"

/* ... */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UCClient defaultClient] setPublicKey:<#your key#>];
    return YES;
}
```

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
* Go to Target -> Info -> URL types
* Add new url scheme with the following format: uploadcare\<public key\>
* The final result should look similar to this:

[image here]

To display the Uploadcare Widget, you must create and initialize an instance of [`UCWidgetVC`](https://github.com/uploadcare/uploadcare-ios/blob/core-refactoring/UploadcareWidget/UCWidgetVC.h) by invoking `initWithProgress:completion:` method:

```objc
#import "UCMenuViewController.h"

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

Then, present it with `UIModalPresentationFormSheet` modalPresentationStyle:

```objc
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:menu];
    navc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navc animated:YES completion:nil];
```

## Sample App

Please take a look at the [Example Project](https://github.com/uploadcare/uploadcare-ios/tree/core-refactoring/Examples/ExampleProject). 

## Contact

If you have any questions, bug reports or suggestions, [drop us a line](hello@uploadcare.com).

## License 

Uploadcare iOS is licensed under the MIT license (see `LICENSE`).
