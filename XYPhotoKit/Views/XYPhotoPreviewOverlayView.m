//
//  XYPhotoPreviewOverlayView.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 06/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoPreviewOverlayView.h"
#import "XYPhotoSelectedAssetManager.h"
#import "XYPhotoDataCategory.h"

@interface XYPhotoPreviewOverlayView()
{
	UIButton *_rightButton;
	UINavigationItem *_navBarItem;
	PHAsset *_asset;
}
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, strong) XYPhotoSelectedAssetPreviewView *previewView;

@end

@implementation XYPhotoPreviewOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		
        UIImageView *topView = [[UIImageView alloc] init];
        topView.image = [UIImage xy_imageWithColor:[UIColor colorWithWhite:0 alpha:0.5]];
        topView.translatesAutoresizingMaskIntoConstraints = false;
        [self addSubview:topView];

        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton setImage:[UIImage xy_imageWithName:@"cl_photo_picker_unpicked"] forState:UIControlStateNormal];
        [_rightButton setImage:[UIImage xy_imageWithName:@"cl_photo_picker_picked"] forState:UIControlStateSelected];
        [_rightButton addTarget:self action:@selector(selectedStateChanged) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.selected = false;
        
        _navBarItem = [[UINavigationItem alloc] initWithTitle:@"照片预览"];
		_navBarItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
		_navBarItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close:)];
		
		_navBar = [[UINavigationBar alloc] init];
        _navBar.translatesAutoresizingMaskIntoConstraints = false;
        _navBar.barTintColor = [UIColor whiteColor];
		[_navBar setBackgroundImage:[UIImage xy_imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
		[_navBar setShadowImage:[UIImage xy_imageWithColor:[UIColor clearColor]]];
		[_navBar setItems:@[_navBarItem]];
		_navBar.tintColor = [UIColor whiteColor];
		[_navBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
		[self addSubview:_navBar];
		
		_previewView = [[XYPhotoSelectedAssetPreviewView alloc] init];
        _previewView.translatesAutoresizingMaskIntoConstraints = false;
		_previewView.delegate = _delegate;
		_previewView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
		[self addSubview:_previewView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_navBar.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor],
            [_navBar.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor],
            [_navBar.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor],
            [_navBar.heightAnchor constraintEqualToConstant:44],
            [topView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [topView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [topView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [topView.bottomAnchor constraintEqualToAnchor:_navBar.bottomAnchor],
            [_previewView.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor],
            [_previewView.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor],
            [_previewView.heightAnchor constraintEqualToConstant:60],
            [_previewView.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor],
        ]];
	}
	return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *touchView = [super hitTest:point withEvent:event];
	return touchView==self ? nil : touchView;
}

- (void)setDelegate:(id<XYPhotoPreviewOverlayViewDelegate>)delegate
{
	_delegate = delegate;
	_previewView.delegate = delegate;
}

- (void)updateTitleAtIndex:(NSInteger)index sum:(NSInteger)sum
{
	_navBarItem.title = [NSString stringWithFormat:@"%zd / %zd",index+1,sum];
	NSMutableAttributedString *firstAtt = [[NSMutableAttributedString alloc] initWithString:@(index+1).stringValue
																				 attributes:@{
																							  NSForegroundColorAttributeName:[UIColor colorWithWhite:0.9 alpha:1],
																							  NSFontAttributeName:[UIFont boldSystemFontOfSize:17]
																							  }];
	NSAttributedString *secondAtt = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" / %zd",sum]
																	attributes:@{
																				 NSForegroundColorAttributeName:[UIColor colorWithWhite:0.9 alpha:1],
																				 NSFontAttributeName:[UIFont systemFontOfSize:14]
																				 }];
	[firstAtt appendAttributedString:secondAtt];
	
	UILabel *label = [[UILabel alloc] init];
	label.attributedText = firstAtt;
	_navBarItem.titleView = label;
}

#pragma amrk - actions

- (void)selectedStateChanged
{
	if (_rightButton.selected) {
		[[XYPhotoSelectedAssetManager sharedManager] removeSelectedAsset:_asset];
		_rightButton.selected = false;
	} else if ([[XYPhotoSelectedAssetManager sharedManager] addSelectedAsset:_asset]) {
		_rightButton.selected = true;
	}
}

- (void)close:(UIBarButtonItem *)item
{
	if ([self.delegate respondsToSelector:@selector(previewOverlayView:closeBarButtonItemClick:)]) {
		[self.delegate previewOverlayView:self closeBarButtonItemClick:item];
	}
}

#pragma mark - private

- (void)updateSelectedAsset:(PHAsset *)asset
{
	_asset = asset;
	_rightButton.selected = [[XYPhotoSelectedAssetManager sharedManager].selectedAssets containsObject:asset];
	[_previewView scrollToAssetIfNeed:asset];
}

@end
