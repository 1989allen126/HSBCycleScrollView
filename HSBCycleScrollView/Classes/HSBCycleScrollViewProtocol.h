//
//  HSBCycleScrollViewProtocol.h
//  HSBCycleScrollView
//
//  Created by apple on 2021/4/12.
//  Copyright © 2021 1989allen126. All rights reserved.
//

#ifndef HSBCycleScrollViewProtocol_h
#define HSBCycleScrollViewProtocol_h
#import <UIKit/UIKit.h>


@class HSBCycleScrollView,HSBCycleScrollViewCell;

typedef NS_ENUM(NSInteger, HSBScrollDirection) {
    HSBScrollDirectionHorizontal = 0,
    HSBScrollDirectionVertical
};

@protocol HSBCycleScrollViewDelegate <NSObject>
@optional

/// 点击某个item
/// @param cycleScrollView 控件
/// @param index 索引
- (void)cycleScrollView:(HSBCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;

/// 当前进度
/// @param cycleScrollView cycleScrollView 控件
/// @param progress 整体进度
- (void)cycleScrollViewDidScroll:(HSBCycleScrollView *)cycleScrollView progress:(CGFloat)progress;

/// 控件变化
/// @param cycleScrollView cycleScrollView 控件
/// @param fromIndex 来源item索引
/// @param toIndex 目标item索引
- (void)cycleScrollView:(HSBCycleScrollView *)cycleScrollView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

/// 如果你需要自定义cell样式，请在实现此代理方法返回你的自定义cell的class
/// @param cycleScrollView cycleScrollView 控件
- (Class)customCollectionViewCellClassForCycleScrollView:(HSBCycleScrollView *)cycleScrollView;

/// 如果你需要自定义cell样式，请在实现此代理方法返回你的自定义cell的Nib。
/// @param cycleScrollView cycleScrollView 控件
- (UINib *)customCollectionViewCellNibForCycleScrollView:(HSBCycleScrollView *)cycleScrollView;


/// 如果你自定义了cell样式，请在实现此代理方法为你的cell填充数据以及其它一系列设置
/// @param cell cell
/// @param index 对应的索引
/// @param cycleScrollView cycleScrollView 控件
- (void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index cycleScrollView:(HSBCycleScrollView *)cycleScrollView;
@end

#endif /* HSBCycleScrollViewProtocol_h */
