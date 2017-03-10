//
//  HJDownloaderManager.h
//  HJConnection
//
//  Created by han on 2017/3/9.
//  Copyright © 2017年 han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HJDownloaderManager : NSObject

+(instancetype)shareDownloaderManager;


/** 多条线程下载多个任务 */
/** 下载 */
-(void)downloadWithURL:(NSURL *)url Progress:(void (^)(float progress))progress completion:(void (^)(NSString * filePath))completion failed:(void (^)(NSString * errorMsg))failed;

/** 暂停下载 */
-(void)pauserWithURL:(NSURL *)url;

/** 多条线程下载同一个任务 */
-(void)downloadWithURL:(NSURL *)url;




@end
