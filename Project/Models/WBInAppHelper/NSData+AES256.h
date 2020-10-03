//
//  NSData+AES256.h
//  Kefir
//
//  Created by Иван Труфанов on 31.01.14.
//  Copyright (c) 2014 wit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)
- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;
@end
