//
//  XYPhotoHorizontalScrollItemView.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 07/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoHorizontalScrollItemView.h"
#import "XYPhotoKitHelper.h"
#import "XYPhotoSelectedAssetManager.h"
#import "XYPhotoDataCategory.h"

@import AVKit;
@interface XYPhotoHorizontalScrollItemView()<UIScrollViewDelegate>

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) UIButton *playVideoButton;
@property (nonatomic, assign) PHImageRequestID imageRequestId;

@end

@implementation XYPhotoHorizontalScrollItemView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.delegate = self;
		self.minimumZoomScale = 1.f;
		self.maximumZoomScale = 2.f;
		self.showsHorizontalScrollIndicator = false;
		self.showsVerticalScrollIndicator = false;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.backgroundColor = [UIColor blackColor];
		
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.width-10, self.frame.size.height)];
		_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		_imageView.backgroundColor = [UIColor blackColor];
		[self addSubview:_imageView];
		
		_playVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_playVideoButton setImage:[UIImage xy_imageWithName:@"cl_photokit_play"] forState:UIControlStateNormal];
		_playVideoButton.frame = CGRectMake((self.frame.size.width-100)/2.f, (self.frame.size.height-100)/2.f, 100, 100);
		_playVideoButton.hidden = true;
		[_playVideoButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_playVideoButton];
		
		_imageManager = [[PHCachingImageManager alloc] init];
	}
	return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(viewWasTapped) object:nil];
	if (touch.tapCount==1) {
		[self performSelector:@selector(viewWasTapped) withObject:nil afterDelay:0.2f];
	} else if (touch.tapCount==2) {
		[self viewWasDoubleTapped:touch];
	}
}

- (void)setAsset:(PHAsset *)asset
{
	_asset = asset;
	
	// 防止复用时加载延时图片展示多次
	if (_imageRequestId!=0) {
		[self.imageManager cancelImageRequest:_imageRequestId];
	}
	
	CGSize size = [UIScreen mainScreen].bounds.size;
	CGFloat scale = [UIScreen mainScreen].scale;
	
	if (asset.mediaType == PHAssetMediaTypeVideo) {
		self.maximumZoomScale = 1;
	} else if (asset.mediaType == PHAssetMediaTypeImage) {
		self.maximumZoomScale = MAX(asset.pixelWidth/(scale*size.width), asset.pixelHeight/(scale*size.height));
		self.maximumZoomScale = MAX(self.maximumZoomScale, 2);
	}
	self.playVideoButton.hidden = asset.mediaType != PHAssetMediaTypeVideo;
	
	// 允许网络请求icould
	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = [XYPhotoSelectedAssetManager sharedManager].allowNetRequestIfiCloud;
	
	_imageRequestId = [self.imageManager requestImageForAsset:asset
												   targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
												  contentMode:PHImageContentModeAspectFit
													  options:options
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downloadFinined) {
            self.imageRequestId = 0;
        }
        if (result) { self.imageView.image = result; }
    }];
}

#pragma mark - actions

- (void)viewWasTapped
{
	if ([_photokitDelegate respondsToSelector:@selector(didTapped:)]) {
		[_photokitDelegate didTapped:self];
	}
}

- (void)viewWasDoubleTapped:(UITouch *)touch
{
	if (_asset.mediaType == PHAssetMediaTypeImage) {
		[self zoomToLocation:[touch locationInView:self]];
	}
}

- (void)playAction
{
	if (_asset.mediaType != PHAssetMediaTypeVideo) {
		return;
	}
	
	PHAsset *videoAsset = _asset;
	PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
	options.networkAccessAllowed = [XYPhotoSelectedAssetManager sharedManager].allowNetRequestIfiCloud;
	options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
	
	[[PHImageManager defaultManager] requestAVAssetForVideo:videoAsset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
			AVPlayer *player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
			AVPlayerViewController *playerViewController = [AVPlayerViewController new];
			playerViewController.player = player;
			[[UIApplication sharedApplication].xy_topViewController presentViewController:playerViewController animated:NO completion:^{
				[player play];
			}];
		});
	}];
}

#pragma mark - private

- (void)zoomToLocation:(CGPoint)location
{
	float newScale;
	CGRect zoomRect;
	if ([self isZoomed]) {
		zoomRect = self.bounds;
	} else {
		newScale = [self maximumZoomScale];
		zoomRect = [self zoomRectForScale:newScale withCenter:location];
	}
	[self zoomToRect:zoomRect animated:YES];
}

- (BOOL)isZoomed
{
	return !([self zoomScale] == [self minimumZoomScale]);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
	CGRect zoomRect;
	zoomRect.size.height = _imageView.frame.size.height / scale;
	zoomRect.size.width  = _imageView.frame.size.width / scale;
	zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
	zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0)-30;
	
	return zoomRect;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	if (_imageView.image) {
		return _imageView;
	}
	return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize size = _imageView.frame.size;
	CGFloat top = floor((MAX(scrollView.contentSize.height, scrollView.frame.size.height)-_imageView.frame.size.height)/2);
	CGFloat left = floor((MAX(scrollView.contentSize.width, scrollView.frame.size.width)-_imageView.frame.size.width)/2);
    _imageView.frame = CGRectMake(top, left, size.width, size.height);
}

@end
