//
//  HSBCycleScrollView.m
//  HSBCycleScrollView
//
//  Created by apple on 2021/4/12.
//  Copyright © 2021 1989allen126. All rights reserved.
//

#import "HSBCycleScrollView.h"
#import "HSBCycleScrollViewCell.h"
#import "HSBCycleScrollViewFlowLayout.h"
#if __has_include(<SDWebImage / UIImageView + WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#elif __has_include("UIImageView+WebCache.h")
#import "UIImageView+WebCache.h"
#endif

#define kHSBCycleScrollViewCellReuserIndentify @"HSBCycleScrollViewCell_ID"

@interface HSBCycleScrollView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) HSBCycleScrollViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger fromIndex;
@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, assign) BOOL itemSizeFlag;
@property (nonatomic, assign) NSInteger indexOffset;
@property (nonatomic, assign) BOOL configuredFlag;
@property (nonatomic, assign) NSInteger tempIndex;
@end

@implementation HSBCycleScrollView

/// 初始化实例
/// @param frame 视图大小
/// @param delegate 代理
/// @param placeholderImage 占位图
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame shouldInfiniteLoop:(BOOL)infiniteLoop delegate:(id<HSBCycleScrollViewDelegate>)delegate placeholderImage:(nullable UIImage *)placeholderImage {
    HSBCycleScrollView *cycleScrollView = [[HSBCycleScrollView alloc] initWithFrame:frame shouldInfiniteLoop:infiniteLoop];
    cycleScrollView.delegate = delegate;
    cycleScrollView.placeholderImage = placeholderImage;
    return cycleScrollView;
}

#pragma mark-- Init
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame shouldInfiniteLoop:YES];
}

- (instancetype)initWithFrame:(CGRect)frame shouldInfiniteLoop:(BOOL)infiniteLoop {
    if (self = [super initWithFrame:frame]) {
        _infiniteLoop = infiniteLoop;
        [self initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _infiniteLoop = YES;
        [self initialization];
    }
    return self;
}

- (void)initialization {
    _autoScroll = YES;
    _itemZoomScale = 1.f;
    _allowsDragging = YES;
    _autoScrollInterval = 3.f;
    _pageIndicatorTintColor = [UIColor grayColor];
    _currentPageIndicatorTintColor = [UIColor whiteColor];

    _flowLayout = [[HSBCycleScrollViewFlowLayout alloc] init];
    _flowLayout.minimumLineSpacing = 0.f;
    _flowLayout.minimumInteritemSpacing = 0.f;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    _collectionView.backgroundColor = nil;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = NO;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:_collectionView];

    //注册cell
    [self registerCellClass:[HSBCycleScrollViewCell class] forCellWithReuseIdentifier:kHSBCycleScrollViewCellReuserIndentify];

    _pageControl = [[UIPageControl alloc] init];
    _pageControl.enabled = NO;
    _pageControl.hidesForSinglePage = YES;
    _pageControl.pageIndicatorTintColor = _pageIndicatorTintColor;
    _pageControl.currentPageIndicatorTintColor = _currentPageIndicatorTintColor;
    [self addSubview:_pageControl];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (_itemSizeFlag) {
        _flowLayout.itemSize = _itemSize;
        _flowLayout.headerReferenceSize = CGSizeMake((self.bounds.size.width - _itemSize.width) / 2, (self.bounds.size.height - _itemSize.height) / 2);
        _flowLayout.footerReferenceSize = CGSizeMake((self.bounds.size.width - _itemSize.width) / 2, (self.bounds.size.height - _itemSize.height) / 2);
    } else {
        _flowLayout.itemSize = self.bounds.size;
        _flowLayout.headerReferenceSize = CGSizeZero;
        _flowLayout.footerReferenceSize = CGSizeZero;
    }
    _collectionView.frame = self.bounds;
    _pageControl.frame = CGRectMake(0.f, self.bounds.size.height - 15.f, self.bounds.size.width, 15.f);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil)
        [self removeTimer];
}

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

#pragma mark-- Public Methods
- (void)registerCellClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [_collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (__kindof HSBCycleScrollViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    index = [self changeIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (void)reloadData {
    [self removeTimer];
    [UIView performWithoutAnimation:^{
        [_collectionView reloadData];
    }];
    [_collectionView performBatchUpdates:nil
                              completion:^(BOOL finished) {
                                  [self configuration];
                              }];
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSInteger numberOfAddedCells = [self numberOfAddedCells];
    if (index < 0 || index > _numberOfItems - numberOfAddedCells - 1) {
        NSLog(@"⚠️attempt to scroll to invalid index:%zd", index);
        return;
    }
    [self removeTimer];
    index += numberOfAddedCells / 2;
    UICollectionViewScrollPosition position = [self scrollPosition];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:animated];
    [self addTimer];
}

#pragma mark-- Private Methods
- (UICollectionViewScrollPosition)scrollPosition {
    switch (_scrollDirection) {
        case HSBScrollDirectionVertical:
            return UICollectionViewScrollPositionCenteredVertically;
        default:
            return UICollectionViewScrollPositionCenteredHorizontally;
    }
}

- (NSInteger)changeIndex:(NSInteger)index {
    if (_infiniteLoop && _numberOfItems > 1) {
        if (index == 0) {
            index = _numberOfItems - 6;
        } else if (index == 1) {
            index = _numberOfItems - 5;
        } else if (index == _numberOfItems - 2) {
            index = 0;
        } else if (index == _numberOfItems - 1) {
            index = 1;
        } else {
            index -= 2;
        }
    }
    return index;
}

- (void)configuration {
    _fromIndex = 0;
    _indexOffset = 0;
    _configuredFlag = NO;

    if (_numberOfItems < 2)
        return;

    if (_infiniteLoop) {
        UICollectionViewScrollPosition position = [self scrollPosition];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:NO];
    }

    [self addTimer];
    [self updatePageControl];

    _configuredFlag = YES;
}

- (void)addTimer {
    [self removeTimer];

    if (_numberOfItems < 2 || !_autoScroll || _autoScrollInterval <= 0.f)
        return;

    _timer = [NSTimer scheduledTimerWithTimeInterval:_autoScrollInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)automaticScroll {
    NSInteger index = [self currentIndex] + 1;
    if (!_infiniteLoop && index >= _numberOfItems)
        index = 0;
    UICollectionViewScrollPosition position = [self scrollPosition];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:YES];
}

- (void)removeTimer {
    if (!_timer)
        return;
    [_timer invalidate];
    _timer = nil;
}

- (void)updatePageControl {
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = MAX(0, _numberOfItems - [self numberOfAddedCells]);
    _pageControl.hidden = (_hidesPageControl || _pageControl.numberOfPages < 2);
}

#pragma mark-- UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    _numberOfItems = !self.dataSource ? 0 : self.dataSource.count;
    if (_infiniteLoop && _numberOfItems > 1) {
        _numberOfItems += [self numberOfAddedCells];
    }
    return _numberOfItems;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HSBCycleScrollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHSBCycleScrollViewCellReuserIndentify forIndexPath:indexPath];
    long itemIndex = [self changeIndex:indexPath.item];
    if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:cycleScrollView:)] &&
        [self.delegate respondsToSelector:@selector(customCollectionViewCellClassForCycleScrollView:)] && [self.delegate customCollectionViewCellClassForCycleScrollView:self]) {
        [self.delegate setupCustomCell:cell forIndex:itemIndex cycleScrollView:self];
        return cell;
    } else if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:cycleScrollView:)] &&
               [self.delegate respondsToSelector:@selector(customCollectionViewCellNibForCycleScrollView:)] && [self.delegate customCollectionViewCellNibForCycleScrollView:self]) {
        [self.delegate setupCustomCell:cell forIndex:itemIndex cycleScrollView:self];
        return cell;
    }

    NSString *imagePath = self.dataSource[itemIndex];
    if ([imagePath isKindOfClass:[NSString class]]) {
        if ([imagePath hasPrefix:@"http"]) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.placeholderImage];
        } else {
            UIImage *image = [UIImage imageNamed:imagePath];
            if (!image) {
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
            cell.imageView.image = image;
        }
    } else if ([imagePath isKindOfClass:[UIImage class]]) {
        cell.imageView.image = (UIImage *)imagePath;
    }

    return cell;
}

#pragma mark-- UICollectionView Delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)]) {
        [self removeTimer];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)]) {
        [self addTimer];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)]) {
        NSInteger index = [self changeIndex:indexPath.item];
        [_delegate cycleScrollView:self didSelectItemAtIndex:index];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _pageControl.currentPage = [self pageIndex];
    if (_configuredFlag && [_delegate respondsToSelector:@selector(cycleScrollViewDidScroll:progress:)]) {
        CGFloat total = 0.f, offset = 0.f;
        NSInteger numberOfAddedCells = [self numberOfAddedCells];
        switch (_scrollDirection) {
            case HSBScrollDirectionVertical:
                total = (_numberOfItems - 1 - numberOfAddedCells) * (_flowLayout.itemSize.height + _flowLayout.minimumLineSpacing);
                offset = fmod([self contentOffset].y, (_flowLayout.itemSize.height + _flowLayout.minimumLineSpacing) * (_numberOfItems - numberOfAddedCells));
                break;
            default:
                total = (_numberOfItems - 1 - numberOfAddedCells) * (_flowLayout.itemSize.width + _flowLayout.minimumLineSpacing);
                offset = fmod([self contentOffset].x, (_flowLayout.itemSize.width + _flowLayout.minimumLineSpacing) * (_numberOfItems - numberOfAddedCells));
                break;
        }
        CGFloat percent = offset / total;
        CGFloat progress = percent * (_numberOfItems - 1 - numberOfAddedCells);
        [_delegate cycleScrollViewDidScroll:self progress:progress];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSInteger index = [self currentIndex];
    if (_infiniteLoop) {
        UICollectionViewScrollPosition position = [self scrollPosition];
        if (index == 1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_numberOfItems - 3 inSection:0];
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:NO];
        } else if (index == _numberOfItems - 2) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:NO];
        }
    }
    NSInteger toIndex = [self changeIndex:index];
    if ([_delegate respondsToSelector:@selector(cycleScrollView:didScrollFromIndex:toIndex:)]) {
        [_delegate cycleScrollView:self didScrollFromIndex:_fromIndex toIndex:toIndex];
    }
    _fromIndex = toIndex;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self pageIndex] != _fromIndex)
        return;

    CGFloat sum = velocity.x + velocity.y;
    if (sum > 0) {
        _indexOffset = 1;
    } else if (sum < 0) {
        _indexOffset = -1;
    } else {
        _indexOffset = 0;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSInteger index = [self currentIndex] + _indexOffset;
    index = MAX(0, index);
    index = MIN(_numberOfItems - 1, index);
    UICollectionViewScrollPosition position = [self scrollPosition];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:YES];
    _indexOffset = 0;
}

#pragma mark-- Getter & Setter
- (NSInteger)currentIndex {
    if (_numberOfItems <= 0) {
        return -1;
    }

    NSInteger index = 0;
    NSInteger minimumIndex = 0;
    NSInteger maximumIndex = _numberOfItems - 1;

    if (_numberOfItems == 1) {
        return index;
    }

    if (_infiniteLoop) {
        minimumIndex = 1;
        maximumIndex = _numberOfItems - 2;
    }

    switch (_scrollDirection) {
        case HSBScrollDirectionVertical:
            index = (_collectionView.contentOffset.y + (_flowLayout.itemSize.height + _flowLayout.minimumLineSpacing) / 2) / (_flowLayout.itemSize.height + _flowLayout.minimumLineSpacing);
            break;
        default:
            index = (_collectionView.contentOffset.x + (_flowLayout.itemSize.width + _flowLayout.minimumLineSpacing) / 2) / (_flowLayout.itemSize.width + _flowLayout.minimumLineSpacing);
            break;
    }
    return MIN(maximumIndex, MAX(minimumIndex, index));
}

- (NSInteger)pageIndex {
    return [self changeIndex:[self currentIndex]];
}

- (CGPoint)contentOffset {
    NSInteger numberOfAddedCells = [self numberOfAddedCells];
    switch (_scrollDirection) {
        case HSBScrollDirectionVertical:
            return CGPointMake(0.f, MAX(0.f, _collectionView.contentOffset.y - (_flowLayout.itemSize.height + _flowLayout.minimumLineSpacing) * numberOfAddedCells / 2));
        default:
            return CGPointMake(MAX(0.f, (_collectionView.contentOffset.x - (_flowLayout.itemSize.width + _flowLayout.minimumLineSpacing) * numberOfAddedCells / 2)), 0.f);
    }
}

- (NSInteger)numberOfAddedCells {
    return _infiniteLoop ? 4 : 0;
}

- (void)setScrollDirection:(HSBScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;

    switch (scrollDirection) {
        case HSBScrollDirectionVertical:
            _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
            break;
        default:
            _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            break;
    }
}

- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    [self addTimer];
}

- (void)setAllowsDragging:(BOOL)allowsDragging {
    _allowsDragging = allowsDragging;
    _collectionView.scrollEnabled = allowsDragging;
}

- (void)setAutoScrollInterval:(NSTimeInterval)autoScrollInterval {
    _autoScrollInterval = autoScrollInterval;
    [self addTimer];
}

- (void)setItemSize:(CGSize)itemSize {
    _itemSizeFlag = YES;
    _itemSize = itemSize;
    _flowLayout.itemSize = itemSize;
    _flowLayout.headerReferenceSize = CGSizeMake((self.bounds.size.width - itemSize.width) / 2, (self.bounds.size.height - itemSize.height) / 2);
    _flowLayout.footerReferenceSize = CGSizeMake((self.bounds.size.width - itemSize.width) / 2, (self.bounds.size.height - itemSize.height) / 2);
}

- (void)setItemSpacing:(CGFloat)itemSpacing {
    _itemSpacing = itemSpacing;
    _flowLayout.minimumLineSpacing = itemSpacing;
}

- (void)setItemZoomScale:(CGFloat)itemZoomScale {
    _itemZoomScale = itemZoomScale;
    _flowLayout.zoomScale = itemZoomScale;
}

- (void)setHidesPageControl:(BOOL)hidesPageControl {
    _hidesPageControl = hidesPageControl;
    _pageControl.hidden = hidesPageControl;
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    _pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    _pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setDelegate:(id<HSBCycleScrollViewDelegate>)delegate {
    _delegate = delegate;

    if ([self.delegate respondsToSelector:@selector(customCollectionViewCellClassForCycleScrollView:)] && [self.delegate customCollectionViewCellClassForCycleScrollView:self]) {
        [self.collectionView registerClass:[self.delegate customCollectionViewCellClassForCycleScrollView:self] forCellWithReuseIdentifier:kHSBCycleScrollViewCellReuserIndentify];
    } else if ([self.delegate respondsToSelector:@selector(customCollectionViewCellNibForCycleScrollView:)] && [self.delegate customCollectionViewCellNibForCycleScrollView:self]) {
        [self.collectionView registerNib:[self.delegate customCollectionViewCellNibForCycleScrollView:self] forCellWithReuseIdentifier:kHSBCycleScrollViewCellReuserIndentify];
    }
}
@end
