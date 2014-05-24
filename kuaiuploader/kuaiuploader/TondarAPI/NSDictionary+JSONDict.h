//
//  NSDictionary+JSONDict.h
//  utsearch
//
//  Created by 徐 磊 on 13-10-9.
//  Copyright (c) 2013年 xuxulll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONDict)
+(NSDictionary*)dictionaryWithContentsOfJSONData:(NSData *)data;
-(NSData*)toJSON;
@end
