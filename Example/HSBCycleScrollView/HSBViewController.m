//
//  HSBViewController.m
//  HSBCycleScrollView
//
//  Created by 1989allen126 on 04/12/2021.
//  Copyright (c) 2021 1989allen126. All rights reserved.
//

#import "HSBViewController.h"
#import <HSBCycleScrollView/HSBCycleScrollView.h>

#define SceenWidth [UIScreen mainScreen].bounds.size.width
#define SceenHeight [UIScreen mainScreen].bounds.size.height

@interface HSBViewController ()<HSBCycleScrollViewDelegate>
@property (strong, nonatomic) HSBCycleScrollView *imageCycleScrollView;
@end

@implementation HSBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSArray *imagesURLStrings = @[
                                  @"https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
                                  @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg"
                                  ];
    
    HSBCycleScrollView *imageCycleScrollView = [HSBCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SceenWidth, 300) shouldInfiniteLoop:YES delegate:self placeholderImage:nil];
    imageCycleScrollView.dataSource = imagesURLStrings;
    self.imageCycleScrollView = imageCycleScrollView;
    [self.view addSubview:imageCycleScrollView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 点击某个item
/// @param cycleScrollView 控件
/// @param index 索引
- (void)cycleScrollView:(HSBCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    
}

/// 当前进度
/// @param cycleScrollView cycleScrollView 控件
/// @param progress 整体进度
- (void)cycleScrollViewDidScroll:(HSBCycleScrollView *)cycleScrollView progress:(CGFloat)progress {
    
}

/// 控件变化
/// @param cycleScrollView cycleScrollView 控件
/// @param fromIndex 来源item索引
/// @param toIndex 目标item索引
- (void)cycleScrollView:(HSBCycleScrollView *)cycleScrollView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
}

@end
