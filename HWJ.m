//
//  HWJ.m
//  HJConnection
//
//  Created by han on 2017/3/9.
//  Copyright © 2017年 han. All rights reserved.
//

#import "HWJ.h"

@interface HWJ()<NSURLConnectionDataDelegate>

@property(nonatomic,strong) NSString * filePath;            /** 文件路径 */

@property(nonatomic,strong) NSURL * url;                    /** 路径 */

@property(nonatomic,assign) CFRunLoopRef downRunLoopRef;    /** 当前runloop */

@property(nonatomic,strong) NSURLConnection *connection;

@property (nonatomic, strong) NSFileHandle *writeHandle;



@end

@implementation HWJ

-(void)downloadWithURL:(NSURL *)url{

    self.url = url;
    
//    [self serverFileInforthURL:url];
    
    if ([self checkLocalFileInfo]) { [self downloadFile]; }
    
}

/** 下载文件 */
-(void)downloadFile{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:1 timeoutInterval:30];
        
        //设置下载的范围
        NSString *rangeStr = @"";
        
        if (self.end == -1) {
            
            rangeStr = [NSString stringWithFormat:@"bytes=%lld-",self.start];
            
        }else{
            
            rangeStr = [NSString stringWithFormat:@"bytes=%lld-%lld",self.start,self.end];
        
        }
        
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
        
        NSLog(@"%lld",size);
        
    }
    
    return YES;

}

//检查服务器文件大小
-(void)serverFileInforthURL:(NSURL *)url{
    //请求服务器
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:30];
    
    request.HTTPMethod = @"HEAD";
    
    NSURLResponse *responsetemp = nil;
  
    [NSURLConnection sendSynchronousRequest:request returningResponse:&responsetemp error:NULL];
    
    self.response = responsetemp;
    
}
//接收到服务器的响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.response.suggestedFilename];
    
    // 创建一个空的文件到沙盒中
    NSFileManager* mgr = [NSFileManager defaultManager];
    
    [mgr createFileAtPath:self.filePath contents:nil attributes:nil];
    
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    
    [self.writeHandle truncateFileAtOffset:self.response.expectedContentLength];
    
    NSLog(@"%@",self.filePath);
    
    NSLog(@"%lld",self.response.expectedContentLength);
    
}
//数据拼接
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    
    [self.writeHandle seekToFileOffset:self.start];
    
    [self.writeHandle writeData:data];
    
    self.start += data.length;
    
    NSLog(@"%@",[NSThread currentThread]);
    
}

//下载完毕
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSLog(@"下载完毕");
    
    CFRunLoopStop(self.downRunLoopRef);
    
    // 关闭文件
    [self.writeHandle closeFile];
    
    self.writeHandle = nil;
    
}

//出现错误
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"错误");
    
    NSLog(@"%@",error);
    
    // 关闭文件
    [self.writeHandle closeFile];
    
    self.writeHandle = nil;
    
    CFRunLoopStop(self.downRunLoopRef);
    
}

//下载暂停
- (void)pause{
    
    [self.connection cancel];
    
}

@end

