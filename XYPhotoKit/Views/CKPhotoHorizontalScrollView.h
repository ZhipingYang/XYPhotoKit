//
//  CKPhotoHorizontalScrollView.h
//  YHHB
//
//  Created by Hunter Huang on 11/30/11.
//  Copyright (c) 2011 vge design. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKPhotoHorizontalScrollViewDataSource;
@protocol CKPhotoHorizontalScrollViewDelegate;
@class CKHorizontalScrollItemView;

@protocol CKHorizontalScrollItemInterface <NSObject>

@property (nonatomic) int index;

@end

@interface CKPhotoHorizontalScrollView : UIScrollView 

@property (nonatomic, weak) id<CKPhotoHorizontalScrollViewDataSource> horizontalDataSource;
@property (nonatomic, weak) id<CKPhotoHorizontalScrollViewDelegate> horizontalDelegate;
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

@protocol CKPhotoHorizontalScrollViewDataSource <NSObject>

- (NSInteger)numberOfItems;
- (id<CKHorizontalScrollItemInterface>)horizontalScrollView:(CKPhotoHorizontalScrollView *)scroller itemViewForIndex:(NSInteger)index;

@end

@protocol CKPhotoHorizontalScrollViewDelegate <NSObject>

@optional

- (void)horizontalScrollView:(CKPhotoHorizontalScrollView *)scroller willSelectIndex:(NSInteger)index;
- (void)horizontalScrollView:(CKPhotoHorizontalScrollView *)scroller didSelectIndex:(NSInteger)index;

- (void)horizontalScrollViewWillBeginDragging:(CKPhotoHorizontalScrollView *)scroller;   //类比 scrollViewWillBeginDragging:
- (void)horizontalScrollViewDidEndDragging:(CKPhotoHorizontalScrollView *)scroller;      //类比 scrollViewDidEndDragging:willDecelerate:
- (void)horizontalScrollViewDidScroll:(CKPhotoHorizontalScrollView *)scroller;           //类比 scrollViewDidScroll:

@end

@interface CKHorizontalScrollItemView : UIView <CKHorizontalScrollItemInterface>

@property (nonatomic) int index;

- (void)viewWillResize;

@end
