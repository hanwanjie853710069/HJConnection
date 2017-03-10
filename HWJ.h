//
//  HWJ.h
//  HJConnection
//
//  Created by han on 2017/3/9.
//  Copyright © 2017年 han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWJ : NSObject

@property(nonatomic,assign) long long start;  /** 开始 */

@property(nonatomic,assign) long long end;  /** 结束 */

@property(nonatomic,assign) long long currentPosition;/** 当前写到什么位置了 */

@property(nonatomic,strong) NSURLResponse *response;        /**请求头信息  */

/**
 *  下载指定url的文件
 *  需要扩展:通知调用者下载的相关信息
 *  1.进度,通知百分比
 *  2.是否完成,通知下载保存的路径
 *  3.错误,通知错误信息
 
 *  代理 / block
 *  @param url 要下载的url
 */
-(void)downloadWithURL:(NSURL *)url;

/** 暂停下载 */
- (void)pause;

-(void)serverFileInforthURL:(NSURL *)url;

-(BOOL)checkLocalFileInfo;

@end
