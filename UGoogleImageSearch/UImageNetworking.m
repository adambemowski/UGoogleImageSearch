//
//  UImageNetworking.m
//  UGoogleImageSearch
//
//  Created by Adam Bemowski on 4/21/13.
//  Copyright (c) 2013 BEMO. All rights reserved.
//

#import "UImageNetworking.h"
#import "AFJSONRequestOperation.h"

#define kBaseURL @"https://ajax.googleapis.com"

@implementation UImageNetworking


#pragma mark - Designated Initializer

+ (UImageNetworking *)sharedClient
{
    static UImageNetworking *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UImageNetworking alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    });
    
    return _sharedClient;
}


- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self != nil) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];        
    }
    
    return self;
}


#pragma mark - Get Search Term for Page

- (void)getImagesForSearch:(NSString *)searchTerm
                      page:(int)pageIndex
                   success:(void (^)(NSArray *array))success
                   failure:(void (^)(NSError *error))failure
{    
    NSLog(@"search Term: %@, page: %i", searchTerm ,pageIndex);
    
    NSDictionary *parameters = @{@"q": searchTerm,
                                 @"v": @"1.0",
                                 @"imgsz": @"medium",
                                 @"rsz": @"8",
                                 @"start": [NSString stringWithFormat:@"%i" ,pageIndex*8]};
    
    [self getPath:@"ajax/services/search/images" parameters:parameters success:^(AFHTTPRequestOperation *operation, id response) {
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        
        NSArray *results = [[dictionary objectForKey:@"responseData"] objectForKey:@"results"];
        if (success) success(results);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.userInfo);
        
        if (failure) failure(error);
    }];
}


@end
