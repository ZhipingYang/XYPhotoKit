//
//  CKPhotoCameraOverlayView.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 11/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoCameraOverlayView.h"
#import "CKPhotoSelectedAssetManager.h"
#import "CKPhotoDataCategory.h"
#import "CKPhotoKitHelper.h"

@interface CKPhotoCameraOverlayView()

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIButton *flashSwitchButton;
@property (nonatomic, strong) UIButton *deviceSwitchButton;

@property (nonatomic, strong) UIView *bottomContentView;
@property (nonatomic, strong) CKPhotoSelectedAssetPreviewView *bottomPreview;

@property (nonatomic, strong) UIButton *shutter;
@property (nonatomic, strong) UILabel *selectedScriptLabel;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation CKPhotoCameraOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self initBaseUIElements:frame];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedAssetsChanged) name:CKPhotoMultiImagePickerNotifications.assetsChanged object:nil];
	}
	return self;
}

- (void)initBaseUIElements:(CGRect)frame
{
	// top
	_topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
	_topBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
	[self addSubview:_topBar];
	
	_flashSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_flashSwitchButton setImage:[UIImage xy_imageWithName:@"cl_photo_picker_camera_flash"] forState:UIControlStateNormal];
	[_flashSwitchButton setTitle:@"自动" forState:UIControlStateNormal];
	_flashSwitchButton.titleLabel.font = [UIFont systemFontOfSize:14];
	_flashSwitchButton.frame = CGRectMake(0, 0, 80, 40);
	[_flashSwitchButton addTarget:self action:@selector(flashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	[_topBar addSubview:_flashSwitchButton];
	
	// 前置摄像头是否可以闪光
	if (![UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
		_flashSwitchButton.hidden = YES;
	}
	
	// 判断是否支持前置摄像头
	if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
		_deviceSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_deviceSwitchButton setImage:[UIImage xy_imageWithName:@"cl_photo_picker_camera_devicemode"] forState:UIControlStateNormal];
		_deviceSwitchButton.frame = CGRectMake(_topBar.frame.size.width-60, 0, 60, 40);
		[_deviceSwitchButton addTarget:self action:@selector(cameraDeviceClick:) forControlEvents:UIControlEventTouchUpInside];
		[_topBar addSubview:_deviceSwitchButton];
	}
	
	// bottom
	_bottomContentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-140, self.frame.size.width, 140)];
	_bottomContentView.backgroundColor = [UIColor blackColor];
	[self addSubview:_bottomContentView];

	[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
			if (status == PHAuthorizationStatusAuthorized) {
				_bottomPreview = [[CKPhotoSelectedAssetPreviewView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60)];
				_bottomPreview.hideControls = YES;
				_bottomPreview.backgroundColor = [UIColor blackColor];
				_bottomPreview.delegate = _delegate;
				[_bottomContentView addSubview:_bottomPreview];
				
				_selectedScriptLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, CGRectGetMaxY(_bottomPreview.frame), self.frame.size.width-8*2, 14)];
				_selectedScriptLabel.textColor = [UIColor whiteColor];
				_selectedScriptLabel.font = [UIFont systemFontOfSize:14];
				_selectedScriptLabel.textAlignment = NSTextAlignmentRight;
				[_bottomContentView addSubview:_selectedScriptLabel];
				
				[self selectedAssetsChanged];
				
			} else {
				[UIAlertController xy_showAlertPhotoSettingIfUnauthorized];
			}
			
		});
	}];
	
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_closeButton.frame = CGRectMake(0, _bottomContentView.frame.size.height-64, 120, 64);
	[_closeButton setTitle:@"取消" forState:UIControlStateNormal];
	[_closeButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	[_bottomContentView addSubview:_closeButton];
	
	_shutter = [UIButton buttonWithType:UIButtonTypeCustom];
	_shutter.frame = CGRectMake((_bottomContentView.frame.size.width-64)/2.0, _bottomContentView.frame.size.height-64, 64, 64);
	[_shutter setImage:[UIImage xy_imageWithName:@"cl_photo_picker_shutter"] forState:UIControlStateNormal];
	[_shutter setImage:[UIImage xy_imageWithName:@"cl_photo_picker_shutter_h"] forState:UIControlStateHighlighted];
	[_shutter addTarget:self action:@selector(shutterClick:) forControlEvents:UIControlEventTouchUpInside];
	[_bottomContentView addSubview:_shutter];
	
	_doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_doneButton.frame = CGRectMake(_bottomContentView.frame.size.width-120, _bottomContentView.frame.size.height-64, 120, 64);
	[_doneButton setTitle:@"完成" forState:UIControlStateNormal];
	[_doneButton addTarget:self action:@selector(finishedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	[_bottomContentView addSubview:_doneButton];
}

- (void)didMoveToWindow
{
	[super didMoveToWindow];
	_bottomPreview.assetArray = [CKPhotoSelectedAssetManager sharedManager].selectedAssets;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *view = [super hitTest:point withEvent:event];
	return view==self ? nil:view;
}

#pragma mark - set

- (void)setFlashMode:(UIImagePickerControllerCameraFlashMode)flashMode
{
	_flashMode = flashMode;
	switch (_flashMode) {
		case UIImagePickerControllerCameraFlashModeAuto:{
			[_flashSwitchButton setTitle:@"自动" forState:UIControlStateNormal];
		}
			break;
		case UIImagePickerControllerCameraFlashModeOn:{
			[_flashSwitchButton setTitle:@"打开" forState:UIControlStateNormal];
		}
			break;
		case UIImagePickerControllerCameraFlashModeOff:{
			[_flashSwitchButton setTitle:@"关闭" forState:UIControlStateNormal];
		}
			break;
		default:
			break;
	}
}

- (void)setCameraDeivce:(UIImagePickerControllerCameraDevice)cameraDeivce
{
	_cameraDeivce = cameraDeivce;
	_flashSwitchButton.hidden = ![UIImagePickerController isFlashAvailableForCameraDevice:_cameraDeivce];
}

- (void)setDelegate:(id<CKPhotoCameraOverlayViewDelegate>)delegate
{
	_delegate = delegate;
	_bottomPreview.delegate = delegate;
}

#pragma mark - actions

- (void)flashButtonClick:(UIButton *)sender
{
	if ([_delegate respondsToSelector:@selector(cameraOverlayView:didSwitchedFlashMode:)] && [UIAlertController xy_showAlertCameraSettingIfUnauthorized]) {
		
		switch (_flashMode) {
			case UIImagePickerControllerCameraFlashModeAuto:{
				self.flashMode = UIImagePickerControllerCameraFlashModeOn;
			}
				break;
			case UIImagePickerControllerCameraFlashModeOn:{
				self.flashMode = UIImagePickerControllerCameraFlashModeOff;
			}
				break;
			case UIImagePickerControllerCameraFlashModeOff:{
				self.flashMode = UIImagePickerControllerCameraFlashModeAuto;
			}
				break;
			default:
				break;
		}
		[_delegate cameraOverlayView:self didSwitchedFlashMode:_flashMode];
	}
}

- (void)cameraDeviceClick:(UIButton *)sender
{
	if ([_delegate respondsToSelector:@selector(cameraOverlayView:didSwitchedCameraDeivce:)] && [UIAlertController xy_showAlertCameraSettingIfUnauthorized]) {
		self.cameraDeivce = _cameraDeivce == UIImagePickerControllerCameraDeviceRear ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		self.flashSwitchButton.hidden = ![UIImagePickerController isFlashAvailableForCameraDevice:_cameraDeivce];
		[_delegate cameraOverlayView:self didSwitchedCameraDeivce:_cameraDeivce];
	}
}

- (void)cancelButtonClick:(UIButton *)sender
{
	if ([_delegate respondsToSelector:@selector(canceledCameraOverlayView:)]) {
		[_delegate canceledCameraOverlayView:self];
	}
}

- (void)finishedButtonClick:(UIButton *)sender
{
	if ([_delegate respondsToSelector:@selector(finishedCameraOverlayView:)]) {
		[_delegate finishedCameraOverlayView:self];
	}
}

- (void)shutterClick:(UIButton *)sender
{
	if ([_delegate respondsToSelector:@selector(cameraOverlayView:didShutted:)] && [UIAlertController xy_showAlertCameraSettingIfUnauthorized]) {
		[_delegate cameraOverlayView:self didShutted:sender];
	}
}


#pragma mark - Notification

- (void)selectedAssetsChanged
{
	NSArray *assets = [CKPhotoSelectedAssetManager sharedManager].selectedAssets;
	NSInteger max = (NSInteger)[CKPhotoSelectedAssetManager sharedManager].maxNumberOfAssets;
	if (max==0) {
		_selectedScriptLabel.text = @(assets.count).stringValue;
	} else {
		_selectedScriptLabel.text = [NSString stringWithFormat:@"(%zd / %zd)",assets.count,max];
	}
}


@end
