##UploadcareKit iOS SDK for [Uploadcare](http://uploadcare.com)

####Set Up the iOS SDK

We've made it easy to setup the UploadcareKit iOS SDK for Xcode by including an example app that you can use as a template. Before you can get started, go to [Uploadcare Sign Up](http://uploadcare.com/accounts/create/) and register your new app. After registration you'll get public and secret keys that allow you to connect to Uploadcare API.

####Build and run the example app
The example project that included in the SDK contains all you need to understand basics of usage. The project is called SimpleExample and contains an example of how to upload file from your local storage, upload from URL, retrieve list of files from Uploadcare API, keep files, delete it and get file info.

Just open UploadcareKit.xcworkspace and select SimpleExample from build targets. Find ViewController.m in SimpleExample project, then goto viewDidLoad method and fill in the values for publicKey and secretKey with your app's key and secret.

``` objective-c
- (void)viewDidLoad
{
    // init UploadcareKit with public and secret
    [[UploadcareKit shared] setPublicKey:@"your_public_key"
                               andSecret:@"your_secret_key"];
    
    [super viewDidLoad];
}
```
Now you can build and run the example. Once running, make sure you can start the app and make request without getting errors. If Uploadcare API doesn't understand your keys you'll see warning in Debug Area:

```` shell
Warning! You must specify public key and secret key! All you need to know you can find in documentation.
```

Once you've successfully can make a requests, you can investigate app with abilities to upload files, getting list of local history, retrieve file list from Uploadcare API, delete of keep files. So, just have fun, but do not forget to check out the source code of SimpleExample. It's really simple. You'll see.

####Adding the Uploadcare SDK for iOS to your project
Now, when we know that the Uploadcare SDK is working, you can add it to your own project. Just a few simple steps:

- open your project in Xcode;
- navigate to where you clone the SDK, goto UploadcareKit folder and drag the UploadcareKit.xcodeproj into your project in Xcode;
- you can select Copy items into destination group's folder or not, as you want (if not, you can just update UploadcareKit SDK from Github and have fresh version in very easy way);
- press Add button
- add UploadcareKit.a file to project dependencies. To do this in Xcode 4, select your project file in the file explorer, select your target, and select the Build Phases sub-tab. Under Link Binary with Libraries, press the + button, select libUploadcareKit.a, and press Add.

## Example Usage

### Upload file from NSData

For upload file from your local storage just specify NSData object and blocks you want to control (optional).  
As you can see from example below, Uploadcare SDK will notify you about upload progress, success or failure.

``` objective-c
[[UploadcareKit shared] uploadFileWithName:@"test_name" 
								   andData:[NSData ...] 
					   uploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {

		NSLog(@"uploaded %lld : %lld : %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);

    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UploadcareFile *file) {
        
		NSLog(@"success -> %@", response);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		NSLog(@"failure -> %@\n%@", response, error);
        
    }];
```

### Upload file from Web

For upload file from Url or Web you can use very same method as for NSData, just specify Url of file and fill blocks you want to control (optional).  

``` objective-c
[[UploadcareKit shared] uploadFileWithURL:[URL as NSString] 
								  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UploadcareFile *file) {
        
		NSLog(@"success -> %@", response);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
		NSLog(@"failure -> %@\n%@", response, error);
        
    }];
```

### Keep file

By default, Uploadcare API doesn't keep your file for a while and delete it after some time. So, if you want to keep your file forever just use keep function on early uploaded data. To keep you must store instances of UploadcareFile from previous uploads or retrieve it from Uploadcare API again.

``` objective-c
[UploadcareKit shared] keep:YES forFile:[UploadcareFile ...]
                    success:^(NSHTTPURLResponse *response, id JSON, UploadcareFile *file) {
                         
                         	 NSLog(@"file keep");
                         	 
                         }
                 andFailure:^(NSHTTPURLResponse *response, NSError *error) {
                      
                         	 NSLog(@"!failure -> %@\n%@", response, error);
                         	 
                      }];

```

### Delete file

If you want to remove file from your account for some reason, just delete. We will not disturb you.

``` objective-c
[[UploadcareKit shared] deleteFile:[UploadcareFile instance]
                           success:^(NSHTTPURLResponse *response) {
                               
                           		NSLog(@"success deleted");

                      } andFailure:^(NSHTTPURLResponse *response, NSError *error) {

                         	    NSLog(@"!failure -> %@\n%@", response, error);

                 }];
```

### Get file info

You can store only file_id to retrieve all additional info about it, see how:

``` objective-c
[[UploadcareKit shared] requestFile:file_id 
						withSuccess:^(NSHTTPURLResponse *response, id JSON, UploadcareFile *file) {
						
		NSLog(@"success -> %@", [file file_id]);
		
    } andFailure:^(id responseObject, NSError *error) {
    
		NSLog(@"!failure -> %@\n%@", response, error);
		
    }];
```

### Get file list

If you want, you can get the file list of all uploaded files from your account. Just do this:

``` objective-c
[[UploadcareKit shared] requestFileListWithSuccess:^(NSHTTPURLResponse *response, id JSON, NSArray *files) {

			NSLog(@"success -> %@", JSON);
			
        } andFailure:^(id responseObject, NSError *error) {
        
            NSLog(@"!failure -> %@\n%@", response, error);
            
        }];
```

##In conclusion

Now that you've seen how to perform all the basic operations, you're ready to start building your app. More pragmatic information about SDK methods you can learn from Reference Documentation.

## Requirements

UploadcareKit for iOS requires either iOS 4.3 and above. Project compatible with Xcode 4.3 and above. 

UploadcareKit uses:

* [AFNetworking](http://github.com/AFNetworking/AFNetworking/)
* [JSONKit](https://github.com/johnezang/JSONKit)

### ARC Support and Static Library

UploadcareKit use ARC feature. So, if you want to use it with non-ARC project or just want to use as static library, you can do it.   
Navigate to #LIBRARY_DIR/UploadcareKit and you'll see build_uploadcarekit_ios_sdk_static_lib.sh script. Open your favourite terminal, goto #PROJECT_DIR/UploadcareKit and run ./build_uploadcarekit_ios_sdk_static_lib.sh, you'll see build log with some output:

```` Shell
** BUILD SUCCEEDED **

Step 2 : Remove older SDK Directory
Step 3 : Create new SDK Directory Version
Step 4 : Create combine lib files for various platforms into one
Step 5 : Copy headers Needed
Finished Universal SDK Generation

You can now use the static library that can be found at:

#LIBRARY_DIR/UploadcareKit/lib/uploadcarekit-ios-sdk

Just drag the uploadcarekit-ios-sdk directory into your project to include the UploadcareKit iOS SDK static library
```

Once more: Just drag the uploadcarekit-ios-sdk directory into your project to include the UploadcareKit iOS SDK static library. That all you need to do.

That's all folks!