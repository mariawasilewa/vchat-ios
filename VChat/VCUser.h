//
//  VCUser.h
//  VChat
//
//  Created by mihata on 11/27/13.
//  Copyright (c) 2013 mihata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCUser : NSObject {
    @private NSString* username;
    @private NSString* password;
    @private BOOL loggedin;
}

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;
@property (nonatomic) BOOL loggedin;

+(VCUser*) sharedUser;

@end
