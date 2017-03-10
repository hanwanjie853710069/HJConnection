//
//  TableViewCell.m
//  HJConnection
//
//  Created by han on 2017/3/9.
//  Copyright © 2017年 han. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
    
    }
    
    return self;
    
}
- (IBAction)touchStart:(id)sender {
    
    NSURL * nsurl = [NSURL URLWithString:self.url];
    
    [[HJDownloaderManager shareDownloaderManager] downloadWithURL:nsurl Progress:^(float progress) {
        
        [self.progress setProgress:progress];
        NSLog(@"%f",progress);
        
    } completion:^(NSString *filePath) {
        
    } failed:^(NSString *errorMsg) {
        
    }];
    
}

- (IBAction)touchStop:(id)sender {
    
    NSURL * nsurl = [NSURL URLWithString:self.url];
    
    [[HJDownloaderManager shareDownloaderManager]pauserWithURL:nsurl];
    
}

@end
