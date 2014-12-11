//
//  SharedData.m
//  AFace
//
//  Created by Kaven Feng on 12/9/14.
//  Copyright (c) 2014 Kaven Feng. All rights reserved.
//

#import "SharedData.h"

@interface SharedData ()
@property (readwrite, nonatomic, strong) NSDictionary *loginData;
@property (readwrite, nonatomic, strong) NSString *token;
@property (readwrite, nonatomic, strong) NSString *fullName;

@end

@implementation SharedData

+ (SharedData *)theInstance
{
    static SharedData *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[SharedData alloc] init];
        
        return sharedSingleton;
    }
}

- (NSString*) getToken
{
    return self.token;
}

- (NSString*) getUserFullName
{
    return self.fullName;
}


- (void) login : (NSDictionary*) loginData
{
    self.loginData = loginData;
    self.token = [self.loginData objectForKey:@"token"];
    self.fullName = [self.loginData objectForKey:@"name"];
    
}

- (void) logout
{
    self.loginData = nil;
}


@end
