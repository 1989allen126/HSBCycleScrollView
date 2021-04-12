//
//  HSBCycleScrollView.h
//  HSBCycleScrollView
//
//  Created by apple on 2021/4/12.
//  Copyright © 2021 1989allen126. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HSBCycleScrollView/HSBCycleScrollViewProtocol.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface HSBCycleScrollView : UIView

/// 初始化实例
/// @param frame 视图大小
/// @param delegate 代理
/// @param placeholderImage 占位图
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame shouldInfiniteLoop:(BOOL)infiniteLoop delegate:(id<HSBCycleScrollViewDelegate>)delegate placeholderImage:(nullable UIImage *)placeholderImage;

@property (nullable, nonatomic, weak) IBOutlet id<HSBCycleScrollViewDelegate> delegate;

#if TARGET_INTERFACE_BUILDER
@property (nonatomic, assign) IBInspectable NSInteger scrollDirection;
@property (nonatomic, assign) IBInspectable double autoScrollInterval;
#else
@property (nonatomic, assign) HSBScrollDirection scrollDirection; // 滚动方向，默认水平
@property (nonatomic, assign) NSTimeInterval autoScrollInterval;  // 自动滚动时间间隔，默认3s
#endif

@property (nonatomic, assign) IBInspectable BOOL autoScroll;      // 自动滚动，默认YES
@property (nonatomic, assign) IBInspectable BOOL allowsDragging;  // 运行拖拽，默认YES
@property (nonatomic, readonly, assign) IBInspectable BOOL infiniteLoop; // 无限循环，默认YES

@property (nonatomic, assign) IBInspectable CGSize  itemSize;     // item大小，默认视图大小
@property (nonatomic, assign) IBInspectable CGFloat itemSpacing;  // 间隔，默认 0.f
@property (nonatomic, assign) IBInspectable CGFloat itemZoomScale;// 缩放比例，默认1.f

@property (nonatomic, assign) IBInspectable BOOL hidesPageControl;// 隐藏页码指示器 NO
@property (nullable, nonatomic, strong) IBInspectable UIColor *pageIndicatorTintColor; // default gray
@property (nullable, nonatomic, strong) IBInspectable UIColor *currentPageIndicatorTintColor; // default white

@property (nonatomic, readonly, assign) NSInteger pageIndex;    // 当前页index
@property (nonatomic, readonly, assign) CGPoint contentOffset;  // 当前偏移量offset

@property (nonatomic, copy) NSArray *dataSource; /**数据源*/

- (void)reloadData;
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
