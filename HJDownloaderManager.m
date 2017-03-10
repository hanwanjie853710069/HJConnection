//
//  HJDownloaderManager.m
//  HJConnection
//
//  Created by han on 2017/3/9.
//  Copyright © 2017年 han. All rights reserved.
//

#import "HJDownloaderManager.h"
#import "HJConnectionDownloader.h"
#import "HWJ.h"

@interface HJDownloaderManager ()

@property(nonatomic,strong) NSMutableDictionary * downloaderCache;/** 下载缓冲池 */

@property(nonatomic,copy) void (^failedBlock)(NSString *);/** 失败回调属性 */

@end

@implementation HJDownloaderManager

-(NSMutableDictionary *)downloaderCache
{
    if (!_downloaderCache) {
        _downloaderCache = [NSMutableDictionary dictionary];
    }
    return _downloaderCache;
}

+ (instancetype)shareDownloaderManager {

    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    
    return instance;

}

-(void)downloadWithURL:(NSURL *)url Progress:(void (^)(float progress))progress completion:(void (^)(NSString * filePath))completion failed:(void (^)(NSString * errorMsg))failed {

    self.failedBlock = failed;
    
    HJConnectionDownloader *downloader = self.downloaderCache[url.path];
    
    if (downloader != nil) {
        
        NSLog(@"该下载已经存在");
        
        return;
        
    }
    
    downloader = [[HJConnectionDownloader alloc]init];
    
    //3.将下载任务保存到缓冲池
    [self.downloaderCache setObject:downloader forKey:url.path];
    
    [downloader downloadWithURL:url Progress:progress completion:^(NSString *filePath) {
        
        [self.downloaderCache removeObjectForKey:url.path];
        
        if (completion) {
            completion(filePath);
        }
        
    } failed:^(NSString *errorMsg) {
        
        [self.downloaderCache removeObjectForKey:url.path];
        
        if (failed) {
            
            failed(errorMsg);
            
        }
        
    }];
    
}

-(void)pauserWithURL:(NSURL *)url {

    HJConnectionDownloader *download = self.downloaderCache[url.path];
    
    if (download == nil) {
        if (self.failedBlock) {
            self.failedBlock(@"该请求不存在");
        }
        
        return;
    }
    
    [download pause];
    
    [self.downloaderCache removeObjectForKey:url.path];

}

/** 多条线程下载同一个任务 */
-(void)downloadWithURL:(NSURL *)url{

    [self serverFileInforthURL:url];

}

//检查服务器文件大小
-(void)serverFileInforthURL:(NSURL *)url{
    //请求服务器
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    request.HTTPMethod = @"HEAD";
    
    NSURLResponse *responsetemp = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&responsetemp error:NULL];
    
    
    long long size = responsetemp.expectedContentLength;
    
    long long nodeSize = floor(size/2);
    
    for (int i=0; i<2; i++) {
        
        HWJ * hj = [[HWJ alloc]init];
        
        hj.start = 0.0;
        
        hj.end = nodeSize;
        
        if (i == 1) {
            
            hj.start = nodeSize + 1;
            
            hj.end = -1;
            
        }
        
        hj.response = responsetemp;
        
        [hj downloadWithURL:url];
        
    }
    
}


@end
