//
//  UImageNetworking.h
//  UGoogleImageSearch
//
//  Created by Adam Bemowski on 4/21/13.
//  Copyright (c) 2013 BEMO. All rights reserved.
//

#import "AFHTTPClient.h"

@interface UImageNetworking : AFHTTPClient

+ (UImageNetworking *)sharedClient;

- (void)getImagesForSearch:(NSString *)searchTerm
                      page:(int)page
                   success:(void (^)(NSArray *array))success
                   failure:(void (^)(NSError *error))failure;

@end
