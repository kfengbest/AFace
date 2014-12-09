//
//  SharedData.h
//  AFace
//
//  Created by Kaven Feng on 12/9/14.
//  Copyright (c) 2014 Kaven Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedData : NSObject

+ (SharedData *)theInstance;

- (void) login : (NSDictionary*) loginData;
- (void) logout;

- (NSString*) getToken;
- (NSString*) getUserFullName;

@end
