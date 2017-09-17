//
//  CKHorizontalScrollView.h
//  YHHB
//
//  Created by Hunter Huang on 11/30/11.
//  Copyright (c) 2011 vge design. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKHorizontalScrollViewDataSource;
@protocol CKHorizontalScrollViewDelegate;
@class CKHorizontalScrollItemView;

@protocol CKHorizontalScrollItemInterface <NSObject>

@property (nonatomic) int index;

@end

@interface CKHorizontalScrollView : UIScrollView 

@property (nonatomic, weak) id<CKHorizontalScrollViewDataSource> horizontalDataSource;
@property (nonatomic, weak) id<CKHorizontalScrollViewDelegate> horizontalDelegate;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGFloat viewPadding;

- (id<CKHorizontalScrollItemInterface>)dequeueReusableItemView;

- (void)clearMemory;
- (void)reloadData;

- (void)resizeToFrame:(CGRect)rect animated:(BOOL)animated duration:(float)duration;

- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated event:(BOOL)event; //event 表示是否最终调用 horizontalScrollView:didSelectIndex:

- (id<CKHorizontalScrollItemInterface>)currentItemView;

@end

@protocol CKHorizontalScrollViewDataSource <NSObject>

- (NSInteger)numberOfItems;
- (id<CKHorizontalScrollItemInterface>)horizontalScrollView:(CKHorizontalScrollView *)scroller itemViewForIndex:(NSInteger)index;

@end

@protocol CKHorizontalScrollViewDelegate <NSObject>

@optional

- (void)horizontalScrollView:(CKHorizontalScrollView *)scroller willSelectIndex:(NSInteger)index;
- (void)horizontalScrollView:(CKHorizontalScrollView *)scroller didSelectIndex:(NSInteger)index;

- (void)horizontalScrollViewWillBeginDragging:(CKHorizontalScrollView *)scroller;   //类比 scrollViewWillBeginDragging:
- (void)horizontalScrollViewDidEndDragging:(CKHorizontalScrollView *)scroller;      //类比 scrollViewDidEndDragging:willDecelerate:
- (void)horizontalScrollViewDidScroll:(CKHorizontalScrollView *)scroller;           //类比 scrollViewDidScroll:

@end

@interface CKHorizontalScrollItemView : UIView <CKHorizontalScrollItemInterface>

@property (nonatomic) int index;

- (void)viewWillResize;

@end
