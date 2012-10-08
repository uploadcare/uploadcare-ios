//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadcareWidget.h"

#import "UploadcareKit.h"
#import "UCAlbumsList.h"

#import "GRKConfiguration.h"

#import "GRKPicasaGrabber.h"
#import "GRKFacebookGrabber.h"
#import "GRKFlickrGrabber.h"
#import "GRKInstagramGrabber.h"

#import "GRKPhoto.h"
#import "GRKImage.h"

#import "UploadedViewController.h"
#import "UploadCareProgressView.h"

#import "JSNotifier.h"

#define SECTION_URL         0
#define SECTION_LOCAL       1
#define SECTION_SERVICES    2
#define SECTION_UPLOADS     3

#define SECTION_SERVICES_FACEBOOK   0
#define SECTION_SERVICES_FLICKR     1
#define SECTION_SERVICES_INSTAGRAM  2
#define SECTION_SERVICES_PICASA     3
#define SECTION_SERVICES_URL        4

#define SECTION_SERVICES_CAMERA     0
#define SECTION_SERVICES_LIBRARY    1

#define FACEBOOK_GRABBER @"GRKFacebookGrabber"
#define FLICKR_GRABBER @"GRKFlickrGrabber"
#define INSTAGRAM_GRABBER @"GRKInstagramGrabber"
#define PICASA_GRABBER @"GRKPicasaGrabber"

#define UNKNOWN_PHOTO_SOURCE @"Unknown"

#define UPLOAD_FROM_URL_DIALOG_TAG 99

@interface UploadcareWidget () {
    NSMutableDictionary *dataSource;
    IBOutlet UITableView *tableview;
    
    UploadCareProgressView *progressView;
}

@end

@implementation UploadcareWidget

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Uploadcare", nil);
        
        dataSource = [[NSMutableDictionary alloc] init];
        
        NSString *pasteboard = [UIPasteboard generalPasteboard].string;
        if (pasteboard) {
            NSURL *url = [NSURL URLWithString:pasteboard];
            if (url && url.scheme && url.host) {
                NSLog(@"+%@: line %d: found URL in pasteboard - '%@'", NSStringFromSelector(_cmd), __LINE__, pasteboard);
                
                [dataSource setObject:[[NSMutableArray alloc] initWithObjects:
                                       pasteboard,
                                       nil]
                               forKey:[NSNumber numberWithInt:SECTION_URL]];
            } else {
                [dataSource setObject:[[NSMutableArray alloc] init]
                               forKey:[NSNumber numberWithInt:SECTION_URL]];
            }
        } else {
            [dataSource setObject:[[NSMutableArray alloc] init]
                           forKey:[NSNumber numberWithInt:SECTION_URL]];
        }
        
        [dataSource setObject:[[NSMutableArray alloc] initWithObjects:
                               NSLocalizedString(@"Camera", nil),
                               NSLocalizedString(@"Library", nil),
                               nil]
                       forKey:[NSNumber numberWithInt:SECTION_LOCAL]];
        
        [dataSource setObject:[[NSMutableArray alloc] initWithObjects:
                               NSLocalizedString(@"Facebook", nil),
                               NSLocalizedString(@"Flickr", nil),
                               NSLocalizedString(@"Instagram", nil),
                               NSLocalizedString(@"Picasa", nil),
//                               NSLocalizedString(@"From URL", nil),
                               nil]
                       forKey:[NSNumber numberWithInt:SECTION_SERVICES]];
        
        [dataSource setObject:[[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"Previous uploads", nil), nil]
                       forKey:[NSNumber numberWithInt:SECTION_UPLOADS]];
        
        progressView = [[UploadCareProgressView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 25.0f, 25.0f)];
        progressView.progress = .0f;
        
        [GRKConfiguration initializeWithConfiguratorClassName:@"UploadcareServicesConfigurator"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init UploadcareKit with public and secret
    [[UploadcareKit shared] setPublicKey:@"cfd09d941305970e0f7d"
                               andSecret:@"8fcfea19f6044dfdc476"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadFromImage:)
                                                 name:UPLOADCARE_NEW_IMAGE_NOTIFICATION
                                               object:nil];
            
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(dismiss:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:progressView];

    [self.navigationController.navigationBar setTintColor:[UIColor lightGrayColor]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (void)uploadFromImage:(NSNotification *)image {
    NSLog(@"+%@: line %d : %@", NSStringFromSelector(_cmd), __LINE__, [image.object class]);
    NSDictionary *object = image.object;
    
    /* use grabber-provided photo name if available, fallback to id, then to random UUID */
    
    NSString *photoNameBase = nil; // extentionless
    if (object[@"photoName"] != [NSNull null]) {
        photoNameBase = object[@"photoName"];
    } else {
        // fall back to photoId
        if (object[@"photoId"] != [NSNull null]) {
            photoNameBase = object[@"photoId"];
        } else {
            // no name, no id, generate a random name
            CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
            photoNameBase = (__bridge NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuid);
            CFRelease(uuid);
        }
    }
    NSString *photoName = [NSString stringWithFormat:@"%@.png", photoNameBase];

    /* charlie foxtrot prevention initiative */
    if (object[@"image"] == [NSNull null]) return; //TODO: Handle?
    
    /* upload */
    [self uploadFromFile:UIImagePNGRepresentation(object[@"image"])
                withName:photoName
             serviceName:object[@"serviceName"] != [NSNull null] ? object[@"serviceName"] : UNKNOWN_PHOTO_SOURCE];
}

- (IBAction)dismiss:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)uploadFileFromPhotoLibrary:(id)sender {
    [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)uploadFromUrl:(id)sender {
    UIAlertView *uploadFromUrlDialog = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please enter URL:", nil)
                                                                  message:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                        otherButtonTitles:NSLocalizedString(@"Upload", nil), nil];
    [uploadFromUrlDialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [uploadFromUrlDialog setTag:UPLOAD_FROM_URL_DIALOG_TAG];
    [uploadFromUrlDialog show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == UPLOAD_FROM_URL_DIALOG_TAG) {
        if (buttonIndex == 1) {
            [self uploadFromURL:[[alertView textFieldAtIndex:0] text]];
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dataSource objectForKey:[NSNumber numberWithInt:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {        
        switch ([indexPath section]) {
            case SECTION_URL: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textAlignment = UITextAlignmentLeft;
                cell.textLabel.font = [UIFont systemFontOfSize:12.f];
                cell.imageView.image = [UIImage imageNamed:@"icon_url"];
                break;
            }
            case SECTION_LOCAL: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                break;
            }
            case SECTION_SERVICES: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.textAlignment = UITextAlignmentLeft;
                switch ([indexPath row]) {
                    case SECTION_SERVICES_FACEBOOK:
                        cell.imageView.image = [UIImage imageNamed:@"icon_facebook"];
                        break;
                    case SECTION_SERVICES_FLICKR:
                        cell.imageView.image = [UIImage imageNamed:@"icon_flickr"];
                        break;
                    case SECTION_SERVICES_INSTAGRAM:
                        cell.imageView.image = [UIImage imageNamed:@"icon_instagram"];
                        break;
                    case SECTION_SERVICES_PICASA:
                        cell.imageView.image = [UIImage imageNamed:@"icon_picasa"];
                        break;
                    case SECTION_SERVICES_URL:
                        cell.imageView.image = [UIImage imageNamed:@"icon_url"];
                        break;
                        
                    default:
                        break;
                }
                break;
            }
            case SECTION_UPLOADS: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor grayColor];
                break;
            }
                
            default:
                DLog(@"Warning! UITableView section can not be recognized.")
                break;
        }
    }
    
    UIView *selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:212. / 256. green:187. / 256. blue:45. / 256. alpha:1.f]];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    cell.textLabel.text = [[dataSource objectForKey:[NSNumber numberWithInt:[indexPath section]]] objectAtIndex:[indexPath row]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case SECTION_URL: {
            if ([[dataSource objectForKey:[NSNumber numberWithInt:SECTION_URL]] count] > 0) {
                return NSLocalizedString(@"We've noticed something in clipboard.", nil);
            }
            return nil;
        }
        case SECTION_LOCAL: {
            return nil;
        }
        case SECTION_SERVICES: {
            return NSLocalizedString(@"Upload file from any sources listed above.", nil);
        }
        case SECTION_UPLOADS: {
            return NSLocalizedString(@"Powered by Uploadcare.com", nil);
        }
            
        default:
            DLog(@"Warning! UITableView section can not be recognized.")
            return nil;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([indexPath section]) {
        case SECTION_URL: {
            [self uploadFromURL:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            break;
        }
        case SECTION_LOCAL: {
            switch ([indexPath row]) {
                case SECTION_SERVICES_CAMERA:
                    [self startMediaBrowserFromViewController:self withSourceType:UIImagePickerControllerCameraCaptureModeVideo usingDelegate:self];
                    break;
                case SECTION_SERVICES_LIBRARY:
                    [self uploadFileFromPhotoLibrary:self];
                    break;
            }
            break;
        }
        case SECTION_SERVICES: {
            if ([indexPath row] == SECTION_SERVICES_FACEBOOK) {
                GRKFacebookGrabber *grabber = [[GRKFacebookGrabber alloc] init];
                UCAlbumsList *albumsList = [[UCAlbumsList alloc] initWithGrabber:grabber
                                                                             andServiceName:[[dataSource objectForKey:[NSNumber numberWithInt:[indexPath section]]] objectAtIndex:[indexPath row]]];
                [self.navigationController pushViewController:albumsList animated:YES];
                
            } else if ([indexPath row] == SECTION_SERVICES_FLICKR) {
                GRKFlickrGrabber *grabber = [[GRKFlickrGrabber alloc] init];
                UCAlbumsList *albumsList = [[UCAlbumsList alloc] initWithGrabber:grabber
                                                                  andServiceName:[[dataSource objectForKey:[NSNumber numberWithInt:[indexPath section]]] objectAtIndex:[indexPath row]]];
                [self.navigationController pushViewController:albumsList animated:YES];
                
            } else if ([indexPath row] == SECTION_SERVICES_INSTAGRAM) {
                GRKInstagramGrabber *grabber = [[GRKInstagramGrabber alloc] init];
                UCAlbumsList *albumsList = [[UCAlbumsList alloc] initWithGrabber:grabber
                                                                  andServiceName:[[dataSource objectForKey:[NSNumber numberWithInt:[indexPath section]]] objectAtIndex:[indexPath row]]];
                [self.navigationController pushViewController:albumsList animated:YES];
                
            } else if ([indexPath row] == SECTION_SERVICES_PICASA) {
                GRKPicasaGrabber *grabber = [[GRKPicasaGrabber alloc] init];
                UCAlbumsList *albumsList = [[UCAlbumsList alloc] initWithGrabber:grabber
                                                                  andServiceName:[[dataSource objectForKey:[NSNumber numberWithInt:[indexPath section]]] objectAtIndex:[indexPath row]]];
                [self.navigationController pushViewController:albumsList animated:YES];
                
            } else if ([indexPath row] == SECTION_SERVICES_URL) {
                [self uploadFromUrl:nil];
            }
            break;
        }
        case SECTION_UPLOADS: {
            [self showUploaded:nil];
            break;
        }
            
        default:
            DLog(@"Warning! UITableView section can not be recognized.")
            break;
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        [self startMediaBrowserFromViewController:nil withSourceType:sourceType usingDelegate:self];
    }
}

- (BOOL)startMediaBrowserFromViewController:(UIViewController*) controller
                              withSourceType:(UIImagePickerControllerSourceType)sourceType
                               usingDelegate:(id) delegate {
    DLog(@"delegate = %@, controller = %@", delegate ? @"FINE" : @"NIL", controller ? @"FINE" : @"NIL");
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = sourceType;
    
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = delegate;
    
    [self presentModalViewController:mediaUI animated:YES];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DLog(@"File Info = %@", info);    
    [NSThread detachNewThreadSelector:@selector(uploadFromImagePicker:)
                             toTarget:self
                           withObject:info];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Uploadcare

- (void)uploadFromImagePicker:(NSDictionary *)info {
    [self uploadFromFile:UIImagePNGRepresentation([info valueForKey:UIImagePickerControllerOriginalImage])
                withName:[info valueForKey:@"UIImagePickerControllerOriginalImage"]];
}

- (void)uploadFromFile:(NSData *)data withName:(NSString *)name {
    [self uploadFromFile:data withName:name serviceName:UNKNOWN_PHOTO_SOURCE];
}

- (void)uploadFromFile:(NSData *)data withName:(NSString *)name serviceName:(NSString*)serviceName {
    JSNotifier *notify = [[JSNotifier alloc] initWithTitle:@"Uploading..."];
    notify.accessoryView = progressView;
    [notify show];
    
    [[UploadcareKit shared] uploadFileWithName:name andData:data uploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"+%@: line %d - progress %llu/%llu %f%%",
              NSStringFromSelector(_cmd),
              __LINE__,
              totalBytesWritten,
              totalBytesExpectedToWrite,
              (totalBytesWritten / (totalBytesExpectedToWrite / 100.f)) / 100.f);        
        
        [progressView setProgress:((totalBytesWritten / (totalBytesExpectedToWrite / 100.f)) / 100.f) - 0.0001f];
        [notify setTitle:[NSString stringWithFormat:NSLocalizedString(@"Uploaded %.2f%%", nil), (totalBytesWritten / (totalBytesExpectedToWrite / 100.f))]];
        
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UploadcareFile *file) {
        NSLog(@"+%@: line %d success", NSStringFromSelector(_cmd), __LINE__);
        [self addToStorageFileWithId:[file file_id] fromService:serviceName];
        
        [notify setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyCheck.png"]] animated:YES];
        [notify setTitle:[NSString stringWithFormat:NSLocalizedString(@"File uploaded %@", nil), [file original_filename]] animated:YES];
        [notify hideIn:4.0];
        
        [progressView setProgress:.0f];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"+%@: line %d - ERROR %@", NSStringFromSelector(_cmd), __LINE__, error);
        
        [notify setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyX.png"]] animated:YES];
        [notify setTitle:(NSLocalizedString(@"Uploading failed!", nil)) animated:YES];
        [notify hideIn:4.0];
        
        [progressView setProgress:.0f];
    }];
}

- (void)uploadFromURL:(NSString *)url {
    [[UploadcareKit shared] uploadFileWithURL:url
                          uploadProgressBlock:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                              [progressView setProgress:(float)totalBytesWritten / totalBytesExpectedToWrite];
                          }
     
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UploadcareFile *file) {
                                          NSLog(@"+%@: line %d success", NSStringFromSelector(_cmd), __LINE__);
                                          JSNotifier *notify = [[JSNotifier alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"File uploaded %@", nil), [file original_filename]]];
                                          notify.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyCheck.png"]];
                                          [notify showFor:2.0];
                                          [progressView setProgress:1.f];
                                      }
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          NSLog(@"+%@: line %d - ERROR %@", NSStringFromSelector(_cmd), __LINE__, error);
                                          
                                          JSNotifier *notify = [[JSNotifier alloc] initWithTitle:(NSLocalizedString(@"Uploading failed!", nil))];
                                          notify.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotifyX.png"]];
                                          [notify showFor:2.0];
                                          
                                          [progressView setProgress:.0f];
                                      }];
}

#pragma mark - Uploaded Tools

- (IBAction)showOnlineFileList:(id)sender {
    UploadedViewController *uploadedViewController = [[UploadedViewController alloc] init];
    [uploadedViewController setShowLocal:NO];
    [self presentModalViewController:uploadedViewController animated:YES];
}

- (IBAction)showUploaded:(id)sender {
    UploadedViewController *uploadedViewController = [[UploadedViewController alloc] init];
    [uploadedViewController setShowLocal:YES];
    [self presentModalViewController:uploadedViewController animated:YES];
}

- (void)checkStorageAndUpdateStatus {
//    NSArray *storage = [[NSUserDefaults standardUserDefaults] arrayForKey:@"uploadcare_storage"];
}

- (void)addToStorageFileWithId:(NSString *)file_id fromService:(NSString *)serviceName {
    NSArray *storage = [[NSUserDefaults standardUserDefaults] arrayForKey:@"uploadcare_storage"];
    NSMutableArray *_storage = [[NSMutableArray alloc] initWithArray:storage];
    [_storage addObject:file_id];
    [[NSUserDefaults standardUserDefaults] setObject:_storage forKey:@"uploadcare_storage"];
    
    /* store source service name for the file */
    NSDictionary *storedFileSources = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"uploadcare_storage_sources"];
    NSMutableDictionary *mutableSources = [[NSMutableDictionary alloc]initWithDictionary:storedFileSources];
    mutableSources[file_id] = serviceName;
    [[NSUserDefaults standardUserDefaults] setObject:mutableSources forKey:@"uploadcare_storage_sources"];
    
    [self checkStorageAndUpdateStatus];
}

@end
