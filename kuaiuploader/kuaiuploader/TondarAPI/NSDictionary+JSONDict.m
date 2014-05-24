//
//  NSDictionary+JSONDict.m
//  utsearch
//
//  Created by 徐 磊 on 13-10-9.
//  Copyright (c) 2013年 xuxulll. All rights reserved.
//

#import "NSDictionary+JSONDict.h"

@implementation NSDictionary (JSONDict)


+(NSDictionary*)dictionaryWithContentsOfJSONData:(NSData *)data
{
    NSError *error;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;    
}
@end

