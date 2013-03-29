## Introduction

The TestFlight SDK allows you to track how beta testers are testing your application. Out of the box we track simple usage information, such as which tester is using your application, their device model/OS, how long they used the application, and automatic recording of any crashes they encounter.

To get the most out of the SDK we have provided the Checkpoint API. The Checkpoint API is used to help you track exactly how your testers are using your application. Curious about which users passed level 5 in your game, or posted their high score to Twitter, or found that obscure feature? With a single line of code you can finally gather all this information.

For more detailed debugging we have a remote logging solution. Find out more about our logging system with TFLog in the Remote Logging section.

Wondering how many times your app has crashed? We've got you covered. All crashes are reported to the TestFlight website with stack traces, checkpoints the user passed, and remote logs.


## Requirements

The TestFlight SDK requires iOS 4.0 or above and the libz library to run.

                
## Integration

1. Add the files to your project: File -> Add Files to " "
    1. Find and select the folder that contains the SDK
    2. Make sure that "Copy items into destination folder (if needed)" is checked
    3. Set Folders to "Create groups for any added folders"
    4. Select all targets that you want to add the SDK to
    
2. Verify that libTestFlight.a has been added to the Link Binary With Libraries Build Phase for the targets you want to use the SDK with     
    1. Select your Project in the Project Navigator
    2. Select the target you want to enable the SDK for
    3. Select the Build Phases tab
    4. Open the Link Binary With Libraries Phase
    5. If libTestFlight.a is not listed, drag and drop the library from your Project Navigator to the Link Binary With Libraries area
    6. Repeat Steps 2 - 5 until all targets you want to use the SDK with have the SDK linked
    
3. Add libz to your Link Binary With Libraries Build Phase
    1. Select your Project in the Project Navigator
    2. Select the target you want to enable the SDK for
    3. Select the Build Phases tab
    4. Open the Link Binary With Libraries Phase
    5. Click the + to add a new library
    6. Find libz.dylib in the list and add it
    7. Repeat Steps 2 - 6 until all targets you want to use the SDK with have libz.dylib
    
4. Get your App Token

    1. If this is a new application, and you have not uploaded it to TestFlight before, first register it here: [https://testflightapp.com/dashboard/applications/create/]().

    2. Go to your list of applications ([http://testflightapp.com/dashboard/applications/]()), click on the application you are using from the list, click on the "App Token" tab on the left. The App Token for that application will be there.
    
5. In your Application Delegate:

    1. Import TestFlight: `#import "TestFlight.h"`
    
    2. Launch TestFlight with your App Token
    
        In your `-application:didFinishLaunchingWithOptions:` method, call `+[TestFlight takeOff:]` with your App Token.
    
        **NOTE:** While beta testing (and **ONLY** while beta testing), place the call to `+[TestFlight setDeviceIdentifier:]` so that your testers do not show up as anonymous on TestFlight's website.

            -(BOOL)application:(UIApplication *)application 
                didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
            // start of your application:didFinishLaunchingWithOptions 

            // !!!: Use the next line only during beta
            // This is illegal to call in production app store apps
            // [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
            
            [TestFlight takeOff:@"Insert your Application Token here"];
            // The rest of your application:didFinishLaunchingWithOptions method
            // ...
            }

    3. To report crashes to you we install our own uncaught exception handler. If you are not currently using an exception handler of your own then all you need to do is go to the next step. If you currently use an Exception Handler, or you use another framework that does please go to the section on advanced exception handling.


## Beta Testing and Release Differentiation

In order to provide more information about your testers while beta testing you will need to provide the device's unique identifier. This identifier is not something that the SDK will collect from the device and we do not recommend using this in production. To send the device identifier to us put the following code **before your call to** `+[TestFlight takeOff:]`.

    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"Insert your Application Token here"];

This will allow you to have the best possible information during testing. **When it is time to submit to the App Store comment this line out**. Apple may reject your app if you leave this line in. If you decide to not include the device's unique identifier during your testing phase TestFlight will still collect all of the information that you send but it will be anonymized.


## Uploading your build
    
After you have integrated the SDK into your application you need to upload your build to TestFlight. You can upload your build on our [website](https://testflightapp.com/dashboard/builds/add/), using our [desktop app](https://testflightapp.com/desktop/), or by using our [upload API](https://testflightapp.com/api/doc/).


## Optional APIs
    
### Checkpoint API

When a tester does something you care about in your app you can pass a checkpoint. For example completing a level, adding a todo item, etc. The checkpoint progress is used to provide insight into how your testers are testing your apps. The passed checkpoints are also attached to crashes, which can help when creating steps to replicate.

    [TestFlight passCheckpoint:@"CHECKPOINT_NAME"];

Use `passCheckpoint:` to track when a user performs certain tasks in your application. This can be useful for making sure testers are hitting all parts of your application, as well as tracking which testers are being thorough.

Checkpoints are meant to tell you if a user visited a place in your app or completed a task. They should not be used for debugging purposes. Instead, use Remote Logging for debugging information (more information below).


### Feedback API

In **beta** builds you may get feedback from the user and send it to TestFlight using this method:

    [TestFlight submitFeedback:feedback];

Once users have submitted feedback from inside of the application you can view it in the feedback area of your build page.


### Remote Logging
       
To perform remote logging you can use the TFLog method which logs in a few different methods described below. In order to make the transition from NSLog to TFLog easy we have used the same method signature for TFLog as NSLog. You can easily switch over to TFLog by adding the following macro to your header

    #define NSLog TFLog

That will do a switch from NSLog to TFLog, if you want more information, such as file name and line number you can use a macro like

    #define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

Which will produce output that looks like

    -[HTFCheckpointsController showYesNoQuestion:] [Line 45] Pressed YES/NO

We have implemented three different loggers.

    1. TestFlight logger
    2. Apple System Log logger
    3. STDERR logger

The TestFlight logger writes its data to a file which is then sent to our servers on Session End events. The Apple System Logger sends its messages to the Apple System Log and are viewable using the Organizer in Xcode when the device is attached to your computer. The ASL logger can be disabled by turning it off in your TestFlight options

    [TestFlight setOptions:{ TFOptionLogToConsole : @NO }];

The default option is YES.

The STDERR logger sends log messages to STDERR so that you can see your log statements while debugging. The STDERR logger is only active when a debugger is attached to your application. If you do not wish to use the STDERR logger you can disable it by turning it off in your TestFlight options

    [TestFlight setOptions:{ TFOptionLogToSTDERR : @NO }];

The default option is YES.

## Advanced Notes

### Checkpoint API

When passing a checkpoint, TestFlight logs the checkpoint synchronously (See Remote Logging for more information). If your app has very high performance needs, you can turn the logging off with the `TFOptionLogOnCheckpoint` option.


### Remote Logging

All logging is done synchronously. Every time the SDK logs, it must write data to a file. This is to ensure log integrity at crash time. Without this, we could not trust logs at crash time. If you have a high performance app, please email support@testflightapp.com for more options.


### Advanced Exception Handling

An uncaught exception means that your application is in an unknown state and there is not much that you can do but try and exit gracefully. Our SDK does its best to get the data we collect in this situation to you while it is crashing, but it is designed in such a way that the important act of saving the data occurs in as safe way a way as possible before trying to send anything. If you do use uncaught exception or signal handlers install your handlers before calling `takeOff`. Our SDK will then call your handler while ours is running. For example:

      /*
       My Apps Custom uncaught exception catcher, we do special stuff here, and TestFlight takes care of the rest
      */
      void HandleExceptions(NSException *exception) {
        NSLog(@"This is where we save the application data during a exception");
        // Save application data on crash
      }
      /*
       My Apps Custom signal catcher, we do special stuff here, and TestFlight takes care of the rest
      */
      void SignalHandler(int sig) {
        NSLog(@"This is where we save the application data during a signal");
        // Save application data on crash
      }

      -(BOOL)application:(UIApplication *)application 
      didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
        // installs HandleExceptions as the Uncaught Exception Handler
        NSSetUncaughtExceptionHandler(&HandleExceptions);
        // create the signal action structure 
        struct sigaction newSignalAction;
        // initialize the signal action structure
        memset(&newSignalAction, 0, sizeof(newSignalAction));
        // set SignalHandler as the handler in the signal action structure
        newSignalAction.sa_handler = &SignalHandler;
        // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
        sigaction(SIGABRT, &newSignalAction, NULL);
        sigaction(SIGILL, &newSignalAction, NULL);
        sigaction(SIGBUS, &newSignalAction, NULL);
        // Call takeOff after install your own unhandled exception and signal handlers
        [TestFlight takeOff:@"Insert your Application Token here"];
        // continue with your application initialization
      }

You do not need to add the above code if your application does not use exception handling already.

