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

### Use

To display the Uploadcare Widget, you must create and initialize an instance of [`UPCUploadController`](https://github.com/uploadcare/uploadcare-ios/blob/master/UploadcareWidget/UPCUploadController.h) by invoking `initWithUploadcarePublicKey:` method, using your Uploadcare [public key](https://uploadcare.com/accounts/settings/) as the argument:

```objc
#import <UPCUploadController.h>

/* ... */

UPCUploadController *uploadController = [[UPCUploadController alloc]initWithUploadcarePublicKey:@"demopublickey"]; // <-- replace with your actual public key
```

Then, present it like you would present any other `UIViewController` subclass:

```objc
[myController presentViewController:uploadController animated:YES completion:nil];
```

### Delegate object

`UPCUploadController` delivers the results of user interaction to a delegate object that should be set using it's `uploadDelegate` property (not to be confused with `delegate` property). The delegate is expected to conform to [UPCUploadDelegate](https://github.com/uploadcare/uploadcare-ios/blob/master/UploadcareWidget/UPCUploadDelegate.h) formal protocol. Implement it's optional methods to get notified when an upload starts, continues, finishes, or fails, the user dismisses the controller and so on.


## Appearance

`UPCUploadController` is compatible with [`UIAppearance` protocol](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIAppearance_Protocol/Reference/Reference.html).

## iPad

`UPCUploadController` expects it will be presented in a [`UIPopoverController`](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIPopoverController_class/Reference/Reference.html) on iPad. You need to pass the presenting popover controller object to `UPCUploadController`'s `popover` property.

## Sample App

Please take a look at [uShare app](https://github.com/uploadcare/uploadcare-ios/tree/master/Examples/ushare). 

## Contact

If you have any questions, bug reports or suggestions, [drop us a line](hello@uploadcare.com).

## License 

Uploadcare iOS is licensed under the MIT license (see `LICENSE`).
