//
//  XDSImageListViewController.m
//  XDSPractice
//
//  Created by zhengda on 15/11/27.
//  Copyright © 2015年 zhengda. All rights reserved.
//

#import "XDSImageListViewController.h"
#import "MHGallery.h"
#import "AFNetworking.h"
#import "UIScrollView+UzysCircularProgressPullToRefresh.h"
#define IMAGE_ITEM_GAP 5

@implementation MHGallerySectionItem


- (id)initWithSectionName:(NSString*)sectionName
                    items:(NSArray*)galleryItems{
    self = [super init];
    if (!self)
        return nil;
    self.sectionName = sectionName;
    self.galleryItems = galleryItems;
    return self;
}
@end


@interface XDSImageListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MHGalleryDataSource,MHGalleryDelegate>
@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UICollectionView * collectionView;
@property (strong, nonatomic)NSMutableArray * galleryItemArray;
@end

@interface XDSImageListViewController ()

@end

@implementation XDSImageListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self XDSImageListViewControllerDataInit];
    [self createXDSImageListViewControllerUI];
}

#pragma mark - UI相关
- (void)createXDSImageListViewControllerUI{
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc]initWithFrame:_tableView.bounds collectionViewLayout:flowLayout];
    [_collectionView registerClass:[MHMediaPreviewCollectionViewCell class] forCellWithReuseIdentifier:@"MHMediaPreviewCollectionViewCell"];
    _collectionView.pagingEnabled = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self setNeedsStatusBarAppearanceUpdate];
    
    _tableView.tableHeaderView = _collectionView;
    __weak typeof(self) weakSelf =self;
    [_tableView addPullToRefreshActionHandler:^{
        if (weakSelf.galleryItemArray.count) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
//            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [weakSelf imageListRequest];
        }
    } portraitContentInsetTop:0 landscapeInsetTop:0];
    [_tableView triggerPullToRefresh];
}

#pragma mark - 代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  _galleryItemArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHMediaPreviewCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    [self makeOverViewDetailCell:(MHMediaPreviewCollectionViewCell*)cell atIndexPath:indexPath];
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    CGFloat selfViewHeight = CGRectGetHeight(self.view.bounds);
    CGFloat selfViewWidth = CGRectGetWidth(self.view.bounds);
    
    CGSize size = CGSizeZero;
    size.height = selfViewHeight/((index%7 == 6)?2:4) - IMAGE_ITEM_GAP*2;
    switch (index%7) {
        case 0:
        case 1:
        case 2:
        case 3:
            size.width = selfViewWidth/3 - IMAGE_ITEM_GAP*2;
            break;
        default:
            size.width = selfViewWidth*2/3 - IMAGE_ITEM_GAP*2;
            break;
    }
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(IMAGE_ITEM_GAP, IMAGE_ITEM_GAP, IMAGE_ITEM_GAP, IMAGE_ITEM_GAP);
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_main_queue(), ^{
        MHGallerySectionItem *section = self.galleryItemArray[indexPath.row];
        NSArray *galleryData = section.galleryItems;
        if (galleryData.count >0) {
            
            MHGalleryController *gallery = [[MHGalleryController alloc]initWithPresentationStyle:MHGalleryViewModeOverView];
            gallery.galleryItems = galleryData;
            gallery.presentationIndex = indexPath.row;
            
            __weak MHGalleryController *blockGallery = gallery;
            
            gallery.finishedCallback = ^(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode){
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                MHMediaPreviewCollectionViewCell *cell = (MHMediaPreviewCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                [blockGallery dismissViewControllerAnimated:YES dismissImageView:cell.thumbnail completion:^{
                    image?(cell.thumbnail.image = image):0;
                    [self setNeedsStatusBarAppearanceUpdate];
                }];
            };
            
            [self presentMHGalleryController:gallery animated:YES completion:nil];
            
        }
    });
}

-(NSInteger)numberOfItemsInGallery:(MHGalleryController *)galleryController{
    return 10;
}

-(BOOL)galleryController:(MHGalleryController*)galleryController shouldHandleURL:(NSURL *)URL{
    return YES;
}

-(MHGalleryItem *)itemForIndex:(NSInteger)index{
    return [MHGalleryItem itemWithImage:MHGalleryImage(@"twitterMH")];
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    if ([self.presentedViewController isKindOfClass:[MHGalleryController class]]) {
        MHGalleryController *gallerController = (MHGalleryController*)self.presentedViewController;
        return gallerController.preferredStatusBarStyleMH;
    }
    return UIStatusBarStyleDefault;
}
#pragma mark - 网络请求
- (void)imageListRequest{
    AFHTTPSessionManager * httpRequestOperation = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:@""]];
    [httpRequestOperation GET:_requestURL
                   parameters:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          [_tableView stopRefreshAnimation];
                          NSLog(@"responseObject = %@", responseObject);
                          if ([responseObject isKindOfClass:[NSDictionary class]]) {
                              NSDictionary * result = responseObject;
                              NSArray * articles = result[@"data"][@"articles"];
                              [_galleryItemArray removeAllObjects];
                              for (NSDictionary * anArticles in articles) {
                                  NSMutableArray * subImageArray = [NSMutableArray arrayWithCapacity:0];
                                  NSArray * mediaArray = anArticles[@"media"];
                                  for (NSDictionary * aMedia in mediaArray) {
                                      NSString * aSubImageURL = aMedia[@"url"];
                                      MHGalleryItem *item = [[MHGalleryItem alloc]initWithURL:aSubImageURL
                                                                                  galleryType:MHGalleryTypeImage];
                                      [subImageArray addObject:item];
                                  }
                                  MHGallerySectionItem *section = [[MHGallerySectionItem alloc]initWithSectionName:@"你好" items:subImageArray];
                                  [_galleryItemArray addObject:section];
                              }
                          }
                          [_collectionView scrollRectToVisible:self.view.bounds animated:YES];
                          [_collectionView reloadData];
                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          [_tableView stopRefreshAnimation];
                      }];
}
#pragma mark - 点击事件处理

#pragma mark - 其他私有方法
-(void)makeOverViewDetailCell:(MHMediaPreviewCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    MHGallerySectionItem *section = self.galleryItemArray[indexPath.row];
    MHGalleryItem *item = [section.galleryItems firstObject];
    cell.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    cell.thumbnail.image = nil;
    cell.galleryItem = item;
}
#pragma mark - 内存管理相关
- (void)XDSImageListViewControllerDataInit{
//http://iphone.myzaker.com/zaker/blog.php?_appid=iphone&_bsize=750_1334&_version=6.4&app_id=405&skey=  //妖色
//    self.requestURL = @"http://iphone.myzaker.com/zaker/blog.php?_appid=iphone&_bsize=750_1334&_version=6.4&app_id=969&skey=";
    
    self.galleryItemArray = [[NSMutableArray alloc]initWithCapacity:0];
}

- (void)dealloc
{
    NSLog(@"url = %@", _requestURL);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
