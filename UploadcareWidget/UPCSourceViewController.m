//
//  UPCSourceViewController.m
//  Social Source
//
//  Created by Zoreslav Khimich on 01/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UploadcareSocialSource.h"
#import "UPCSourceViewController.h"
#import "UPCPatienceView.h"
#import "UPCWebLoginViewController.h"
#import "UPCGalleryViewController.h"
#import "UPCDrawerViewController.h"
#import "UPCGradientView.h"
#import "UPCThingsViewController.h"
#import "UPCListViewController.h"
#import "UPCSocialStyle.h"
#import "UPCUpload_Private.h"
#import "UPCUploadController.h"

@interface UPCSourceViewController ()

@property (strong, readonly) UPCSocialSourceClient *client;
@property (strong, readonly) USSSource *source;
@property (strong, nonatomic) USSPath *path;
@property (strong, nonatomic) USSThingSet *currentThingSet;
@property (strong, nonatomic) NSArray *thingsAccumulator;

@property (readonly) NSString *stylePath;
@property (readonly, nonatomic) USSPathChunk *activeRootChunk;

@property (strong, nonatomic) UIViewController<UPCThingsViewController> *thingsViewController;
@property (strong, nonatomic) UPCPatienceView *patienceView;
@property (strong, nonatomic) UPCDrawerViewController *drawerController;
@property (strong, nonatomic) UIView *thingsContainerView;

@property (atomic) BOOL drawerVisible;
@property (atomic) BOOL drawerAnimating;
@property (nonatomic) BOOL shouldAllowToOpenDrawer;
@property (assign, nonatomic)  NSUInteger selectedChunkIndex;

@property (strong, nonatomic) NSCache *thingsViewControllersCache;
@end

@implementation UPCSourceViewController

- (id)initWithSocialSourceClient:(UPCSocialSourceClient *)client source:(USSSource *)source activeRootChunkIndex:(NSUInteger)rootChunkIndex path:(USSPath *)path  {
    self = [super init];
    if (self) {
        _client = client;
        _source = source;
        _path = path;
        _selectedChunkIndex = rootChunkIndex;
        
        _thingsViewControllersCache = [[NSCache alloc]init];
        
    }
    return self;
}

/* "Loading" splash screen */
#pragma mark - "Loading" screen

- (UPCPatienceView *)patienceView {
    if (!_patienceView) {
        _patienceView = [[UPCPatienceView alloc]initWithFrame:self.thingsContainerView.bounds];
        _patienceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _patienceView;
}

- (void)showPatienceScreen {
    [self.thingsContainerView addSubview:self.patienceView];
}

- (void)hidePatienceScreen {
    [self.patienceView removeFromSuperview];
}

/* UIWebView & it's controller for OAuth bussiness */
#pragma mark - Login screen

const CGFloat kLoginViewAnimationDuration = 0.25f;

/* Install the login controller and present it's view animated */
- (void)presentLoginViewController:(UPCWebLoginViewController *)loginController {
    [self showPatienceScreen];
    
    [self addChildViewController:loginController];
    [self.view addSubview:loginController.view];
    [loginController.view setFrame:self.view.bounds];
    
    [loginController.view setTransform:CGAffineTransformMakeScale(0, 0)];
    [loginController.view setHidden:NO];
    [loginController didMoveToParentViewController:self];
    
    [UIView transitionWithView:self.view duration:kLoginViewAnimationDuration options:UIViewAnimationOptionCurveEaseIn animations:^{
        [loginController.view setTransform:CGAffineTransformMakeScale(1, 1)];
    } completion:^(BOOL finished) {
        [self hidePatienceScreen];
    }];
}

- (void)dismissLoginViewController:(UPCWebLoginViewController *)loginController {
    if (loginController.parentViewController != self) return;
    
    [loginController willMoveToParentViewController:nil];
    [UIView transitionWithView:self.view duration:kLoginViewAnimationDuration options:UIViewAnimationOptionCurveEaseOut animations:^{
        [loginController.view setTransform:CGAffineTransformMakeScale(0, 0)];
    } completion:^(BOOL finished) {
        [loginController.view removeFromSuperview];
        [loginController removeFromParentViewController];
    }];
}

- (void)loginUsingAddress:(NSString *)loginAddress
{
    UPCWebLoginViewController *loginController = [[UPCWebLoginViewController alloc]init];
    [loginController.view setFrame:self.view.frame];
    [loginController.view setHidden:YES];
    NSURL *loginURL = [NSURL URLWithString:loginAddress];
    [loginController loadURL:loginURL URLLoadedBlock:^(NSURL *URL) {
        if ([URL.host isEqual:[[NSURL URLWithString:USSBaseAddress] host]] && [URL.lastPathComponent isEqual:USSLoginSuccessLastPathComponent]) {
            /* Login accomplished, dismsiss the controller and retry fetching the data */
            [self dismissLoginViewController:loginController];
            [self setupThingsViewController];
     
        }else if (loginController.parentViewController != self) {
            /* Login page has been loaded and should be presented */
            [self presentLoginViewController:loginController];
            self.navigationItem.title = NSLocalizedString(@"Connect", @"Login screen title");
        }
    }];
}

/* Hideable/reveleable drawer containing a list of navigation buttons (e.g. "My Photos", "My Friends" etc) */
#pragma mark - Drawer

- (void)installDrawerButton {
    /* setup the drawer button */
    if ([self shouldAllowToOpenDrawer]) {
        UIBarButtonItem *drawerButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"UPCSelectorBarItemIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(showOrHideDrawer:)];
        [self.navigationItem setRightBarButtonItem:drawerButton animated:YES];
        
        /* swipe down over the navbar should reveal the drawer */
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showDrawer:)];
        swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        self.navigationController.navigationBar.gestureRecognizers = @[swipeRecognizer];
    }
}

- (UPCDrawerViewController *)drawerController {
    if (!_drawerController) {
        _drawerController = [[UPCDrawerViewController alloc]initWithChunks:self.source.rootChunks serviceName:self.source.title];
        _drawerController.tableView.delegate = self;
        
        /* Swipe up = hide the drawer */
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideDrawer:)];
        swipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        [_drawerController.view addGestureRecognizer:swipeRecognizer];
    }
    
    return _drawerController;
}

- (void)adoptDrawerController {
    [self addChildViewController:self.drawerController];
    [self.view insertSubview:self.drawerController.view atIndex:0];
    [self.drawerController.view setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.drawerController.heightNeeded)];
    [self.drawerController didMoveToParentViewController:self];
}

- (void)dumpDrawerController {
    [self willMoveToParentViewController:nil];
    [self.drawerController.view removeFromSuperview];
    [self.drawerController removeFromParentViewController];
}

static const CGFloat kDrawerAnimationDuration = 0.25f;

- (void)showDrawer:(id)sender {
    if (self.drawerVisible || self.drawerAnimating) return;
    self.drawerAnimating = YES;
    
    /* Install the view controller */
    [self adoptDrawerController];
    
    /* Manage selection */
    [self.drawerController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedChunkIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    /* Disable user interaction w/things view and install gesture recognizers */
    self.thingsViewController.view.userInteractionEnabled = NO;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideDrawer:)];
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideDrawer:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    self.thingsContainerView.gestureRecognizers = @[tapRecognizer, swipeRecognizer];
    
    /* Reveal the drawer animated */
    [UIView animateWithDuration:kDrawerAnimationDuration delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.thingsContainerView.frame = CGRectOffset(self.thingsContainerView.frame, 0, self.drawerController.heightNeeded);
    } completion:^(BOOL finished) {
        self.drawerAnimating = NO;
        self.drawerVisible = YES;
    }];
}

- (void)hideDrawer:(id)sender {
    if (!self.drawerVisible || self.drawerAnimating) return;
    self.drawerAnimating = YES;
    
    /* Hide the drawe animated */
    [UIView animateWithDuration:kDrawerAnimationDuration delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.thingsContainerView.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        [self dumpDrawerController];
        self.drawerAnimating = NO;
        self.drawerVisible = NO;
        
        /* Enable user interaction w/things view and remove the gesture recognizers */
        self.thingsContainerView.gestureRecognizers = nil;
        self.thingsViewController.view.userInteractionEnabled = YES;
    }];
}

- (void)showOrHideDrawer:(id)sender {
    if (!self.drawerVisible) {
        [self showDrawer:sender];
    }else{
        [self hideDrawer:sender];
    }
}

- (void)setSelectedChunkIndex:(NSUInteger)selectedChunkIndex {
    _selectedChunkIndex = selectedChunkIndex;
    [self setupThingsViewController];
    // Uncomment to display chunk title in the nav bar (e.g. "My Photos") instead of the service name
    // self.navigationItem.title = self.activeChunk.title;
}

/* Drawer item has been selected */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.drawerController.tableView) {
        if (indexPath.section == 0) {
            NSUInteger newSelectedChunkIndex = indexPath.row;
            if (self.selectedChunkIndex != newSelectedChunkIndex) {
                self.selectedChunkIndex = newSelectedChunkIndex;
            }
            [self hideDrawer:self];
        }else{
            [self.source signOutUsingClient:self.client completionBlock:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }
}

- (USSPathChunk *)activeRootChunk {
    return self.source.rootChunks[self.selectedChunkIndex];
}


#pragma mark - Views and appearance setup

- (void)setupShadows {
    CGFloat kShadowHeight = 18.f;
    CGFloat kShadowStrength = .15f;

    /* Make the things view seem to drop shadow when the drawer is shown */
    UPCGradientView *bottomshadowSubview = [[UPCGradientView alloc]initWithFrame:CGRectMake(0, -kShadowHeight, CGRectGetWidth(self.thingsContainerView.bounds), kShadowHeight)];
    bottomshadowSubview.gradientLayer.colors = @[(id)[UIColor colorWithWhite:0. alpha:0.].CGColor, (id)[UIColor colorWithWhite:0. alpha:kShadowStrength].CGColor];
    bottomshadowSubview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bottomshadowSubview.opaque = NO;
    bottomshadowSubview.userInteractionEnabled = NO;
    [self.thingsContainerView addSubview:bottomshadowSubview];
    self.thingsContainerView.layer.masksToBounds = NO;
    
    /* Make the navigation bar seem to drop shadow as well */
    UPCGradientView *topShadowSubview = [[UPCGradientView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.thingsContainerView.bounds), kShadowHeight)];
    topShadowSubview.gradientLayer.colors = @[(id)[UIColor colorWithWhite:0. alpha:kShadowStrength].CGColor, (id)[UIColor colorWithWhite:0. alpha:0.].CGColor];
    topShadowSubview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    topShadowSubview.opaque = NO;
    topShadowSubview.userInteractionEnabled = NO;
    [self.view insertSubview:topShadowSubview belowSubview:self.thingsContainerView];
     
}

- (void)setupThingsContainerView {
    self.thingsContainerView = [[UIView alloc]initWithFrame:self.view.bounds];
    self.thingsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    self.thingsContainerView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
    
    /* `empty` label */
    UILabel *emptyLabel = [[UILabel alloc]init];
    emptyLabel.text = NSLocalizedString(@"Empty", @"Empty collection view label");
    emptyLabel.font = [UIFont boldSystemFontOfSize:21];
    emptyLabel.textColor = [UIColor colorWithWhite:0.77 alpha:1.0];
    emptyLabel.backgroundColor = [UIColor clearColor];
    emptyLabel.shadowColor = [UIColor whiteColor];
    emptyLabel.shadowOffset = CGSizeMake(0, -1);
    [emptyLabel sizeToFit];
    emptyLabel.center = CGPointMake(CGRectGetWidth(self.thingsContainerView.bounds) *.5, CGRectGetHeight(self.thingsContainerView.bounds) *.5 - 20);
    emptyLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.thingsContainerView addSubview:emptyLabel];
    
    [self.view addSubview:self.thingsContainerView];
}

#pragma UIViewController stuff

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    self.view.backgroundColor = [UIColor colorWithRed:49./255 green:60./255 blue:74./255 alpha:1.];
    
    /* views & stuff */
    [self setupThingsContainerView];
    [self setupShadows];

    /* Create the things view controller and fetch the data */
    [self setupThingsViewController];
}


- (void)viewWillAppear:(BOOL)animated {
    /* restore swipe gesture, if appropriate */
    [self installDrawerButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    /* Remove the swipe recognizer (see above) */
    self.navigationController.navigationBar.gestureRecognizers = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Things view controller

- (void)setThingsViewController:(UIViewController<UPCThingsViewController> *)thingsViewController {
    [_thingsViewController willMoveToParentViewController:nil];
    [_thingsViewController.view removeFromSuperview];
    [_thingsViewController removeFromParentViewController];
    _thingsViewController = thingsViewController;
    if (_thingsViewController){
        [self addChildViewController:_thingsViewController];
        [self.thingsContainerView addSubview:_thingsViewController.view];
        [_thingsViewController.view setFrame:self.thingsContainerView.bounds];
        [_thingsViewController didMoveToParentViewController:self];
    }
}

#pragma mark - Data fetch

- (NSString *)stylePath {
    return [[self.source.shortName stringByAppendingPathComponent:self.activeRootChunk.pathChunk]stringByAppendingPathComponent:self.path.path];
}

- (NSString *)navigationTitle {
    if (self.path) {
        return self.path.title;
    }
    return self.source.title;
}

- (void)loadPath:(USSPath *)path usingBlock:(void(^)(USSThingSet *thingSet))resultBlock {
    [self.client queryObjectOrLoginAddressForSourceBase:self.source.baseAddress rootChunkPath:self.activeRootChunk.pathChunk path:path resultBlock:^(USSThingSet *thingSet, NSString *loginAddress, NSError *error) {
        if (error) {
#warning Hanlde errors!
            NSLog(@"Failed to fetch Social Source data: %@", error);
        } else if (thingSet) {
            /* Data fetched all right */
            resultBlock(thingSet);
        }else if(loginAddress) {
            /* Need to login */
            [self loginUsingAddress:loginAddress];
        }
    }];    
}

- (void)setupThingsViewController {
    self.navigationItem.title = self.navigationTitle;
    self.shouldAllowToOpenDrawer = NO;
    
    /* Select the appropriate presentation type */
    Class thingsControllerClass;
    if ([UPCSocialStyle presentationTypeForPath:self.stylePath] == UPCPresentationTypeGrid) {
        thingsControllerClass = [UPCGalleryViewController class];
    }else if([UPCSocialStyle presentationTypeForPath:self.stylePath] == UPCPresentationTypeList) {
        thingsControllerClass = [UPCListViewController class];
    }

    /* attempt to reuse a cached controller */
    UIViewController<UPCThingsViewController> *controller = [self.thingsViewControllersCache objectForKey:thingsControllerClass];
    if (!controller) {
        controller = [[thingsControllerClass alloc]init];
        [self.thingsViewControllersCache setObject:controller forKey:thingsControllerClass];
    }
    self.thingsViewController = controller;
    
    /* set style */
    NSString *stylePath = self.stylePath;
    self.thingsViewController.stylePath = stylePath;
    
    [self showPatienceScreen];
    [self loadPath:self.path usingBlock:^(USSThingSet *thingSet) {
        /* pass the data to the controller */
        if (thingSet.things.count || [self.stylePath.lastPathComponent isEqualToString:@"search"]) {
            [self.thingsViewController setThings:thingSet.things isLastPage:thingSet.nextPagePath == nil];
        } else {
            [self setThingsViewController:nil];
        }
        self.currentThingSet = thingSet;
        [self setThingsAccumulator: nil];

        /* enable the drawer button and swipe gesture, if appropriate */
        self.shouldAllowToOpenDrawer = !self.path; // drawer should not be openable for anything below the root chunk
        [self installDrawerButton];

        [self hidePatienceScreen];
    }];
}

- (void)refreshThings {
    [self loadPath:self.path usingBlock:^(USSThingSet *thingSet) {
        [self.thingsViewController setThings:thingSet.things isLastPage:thingSet.nextPagePath == nil];
        [self setThingsAccumulator:nil];
        self.currentThingSet = thingSet;
    }];
}

- (void)fetchNextThingsPage {
    [self loadPath:self.currentThingSet.nextPagePath usingBlock:^(USSThingSet *thingSet) {
        if (!self.thingsAccumulator) {
            self.thingsAccumulator = self.currentThingSet.things;
        }
        self.thingsAccumulator = [self.thingsAccumulator arrayByAddingObjectsFromArray:thingSet.things];
        [self.thingsViewController setThings:self.thingsAccumulator isLastPage:thingSet.nextPagePath == nil];
        self.currentThingSet = thingSet;
    }];
}

- (void)search:(NSString *)text {
    [self loadPath:[USSPath pathWithChunk:[NSString stringWithFormat:@"-/%@", text] titled:text] usingBlock:^(USSThingSet *thingSet) {
        self.thingsAccumulator = nil;
        [self.thingsViewController setThings:thingSet.things isLastPage:thingSet.nextPagePath == nil];
        self.currentThingSet = thingSet;
    }];
}

/* Navigation */
#pragma mark - Navigation

- (void)performSocialSourceAction:(USSAction *)action forItemTitled:(NSString *)title withThumbnailURL:(NSURL *)thumbnailURL thumbnailImage:(UIImage *)thumbnailImage {
    switch (action.type) {
        case USSActionTypeOpenPath:
            [self openPath:action.path withTitle:title];
            break;
            
        case USSActionTypeSelectFile:
            [self showPatienceScreen];
            [self.client selectFile:action.file socialSource:self.source resultBlock:^(NSString *selectedFileAddress, NSError *error) {
                if (error) {
#warning Handle error!
                    NSLog(@"Failed to select a file: %@", error);
                } else {
                    NSURL *fileURL = [NSURL URLWithString:selectedFileAddress];
                    NSAssert([self.navigationController isKindOfClass:[UPCUploadController class]], @"Navigation controller is not %@", [UPCUploadController class]);
                    UPCUploadController *uploadController = (UPCUploadController *)self.navigationController;
                    [uploadController.presentingViewController dismissViewControllerAnimated:YES completion:^{
                        [self hidePatienceScreen];
                        [UPCUpload uploadRemoteForURL:fileURL title:title thumbnailURL:thumbnailURL thumbnailImage:thumbnailImage delegate:uploadController.uploadDelegate source:self.source.title];
                    }];
                }
            }];
        break;
    }
}

- (void)openPath:(USSPath *)path withTitle:(NSString *)title {
    UPCSourceViewController *controller = [[UPCSourceViewController alloc]initWithSocialSourceClient:self.client source:self.source activeRootChunkIndex:self.selectedChunkIndex path:path];
    [self.navigationController pushViewController:controller animated:YES];
}

@end