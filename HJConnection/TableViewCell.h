//
//  TableViewCell.h
//  HJConnection
//
//  Created by han on 2017/3/9.
//  Copyright © 2017年 han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJConnectionDownloader.h"
#import "HJDownloaderManager.h"

@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@property (weak, nonatomic) IBOutlet UIButton *start;

@property (weak, nonatomic) IBOutlet UIButton *stop;

@property(nonatomic,weak) HJConnectionDownloader * connection;

@property(nonatomic,strong) NSString * url;

@end
