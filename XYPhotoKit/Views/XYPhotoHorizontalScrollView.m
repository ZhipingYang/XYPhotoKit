//
//  XYPhotoHorizontalScrollView.m
//  YHHB
//
//  Created by Hunter Huang on 11/30/11.
//  Copyright (c) 2011 vge design. All rights reserved.
//

#import "XYPhotoHorizontalScrollView.h"

static const NSInteger preloadanswerNum = 1;

@interface XYPhotoHorizontalScrollView() <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableSet *reusableViews;
@property (nonatomic, assign) NSInteger firstVisibleIndex;
@property (nonatomic, assign) NSInteger lastVisibleIndex;

@end

@interface UINavigationController ()

- (BOOL)horizontalScrollView:(UIScrollView *)scrollView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

@end

@implementation XYPhotoHorizontalScrollView

@synthesize horizontalDelegate, horizontalDataSource, reusableViews, currentIndex;
@synthesize firstVisibleIndex, lastVisibleIndex, viewPadding;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = YES;
        self.scrollsToTop = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.reusableViews = [NSMutableSet set];
        self.delegate = self;
        
        firstVisibleIndex = NSIntegerMax;
        lastVisibleIndex  = NSIntegerMin;
    }
    return self;
}

#pragma mark - public

//强制固定contentInset为zero
- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:UIEdgeInsetsZero];
}

//强制固定contentOffset为zero
- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:CGPointMake(contentOffset.x, 0)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect visibleBounds = [self bounds];
    CGFloat visibleWidth = visibleBounds.size.width;
    CGFloat visibleHeight = visibleBounds.size.height;
    
    NSInteger answerNum = horizontalDataSource?[horizontalDataSource numberOfItems]:0;
    self.contentSize = CGSizeMake(answerNum*visibleWidth, visibleHeight);
    
    CGFloat leftDelta = visibleBounds.origin.x-visibleWidth*preloadanswerNum;
    CGFloat extendedVisibleWidth = (preloadanswerNum*2+1)*visibleWidth;
    if (leftDelta < 0) {
        extendedVisibleWidth += leftDelta;
    }
    CGRect extendedVisibleBounds = CGRectMake(MAX(0, visibleBounds.origin.x-preloadanswerNum*visibleWidth), 0, extendedVisibleWidth, visibleHeight);
    // Recycle all views that are no longer visible
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[XYHorizontalScrollItemView class]]||[view conformsToProtocol:@protocol(XYHorizontalScrollItemInterface)]) {
            CGRect viewFrame = [view frame];
            // If the view doesn't intersect, it's not visible, so we can recycle it
            if (! CGRectIntersectsRect(viewFrame, extendedVisibleBounds)) {
                [view removeFromSuperview];
                if (reusableViews.count<5) {
                    [reusableViews addObject:view];
                }
            }
        }
    }
    
    int startIndex = MAX(0, floorf((extendedVisibleBounds.origin.x)/visibleWidth));
    int endIndex = MIN(answerNum, ceilf((extendedVisibleBounds.origin.x+extendedVisibleBounds.size.width)/visibleWidth));// 预加载2张
    
    for (int index = startIndex; index < endIndex; index++) {
        BOOL isItemViewMissing = index < firstVisibleIndex || index >= lastVisibleIndex;
        if (isItemViewMissing) {
            id<XYHorizontalScrollItemInterface> itemView = nil;
            if (horizontalDataSource) {
                itemView = [horizontalDataSource horizontalScrollView:self itemViewForIndex:index];
            }
            // Set the frame so the view is inserted into the correct position.
            itemView.index = index;
            [(UIView *)itemView setTag:index+1000];
            [(UIView *)itemView setFrame:CGRectMake(index*visibleWidth+viewPadding, 0, visibleWidth-viewPadding*2, visibleHeight)];
            [self addSubview:(UIView *)itemView];
        }
    }
    
    // Remember which thumb view indexes are visible.
    firstVisibleIndex = startIndex;
    lastVisibleIndex  = endIndex;
}


#pragma mark - public 复用

- (id<XYHorizontalScrollItemInterface>)dequeueReusableItemView {
    XYHorizontalScrollItemView *view = [reusableViews anyObject];
    if (view) {
        [reusableViews removeObject:view];
    }
    return view;
}

//清空复用
- (void)clearMemory
{
    [reusableViews removeAllObjects];
    reusableViews = [NSMutableSet set];
}

- (void)reloadData
{
    [self enqueueReusableItemViews];
    // force to call layoutSubviews
    [self layoutSubviews];
}

- (void)resizeToFrame:(CGRect)rect animated:(BOOL)animated duration:(float)duration
{
    if (animated) {
        [UIView animateWithDuration:duration animations:^{
            self.frame = rect;
        }];
    } else {
        self.frame = rect;
    }
    
    self.contentOffset = CGPointMake(currentIndex*self.frame.size.width, 0);
    
    [UIView animateWithDuration:animated?duration:0 animations:^{
        for (NSInteger i=0, c=[self.subviews count]; i<c; i++) {
            XYHorizontalScrollItemView *view = [self.subviews objectAtIndex:i];
            if ([view isKindOfClass:[XYHorizontalScrollItemView class]]||[view conformsToProtocol:@protocol(XYHorizontalScrollItemInterface)]) {
                view.frame = CGRectMake([view index]*self.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                if ([view index] == self.currentIndex) {
                    [view setFrame:CGRectMake([view index]*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
                } else {
                    [view setHidden:YES];
                    [view setFrame:CGRectMake([view index]*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
                }
                if ([view respondsToSelector:@selector(viewWillResize)]) {
                    [view performSelector:@selector(viewWillResize) withObject:nil];
                }
            }
        }
    } completion:^(BOOL finished) {
        for (NSInteger i=0, c=[self.subviews count]; i<c; i++) {
            XYHorizontalScrollItemView *view = [self.subviews objectAtIndex:i];
            if ([view isKindOfClass:[XYHorizontalScrollItemView class]]||[view conformsToProtocol:@protocol(XYHorizontalScrollItemInterface)]) {
                view.frame = CGRectMake([view index]*self.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                if ([view index] != self.currentIndex) {
                    [view setHidden:NO];
                }
            }
        }
    }];
    
}

#pragma mark - public setIndex

- (void)setCurrentIndex:(NSInteger)index
{
    if (index<0) {
        return;
    }
    [self setCurrentIndex:index animated:NO];
}

- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated
{
    [self setCurrentIndex:index animated:animated event:NO];
}

//主动设置scrollView 滚动,不触发scrollRectToVisible:animated: 动画
- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated event:(BOOL)event
{
    if (index<0) {
        return;
    }
    currentIndex = index;
    CGRect rect = self.bounds;
    rect.origin.x = rect.size.width * currentIndex;
    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            [self scrollRectToVisible:rect animated:NO];
        } completion:^(BOOL finished){
            if (finished&&event) {
                if ([horizontalDelegate respondsToSelector:@selector(horizontalScrollView:didSelectIndex:)]) {
                    [horizontalDelegate horizontalScrollView:self didSelectIndex:currentIndex];
                }
            }
        }];
    } else {
        [self scrollRectToVisible:rect animated:NO];
        if (event) {
            if ([horizontalDelegate respondsToSelector:@selector(horizontalScrollView:didSelectIndex:)]) {
                [horizontalDelegate horizontalScrollView:self didSelectIndex:currentIndex];
            }
        }
    }
    
    if (!animated) {
        [self layoutSubviews];
    }
    
}

- (id<XYHorizontalScrollItemInterface>)currentItemView
{
    return [self findViewWithTag:1000+currentIndex];
}

#pragma mark - private

- (void)enqueueReusableItemViews {
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[XYHorizontalScrollItemView class]]||[view conformsToProtocol:@protocol(XYHorizontalScrollItemInterface)]) {
            [view removeFromSuperview];
            if (reusableViews.count<5) {
                [reusableViews addObject:view];
            }
        }
    }
    
    firstVisibleIndex = NSIntegerMax;
    lastVisibleIndex  = NSIntegerMin;
}


- (id<XYHorizontalScrollItemInterface>)findViewWithTag:(NSUInteger)tag
{
    for (UIView *sub in self.subviews) {
        if (([sub isKindOfClass:[XYHorizontalScrollItemView class]]||[sub conformsToProtocol:@protocol(XYHorizontalScrollItemInterface)]) && sub.tag==tag) {
            return (id<XYHorizontalScrollItemInterface>)sub;
        }
    }
    return nil;
}

- (void)updateCurrentIndex
{
    int index = floorf((self.contentOffset.x+self.frame.size.width/2)/self.frame.size.width);
    if (index != currentIndex && index >= 0 && index<(horizontalDataSource?[horizontalDataSource numberOfItems]:0)) {
        currentIndex = index;
        if ([horizontalDelegate respondsToSelector:@selector(horizontalScrollView:willSelectIndex:)]) {
            [horizontalDelegate horizontalScrollView:self willSelectIndex:currentIndex];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDragging) {
        [self updateCurrentIndex];
    }
    if ([self.horizontalDelegate respondsToSelector:@selector(horizontalScrollViewDidScroll:)]) {
        [self.horizontalDelegate horizontalScrollViewDidScroll:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updateCurrentIndex];
        if ([self.horizontalDelegate respondsToSelector:@selector(horizontalScrollViewDidEndDragging:)]) {
            [self.horizontalDelegate horizontalScrollViewDidEndDragging:self];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateCurrentIndex];
    //停止滚动的代理
    if ([horizontalDelegate respondsToSelector:@selector(horizontalScrollView:didSelectIndex:)]) {
        [horizontalDelegate horizontalScrollView:self didSelectIndex:currentIndex];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([self.horizontalDelegate respondsToSelector:@selector(horizontalScrollViewWillBeginDragging:)]) {
        [self.horizontalDelegate horizontalScrollViewWillBeginDragging:self];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

@end

@implementation XYHorizontalScrollItemView

- (void)viewDidShow
{
    
}

- (void)viewDidHidden
{
    
}

- (void)viewWillResize
{
    
}

@end
