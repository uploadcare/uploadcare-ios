//
//  UPCSocialSource.h
//  Social Source
//
//  Created by Zoreslav Khimich on 01/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import <UIKit/UIKit.h>

/* typedef blocks */
#pragma mark - typedef blocks

/** Signature for the block executed when querySourcesUsingBlock:completes 
 *  @param sources  Array, containing USSSource objects
 *  @param error    NSError object describing the error, or nil */
typedef void(^USSQuerySourcesCompletionBlock)(NSArray *sources, NSError *error);

@class USSThingSet;
typedef void(^USSQueryObjectOrLoginAddressCompletionBlock)(USSThingSet *thingSet, NSString *loginAddress, NSError *error);

typedef void(^USSSelectFileCompletionBlock)(NSString *selectedFileAddress, NSError *error);

/* constants */
#pragma mark - constants

extern NSString *const USSBaseAddress;
extern NSString *const USSLoginSuccessLastPathComponent;

@class UPCSocialSourceClient;

/* USSSource */
#pragma mark - USSSource

@interface USSSource : NSObject

- (id)initWithJSON:(NSDictionary *)JSON;

@property (readonly, nonatomic) NSString *shortName;
@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) NSString *baseAddress;
@property (readonly, nonatomic) NSString *selectFileAddress;
@property (readonly, nonatomic) NSArray *rootChunks; // array of USSPathChunk

- (void)signOutUsingClient:(UPCSocialSourceClient *)client completionBlock:(void(^)(void))completionBlock;

@end

/* USSPathChunk */
#pragma mark - USSPathChunk

@interface USSPathChunk : NSObject

- (id)initWithJSON:(NSDictionary *)JSON;

@property (readonly, nonatomic) NSString *pathChunk;
@property (readonly, nonatomic) NSString *title;

@end

/* USSPath */
#pragma mark - USSPath

@interface USSPath : NSObject

- (id)initWithJSON:(NSDictionary *)JSON;

@property (readonly, nonatomic) NSArray *chunks;            /* array of USSPathChunk */
@property (readonly, nonatomic) NSString *path;             /* e.g. "chunk1/chunk2/chunk3" */
@property (readonly, nonatomic) USSPathChunk *lastChunk;
@property (readonly, nonatomic) NSString *title;

- (NSString *)absoluteAddressWithSourceBasePath:(NSString *)sourceBasePath rootChunkPath:(NSString *)rootChunkPath;
- (USSPath *)pathByAddingComponent:(NSString *)pathComponent titled:(NSString *)title;

+ (USSPath *)pathWithChunk:(NSString *)pathChunk titled:(NSString *)title;

@end

#pragma mark - USSAction

/* USSActionType */

typedef enum {
    USSActionTypeOpenPath = 1,
    USSActionTypeSelectFile,

}USSActionType;

/* USSAction */

@interface USSAction : NSObject

- (id)initWithJSON:(NSDictionary *)JSON;

@property (readonly, nonatomic) USSActionType type;
@property (readonly, nonatomic) USSPath *path;
@property (readonly, nonatomic) NSString *file;

@end

#pragma mark - USSThing

/* USSThingType */

typedef enum {
    USSThingTypeItem = 1,   /* photo, file, etc. */
    USSThingTypeGroup ,     /* album, folder, friend, etc. */
    
} USSThingType;

/* USSThing */

@interface USSThing : NSObject

- (id)initWithJSON:(NSDictionary *)JSON;

@property (readonly, nonatomic) USSThingType type;
@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) NSURL *thumbnailURL;
@property (readonly, nonatomic) USSAction *action;

@end

/* USSThingSet */
#pragma mark - USSThingSet 

@interface USSThingSet : NSObject

- (id)initWithJSON:(NSDictionary *)JSON;

@property (readonly, nonatomic) USSPathChunk *rootChunk;
@property (readonly, nonatomic) USSPath *path;
@property (readonly, nonatomic) NSArray *things;
@property (readonly, nonatomic) USSPath *nextPagePath;

@end


/* UPCSocialSource */
#pragma mark - UPCSocialSource

@interface UPCSocialSourceClient : NSObject

- (id)initWithUploadcarePublicKey:(NSString *)publicKey;

- (void)querySourcesUsingBlock:(USSQuerySourcesCompletionBlock)resultBlock;
- (void)queryObjectOrLoginAddressForSourceBase:(NSString *)sourceBase rootChunkPath:(NSString *)rootChunkPath path:(USSPath *)path resultBlock:(USSQueryObjectOrLoginAddressCompletionBlock)resultBlock;
- (void)selectFile:(NSString *)file socialSource:(USSSource *)source resultBlock:(USSSelectFileCompletionBlock)resultBlock;

@end


