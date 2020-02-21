//
//  XYPhotoHorizontalScrollView.h
//  YHHB
//
//  Created by Hunter Huang on 11/30/11.
//  Copyright (c) 2011 vge design. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XYPhotoHorizontalScrollViewDataSource;
@protocol XYPhotoHorizontalScrollViewDelegate;
@class XYHorizontalScrollItemView;

@protocol XYHorizontalScrollItemInterface <NSObject>

@property (nonatomic) int index;

@end

@interface XYPhotoHorizontalScrollView : UIScrollView

@property (nonatomic, weak) id<XYPhotoHorizontalScrollViewDataSource> horizontalDataSource;
@property (nonatomic, weak) id<XYPhotoHorizontalScrollViewDelegate> horizontalDelegate;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGFloat viewPadding;

- (id<XYHorizontalScrollItemInterface>)dequeueReusableItemView;

- (void)clearMemory;
- (void)reloadData;

- (void)resizeToFrame:(CGRect)rect animated:(BOOL)animated duration:(float)duration;

- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated event:(BOOL)event; //event 表示是否最终调用 horizontalScrollView:didSelectIndex:

- (id<XYHorizontalScrollItemInterface>)currentItemView;

@end

@protocol XYPhotoHorizontalScrollViewDataSource <NSObject>

- (NSInteger)numberOfItems;
- (id<XYHorizontalScrollItemInterface>)horizontalScrollView:(XYPhotoHorizontalScrollView *)scroller itemViewForIndex:(NSInteger)index;

@end

@protocol XYPhotoHorizontalScrollViewDelegate <NSObject>

@optional

- (void)horizontalScrollView:(XYPhotoHorizontalScrollView *)scroller willSelectIndex:(NSInteger)index;
- (void)horizontalScrollView:(XYPhotoHorizontalScrollView *)scroller didSelectIndex:(NSInteger)index;

- (void)horizontalScrollViewWillBeginDragging:(XYPhotoHorizontalScrollView *)scroller;   //类比 scrollViewWillBeginDragging:
- (void)horizontalScrollViewDidEndDragging:(XYPhotoHorizontalScrollView *)scroller;      //类比 scrollViewDidEndDragging:willDecelerate:
- (void)horizontalScrollViewDidScroll:(XYPhotoHorizontalScrollView *)scroller;           //类比 scrollViewDidScroll:

@end

@interface XYHorizontalScrollItemView : UIView <XYHorizontalScrollItemInterface>

@property (nonatomic) int index;

- (void)viewWillResize;

@end
