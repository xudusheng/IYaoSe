//
//  XDSImageListViewController.h
//  XDSPractice
//
//  Created by zhengda on 15/11/27.
//  Copyright © 2015年 zhengda. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MHGallerySectionItem : NSObject
@property (nonatomic, strong) NSString *sectionName;
@property (nonatomic, strong) NSArray *galleryItems;


- (id)initWithSectionName:(NSString*)sectionName
                    items:(NSArray*)galleryItems;

@end

@interface XDSImageListViewController : UIViewController

@property(strong, nonatomic)NSString * requestURL;

@end
