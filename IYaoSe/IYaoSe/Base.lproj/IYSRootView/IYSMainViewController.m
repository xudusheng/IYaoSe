//
//  IYSMainViewController.m
//  IYaoSe
//
//  Created by wangrongchao on 15/11/30.
//  Copyright © 2015年 truly. All rights reserved.
//

#import "IYSMainViewController.h"
#import "XDSImageListViewController.h"
#define IMAGE_ITEM_GAP 5

@interface IYSMainViewController ()
@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UICollectionView * collectionView;
@property (strong, nonatomic)NSMutableArray * galleryItemArray;
@end

@implementation IYSMainViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self IYSMainViewControllerDataInit];
    [self createIYSMainViewControllerUI];
    
    //    [self imageListRequest];
}

#pragma mark - UI相关
- (void)createIYSMainViewControllerUI{
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - 代理方法

#pragma mark - 网络请求

#pragma mark - 点击事件处理
- (IBAction)imageRequestButtonClick:(UIButton *)button {
    NSArray * urlArray = @[
                           @"http://iphone.myzaker.com/zaker/blog.php?_appid=iphone&_bsize=750_1334&_version=6.4&app_id=405&skey=",
                           @"http://iphone.myzaker.com/zaker/blog.php?_appid=iphone&_bsize=750_1334&_version=6.4&app_id=969&skey=",
                           @"http://iphone.myzaker.com/zaker/blog2news.php?_appid=iphone&_bsize=750_1334&_version=6.4&app_id=1156&nt=1&since_date=1447638882"
                           ];
    
    XDSImageListViewController * imageListVC = [[XDSImageListViewController alloc]init];
    imageListVC.requestURL = urlArray[button.tag];
    //    [self.navigationController pushViewController:imageListVC animated:YES];
    [self presentViewController:imageListVC animated:YES completion:nil];
}

#pragma mark - 其他私有方法

#pragma mark - 内存管理相关
- (void)IYSMainViewControllerDataInit{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
