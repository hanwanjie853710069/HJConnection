//
//  ViewController.m
//  HJConnection
//
//  Created by han on 2017/3/9.
//  Copyright © 2017年 han. All rights reserved.
//

#import "ViewController.h"
#import "HJConnectionDownloader.h"
#import "HJDownloaderManager.h"
#import "HWJ.h"
//http://127.0.0.1/001--NSURLConnection.wmv.pbb
#define urlPath @"http://sw.bos.baidu.com/sw-search-sp/software/50045684f7da6/QQ_mac_5.4.1.dmg"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (nonatomic, strong) NSFileHandle *writeHandle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
}
- (IBAction)touchStart:(id)sender {
    NSURL *url = [NSURL URLWithString:urlPath];
    
    [[HJDownloaderManager shareDownloaderManager] downloadWithURL:url Progress:^(float progress) {
        NSLog(@"%f",progress);
        
        [self.progress setProgress:progress];
        
    } completion:^(NSString *filePath) {
        NSLog(@"%@",filePath);
    } failed:^(NSString *errorMsg) {
        NSLog(@"%@",errorMsg);
    }];
    
}
- (IBAction)touchstop:(id)sender {
    
    NSURL *url = [NSURL URLWithString:urlPath];
    
    [[HJDownloaderManager shareDownloaderManager] pauserWithURL:url];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [[HJDownloaderManager shareDownloaderManager] downloadWithURL:[NSURL URLWithString:urlPath]];

}


@end
