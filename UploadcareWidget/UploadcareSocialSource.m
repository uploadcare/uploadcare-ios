//
//  UPCSocialSource.m
//  Social Source
//
//  Created by Zoreslav Khimich on 01/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "UploadcareSocialSource.h"

#import <AFNetworking/AFHTTPClient.h>
#import <AFNetworking/AFJSONRequestOperation.h>

NSString *const USSBaseAddress = @"https://social.staging0.uploadcare.com";
NSString *const USSLoginSuccessLastPathComponent = @"endpoint";

NSString *const USSPublicKeyHeader = @"X-Uploadcare-PublicKey";
NSString *const USSContentType = @"application/vnd.ucare.ss-v0.1+json";

NSString *const USSSourcesAddress = @"/sources";
NSString *const USSLoginAddressKey = @"login_link";

NSString *const USSErrorDomain =  @"USSErrorDomain";

/* Utility */
#pragma mark - Utility

NSString *USSURLEncode(NSString *unencodedString) {
    unencodedString = [unencodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)unencodedString, NULL, (CFStringRef)@"!*'();:@&=+$,?%#[]", kCFStringEncodingUTF8));
}

NSURL *USSAbsoluteURL(NSString *address) {
    NSURL *resultURL = [NSURL URLWithString:address];
    if (!resultURL.host) {
        NSURL *baseURL = [NSURL URLWithString:USSBaseAddress];
        resultURL = [NSURL URLWithString:address relativeToURL:baseURL];
    }
    return resultURL;
}

@interface UPCSocialSourceClient ()

@property (strong, readonly) AFHTTPClient *client;

@end

@implementation UPCSocialSourceClient

- (id)initWithUploadcarePublicKey:(NSString *)publicKey {
    self = [super init];
    if (self) {
        /* Make AFJSONRequestOperation accept `application/vnd.ucare.ss-v0.1+json` */
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:USSContentType, nil]];
        
        _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:USSBaseAddress]];
        /* Use AFJSONRequestOperation */
        [_client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        /* Accept the content type */
        [_client setDefaultHeader:@"Accept" value:USSContentType];
        /* Public key header */
        [_client setDefaultHeader:USSPublicKeyHeader value:publicKey];
    }
    return self;
}

- (void)querySourcesUsingBlock:(USSQuerySourcesCompletionBlock)resultBlock {
    [self.client getPath:USSSourcesAddress parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // ensure it's a dictionaty
        assert([responseObject isKindOfClass:[NSDictionary class]]);
        // enumerate sources, create USSSource instances and let them parse JSON
        NSArray *JSONSources = [responseObject objectForKey:@"sources"];
        NSMutableArray *sources = [[NSMutableArray alloc]initWithCapacity:[JSONSources count]];
        for (NSDictionary *JSONSource in JSONSources) {
            USSSource *source = [[USSSource alloc]initWithJSON:JSONSource];
            [sources addObject:source];
        }
        // pass the results
        resultBlock(sources, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // pass the error
        resultBlock(nil, error);
    }];
}

- (void)queryObjectOrLoginAddressForSourceBase:(NSString *)sourceBase rootChunkPath:(NSString *)rootChunkPath path:(USSPath *)path resultBlock:(USSQueryObjectOrLoginAddressCompletionBlock)resultBlock {

    NSString *absolutePath;
    if (path) {
        absolutePath = [path absoluteAddressWithSourceBasePath:sourceBase rootChunkPath:rootChunkPath];
    }else{
        absolutePath = [[USSBaseAddress stringByAppendingPathComponent:sourceBase] stringByAppendingPathComponent:rootChunkPath];
    }
    
    [self.client getPath:absolutePath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        assert([responseObject isKindOfClass:[NSDictionary class]]);
        NSString *loginAddress = [responseObject objectForKey:USSLoginAddressKey];
        if (loginAddress) {
            resultBlock(nil, loginAddress, nil);
        }else if([[responseObject objectForKey:@"obj_type"]isEqualToString:@"error"]) {
            resultBlock(nil, nil, [NSError errorWithDomain:USSErrorDomain code:1 userInfo:responseObject]);
        }else {
            USSThingSet *thingSet = [[USSThingSet alloc]initWithJSON:responseObject];
            resultBlock(thingSet, nil, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        resultBlock(nil, nil, error);
    }];
}

- (void)selectFile:(NSString *)file socialSource:(USSSource *)source resultBlock:(USSSelectFileCompletionBlock)resultBlock {
    [self.client postPath:source.selectFileAddress parameters:@{@"file" : file} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        resultBlock(responseObject[@"url"], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        resultBlock(nil, error);
    }];
}

@end

/* USSPathChunk */
#pragma mark - USSPathChunk

@interface USSPathChunk ()
@property (strong, nonatomic) NSDictionary *JSON;
@end

@implementation USSPathChunk

- (id)initWithJSON:(NSDictionary *)JSON {
    self = [super init];
    if (self) {
        _JSON = JSON;
    }
    return self;
}

- (NSString *)pathChunk {
    return USSURLEncode(self.JSON[@"path_chunk"]);
}

- (NSString *)title {
    return self.JSON[@"title"];
}

@end

/* USSPath */
#pragma mark - USSPath

@interface USSPath ()
@property (strong, nonatomic) NSArray *chunks;
@property (strong, nonatomic) NSString *path;
@end

@implementation USSPath

- (id)initWithJSON:(NSDictionary *)JSON {
    self = [super init];
    if (self) {
        NSAssert([JSON[@"obj_type"]isEqualToString:@"path"], @"(%@) %@ has unexpected object type", self.class, JSON);

        NSArray *JSONChunks = JSON[@"chunks"];
        NSMutableArray *chunksArray = [[NSMutableArray alloc]initWithCapacity:JSONChunks.count];
        
        for(NSDictionary *JSONChunk in JSONChunks) {
            USSPathChunk *pathChunk = [[USSPathChunk alloc]initWithJSON:JSONChunk];
            [chunksArray addObject:pathChunk];
        }
        _chunks = chunksArray;
    }
    return self;
}

- (id)initWithChunks:(NSArray *)chunks {
    self = [super init];
    if (self) {
        _chunks = chunks;
    }
    return self;
}

- (NSString *)path {
    if (!_path) {
        _path = [[NSString alloc]init];
        for(USSPathChunk *chunk in self.chunks) {
            _path = [_path stringByAppendingPathComponent:chunk.pathChunk];
        }
    }
    return _path;
}

- (NSString *)absoluteAddressWithSourceBasePath:(NSString *)sourceBasePath rootChunkPath:(NSString *)rootChunkPath {
    NSString *absoluteSourcePath = [USSBaseAddress stringByAppendingPathComponent:sourceBasePath];
    NSString *absoluteRootChunkPath = [absoluteSourcePath stringByAppendingPathComponent:rootChunkPath];
    return [absoluteRootChunkPath stringByAppendingPathComponent:self.path];
}

- (USSPathChunk *)lastChunk {
    return self.chunks.lastObject;
}

- (NSString *)title {
    for(NSInteger index = self.chunks.count-1; index >= 0; index--) {
        if ([[self.chunks[index] title] length]) return [self.chunks[index] title];
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %@>", self.class, self.path];
}

+ (USSPath *)pathWithChunk:(NSString *)pathChunk titled:(NSString *)title {
    USSPathChunk *chunk = [[USSPathChunk alloc]initWithJSON:@{@"path_chunk": pathChunk, @"title":title}];
    USSPath *path = [[USSPath alloc]initWithChunks:@[chunk]];
    return path;
}

- (USSPath *)pathByAddingComponent:(NSString *)pathComponent titled:(NSString *)title {
    USSPathChunk *chunk = [[USSPathChunk alloc]initWithJSON:@{@"path_chunk": pathComponent, @"title":title}];
    NSArray *chunks = [self.chunks arrayByAddingObject:chunk];
    USSPath *path = [[USSPath alloc]initWithChunks:chunks];
    return path;
}

@end

/* USSSource */
#pragma mark - USSSource

@interface USSSource ()
@property (strong, nonatomic) NSDictionary *JSON;
@property (strong, nonatomic) NSArray *rootChunks;
@end

@implementation USSSource

- (id)initWithJSON:(NSDictionary *)JSON {
    self = [super init];
    if (self) {
        _JSON = JSON;
    }
    return self;
}

- (NSString *)shortName {
    return self.JSON[@"name"];
}

+ (NSString *)sourceTitleForShortName:(NSString *)shortName {
    static NSDictionary *kTitles;
    if (!kTitles) {
        kTitles = @{ @"instagram"    : NSLocalizedString(@"Instagram", @"Instagram source title"),
                     @"facebook"     : NSLocalizedString(@"Facebook", @"Facebook source title"),
                     @"gdrive"       : NSLocalizedString(@"Google Drive", @"Google Drive source title"),
                     @"dropbox"      : NSLocalizedString(@"Dropbox", @"Dropbox source title"),
                     };
    }
    return kTitles[shortName];
}

- (NSString *)title {
    return [USSSource sourceTitleForShortName:self.shortName];
}

- (NSString *)baseAddress {
    return self.JSON[@"urls"][@"source_base"];
}

- (NSString *)selectFileAddress {
    return self.JSON[@"urls"][@"done"];
}

- (NSArray *)rootChunks {
    if (!_rootChunks) {
        NSArray *JSONRootChunks = self.JSON[@"root_chunks"];
        NSMutableArray *mutableChunks = [[NSMutableArray alloc]initWithCapacity:[JSONRootChunks count]];
        for(NSDictionary *JSONChunk in JSONRootChunks) {
            USSPathChunk *pathChunk = [[USSPathChunk alloc]initWithJSON:JSONChunk];
            [mutableChunks addObject:pathChunk];
        }
        _rootChunks = mutableChunks;
    }
    return _rootChunks;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: baseAddress:%@, shortName:%@, %d chunks>", self.class, self.baseAddress, self.shortName, self.rootChunks.count];
}

- (void)signOutUsingClient:(UPCSocialSourceClient *)client completionBlock:(void(^)(void))completionBlock {
    NSString *signOutPath = self.JSON[@"urls"][@"session"];
    [client.client deletePath:signOutPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to sign out from %@: %@", self.shortName, error);
    }];
}

@end

/* USSAction */
#pragma mark - USSAction

@interface USSAction ()
@property (strong, nonatomic) NSDictionary *JSON;
@property (readwrite, strong, nonatomic) USSPath *path;

@end

@implementation USSAction

- (id)initWithJSON:(NSDictionary *)JSON {
    self = [super init];
    if (self) {
        _JSON = JSON;
        
        NSString *JSONActionType = _JSON[@"action"];
        if ([JSONActionType isEqualToString:@"select_file"]) {
            _type = USSActionTypeSelectFile;
        } else if ([JSONActionType isEqualToString:@"open_path"]) {
            _type = USSActionTypeOpenPath;
        } else {
            NSAssert(NO, @"Unknown action `%@`", JSONActionType);
        }
    }
    return self;
}

- (USSPath *)path {
    if (!_path) {
        _path = [[USSPath alloc]initWithJSON:self.JSON[@"path"]];
    }
    return _path;
}

- (NSString *)file {
    return self.JSON[@"url"];
}

@end

/* USSThing */
#pragma mark - USSThing

@interface USSThing ()
@property (strong, nonatomic) NSDictionary *JSON;
@property (assign, nonatomic) USSThingType type;
@property (readwrite, strong, nonatomic) NSURL *thumbnailURL;
@property (readwrite, strong, nonatomic) USSAction *action;
@end

@implementation USSThing

- (id)initWithJSON:(NSDictionary *)JSON {
    self = [super init];
    if (self) {
        _JSON = JSON;
        
        NSString *JSONObjectType = _JSON[@"obj_type"];
        if ([JSONObjectType isEqualToString:@"album"]) {
            _type = USSThingTypeGroup;
        } else if ([JSONObjectType isEqualToString:@"photo"]) {
            _type = USSThingTypeItem;
        } else {
            NSAssert(NO, @"Unknown thing type `%@`", JSONObjectType);
            return nil;
        }
    }
    return self;
}

- (NSString *)title {
    return self.JSON[@"title"];
}

- (NSURL *)thumbnailURL {
    if (!_thumbnailURL) {
        NSString *thumnailAddress = self.JSON[@"thumbnail"];
        _thumbnailURL = USSAbsoluteURL(thumnailAddress);
    }
    return _thumbnailURL;
}

- (USSAction *)action {
    if (!_action) {
        _action = [[USSAction alloc]initWithJSON:self.JSON[@"action"]];
    }
    return _action;
}

@end

/* USSThingSet */
#pragma mark - USSThingSet

@interface USSThingSet ()
@property (strong, nonatomic) NSDictionary *JSON;
@property (readwrite, strong, nonatomic) USSPathChunk *rootChunk;
@property (readwrite, strong, nonatomic) USSPath *path;
@property (readwrite, strong, nonatomic) NSArray *things;
@property (readwrite, strong, nonatomic) USSPath *nextPagePath;
@end

@implementation USSThingSet

- (id)initWithJSON:(NSDictionary *)JSON {
    self = [super init];
    if (self) {
        _JSON = JSON;
    }
    return self;
}

- (USSPathChunk *)rootChunk {
    if (!_rootChunk) {
        _rootChunk = [[USSPathChunk alloc]initWithJSON:self.JSON[@"root"]];
    }
    return _rootChunk;
}

- (USSPath *)path {
    if (!_path) {
        _path = [[USSPath alloc]initWithJSON:self.JSON[@"path"]];
    }
    return _path;
}

- (NSArray *)things {
    if (!_things) {
        NSArray *JSONThings = self.JSON[@"things"];
        NSMutableArray *mutableThings = [[NSMutableArray alloc]initWithCapacity:JSONThings.count];
        for (NSDictionary *JSONThing in JSONThings) {
            USSThing *thing = [[USSThing alloc]initWithJSON:JSONThing];
            [mutableThings addObject:thing];
        }
        _things = mutableThings;
    }
    return _things;
}

- (USSPath *)nextPagePath {
    if (!_nextPagePath) {
        NSDictionary *JSONNextPage = self.JSON[@"next_page"];
        if (!JSONNextPage || (NSNull *)JSONNextPage == [NSNull null]) return nil;
        _nextPagePath = [[USSPath alloc]initWithJSON:JSONNextPage];
    }
    return _nextPagePath;
}

@end
