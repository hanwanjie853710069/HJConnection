//
//  HJConnectionDownloader.m
//  HJConnection
//
//  Created by han on 2017/3/9.
//  Copyright © 2017年 han. All rights reserved.
//

#import "HJConnectionDownloader.h"

@interface HJConnectionDownloader()<NSURLConnectionDataDelegate>

@property(nonatomic,assign) long long longlong;             /** 文件大小 */

@property(nonatomic,strong) NSString * filePath;            /** 文件路径 */

@property(nonatomic,assign) long long currentLength;        /** 本地文件大小 */

@property(nonatomic,strong) NSURL * url;                    /** 路径 */

@property(nonatomic,strong) NSOutputStream * stream;        /** 输出流 */

@property(nonatomic,assign) CFRunLoopRef downRunLoopRef;    /** 当前runloop */

@property(nonatomic,copy) void(^progressBlock)(float);      /** 进度 */

@property(nonatomic,copy) void(^filePathp)(NSString *);     /** 文件路径 */

@property(nonatomic,copy) void(^failed)(NSString *);        /** 错误 */

@property(nonatomic,strong) NSURLConnection *connection;

@end

@implementation HJConnectionDownloader

-(void)downloadWithURL:(NSURL *)url
              Progress:(void (^)(float progress))progress
            completion:(void (^)(NSString * filePath))completion
                failed:(void (^)(NSString * errorMsg))failed{
    
    self.progressBlock = progress;
    
    self.filePathp = completion;
    
    self.failed = failed;
    
    self.url = url;
    
    [self serverFileInforthURL:url];
    
    NSLog(@"大小%lld,路径%@",self.longlong,self.filePath);
    
    if ([self checkLocalFileInfo]) { [self downloadFile]; }
    

    
}

/** 下载文件 */
-(void)downloadFile{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:1 timeoutInterval:30];
        
        //设置下载的范围
        NSString *rangeStr = [NSString stringWithFormat:@"bytes=%lld-",self.currentLength];
        
        //设置请求头字节
        [request setValue:rangeStr forHTTPHeaderField:@"Range"];
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        [self.connection start];
        
        self.downRunLoopRef = CFRunLoopGetCurrent();
        
        CFRunLoopRun();
        
    });
    
}

//检查本地文件信息YES需要下载No不需要下载
-(BOOL)checkLocalFileInfo{
    
    long long size = 0;
    
    //文件是否存在
    if([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]){
        //获取文件大小
        
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:NULL];
        
        size = [dict fileSize];
        
    }
    
    if (size > self.longlong) {
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
        
    }
    
    self.currentLength = size;
    
    if (size == self.longlong) {
        
        NSLog(@"该文件已经下载过了");
        
        if (self.filePathp) {
            self.filePathp(self.filePath);
        }
        
        return NO;
        
    }
    
    return YES;
}


//检查服务器文件大小
-(void)serverFileInforthURL:(NSURL *)url{
    //请求服务器
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    request.HTTPMethod = @"HEAD";
    
    NSURLResponse *response = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    self.longlong = response.expectedContentLength;
    
    self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
    
}
//接收到服务器的响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    self.stream = [[NSOutputStream alloc]initToFileAtPath:self.filePath append:YES];
    
    [self.stream open];
    
}
//数据拼接
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    
    NSLog(@"%lu",data.length);
    
    [self.stream write:data.bytes maxLength:data.length];
    
    //记录文件长度
    self.currentLength += data.length;
    
    float progress = (float)self.currentLength / self.longlong;
    
    if (self.progressBlock) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.progressBlock(progress);
            
        });
        
    }
    
}

//下载完毕
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    [self.stream close];/** 关闭数据流 */
    
    NSLog(@"下载完毕");
    
    CFRunLoopStop(self.downRunLoopRef);
    
    if (self.filePathp) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.filePathp(self.filePath);
            
        });
        
    }
    
}

//出现错误
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if (self.failed) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.filePathp(error.description);
            
        });
        
    }
    
    [self.stream close];/** 关闭数据流 */
    
    NSLog(@"错误");
    
    CFRunLoopStop(self.downRunLoopRef);
    
}

//下载暂停
- (void)pause{

    [self.connection cancel];
    
}

@end
