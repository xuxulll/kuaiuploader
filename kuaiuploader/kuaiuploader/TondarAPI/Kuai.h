//
//  Kuai.h
//  TondarAPI
//
//  Created by liuchao on 8/20/12.
//  Copyright (c) 2012 HwaYing. All rights reserved.
//
/*This file is part of XunleiLixian-API.
 
 XunleiLixian-API is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */
#import <Foundation/Foundation.h>

@interface KuaiItemInfo : NSObject
@property (weak) NSString* urlString;
@property (weak) NSString *name;
@property (weak) NSString *size;
@property (weak) NSString *gcid;
@property (weak) NSString *cid;
@property (weak) NSString *gcid_resid;
@property (weak) NSString *fid;
@property (weak) NSString *tid;
@property (weak) NSString *namehex;
@property (weak) NSString *internalid;
@property (weak) NSString *taskid;
@end

@interface Kuai : NSObject
-(NSArray*) kuaiItemInfoArrayByKuaiURL:(NSURL*) kuaiURL;
-(NSString*) generateLixianUrl:(KuaiItemInfo*) itemInfo;
@end
