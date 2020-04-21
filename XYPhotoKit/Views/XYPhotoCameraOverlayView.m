//
//  XYPhotoCameraOverlayView.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 11/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYPhotoCameraOverlayView.h"
#import "XYPhotoSelectedAssetManager.h"
#import "XYPhotoDataCategory.h"
#import "XYPhotoKitHelper.h"

@interface XYPhotoCameraOverlayView()

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIButton *flashSwitchButton;
@property (nonatomic, strong) UIButton *deviceSwitchButton;

@property (nonatomic, strong) UIView *bottomContentView;
@property (nonatomic, strong) XYPhotoSelectedAssetPreviewView *bottomPreview;

@property (nonatomic, strong) UIButton *shutter;
@property (nonatomic, strong) UILabel *selectedScriptLabel;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation XYPhotoCameraOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self initBaseUIElements];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedAssetsChanged) name:XYPhotoMultiImagePickerNotifications.assetsChanged object:nil];
	}
	return self;
}

- (void)initBaseUIElements
{
	// top
	_topBar = [[UIView alloc] init];
    _topBar.translatesAutoresizingMaskIntoConstraints = false;
	_topBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
	[self addSubview:_topBar];
    
    _flashSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _flashSwitchButton.translatesAutoresizingMaskIntoConstraints = false;
    [_flashSwitchButton setImage:[UIImage xy_imageWithName:@"cl_photo_picker_camera_flash"] forState:UIControlStateNormal];
    [_flashSwitchButton setTitle:@"自动" forState:UIControlStateNormal];
    _flashSwitchButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_flashSwitchButton addTarget:self action:@selector(flashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_flashSwitchButton];
    
    _deviceSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deviceSwitchButton.translatesAutoresizingMaskIntoConstraints = false;
    [_deviceSwitchButton setImage:[UIImage xy_imageWithName:@"cl_photo_picker_camera_devicemode"] forState:UIControlStateNormal];
    _deviceSwitchButton.frame = CGRectMake(_topBar.frame.size.width-60, 0, 60, 40);
    [_deviceSwitchButton addTarget:self action:@selector(cameraDeviceClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deviceSwitchButton];

    // 前置摄像头是否可以闪光
    if (![UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
        _flashSwitchButton.hidden = true;
    }
    // 判断是否支持前置摄像头
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        _deviceSwitchButton.hidden = true;
    }
    
    // bottom
    _bottomContentView = [[UIView alloc] init];
    _bottomContentView.translatesAutoresizingMaskIntoConstraints = false;
    _bottomContentView.backgroundColor = [UIColor blackColor];
    [self addSubview:_bottomContentView];
	
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.translatesAutoresizingMaskIntoConstraints = false;
	_closeButton.frame = CGRectMake(0, _bottomContentView.frame.size.height-64, 120, 64);
	[_closeButton setTitle:@"取消" forState:UIControlStateNormal];
	[_closeButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	[_bottomContentView addSubview:_closeButton];
	
	_shutter = [UIButton buttonWithType:UIButtonTypeCustom];
    _shutter.translatesAutoresizingMaskIntoConstraints = false;
	_shutter.frame = CGRectMake((_bottomContentView.frame.size.width-64)/2.0, _bottomContentView.frame.size.height-64, 64, 64);
	[_shutter setImage:[UIImage xy_imageWithName:@"cl_photo_picker_shutter"] forState:UIControlStateNormal];
	[_shutter setImage:[UIImage xy_imageWithName:@"cl_photo_picker_shutter_h"] forState:UIControlStateHighlighted];
	[_shutter addTarget:self action:@selector(shutterClick:) forControlEvents:UIControlEventTouchUpInside];
	[_bottomContentView addSubview:_shutter];
	
	_doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.translatesAutoresizingMaskIntoConstraints = false;
	_doneButton.frame = CGRectMake(_bottomContentView.frame.size.width-120, _bottomContentView.frame.size.height-64, 120, 64);
	[_doneButton setTitle:@"完成" forState:UIControlStateNormal];
	[_doneButton addTarget:self action:@selector(finishedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	[_bottomContentView addSubview:_doneButton];
    
    
    //    UIEdgeInsets insets = UIApplication.sharedApplication.keyWindow.safeAreaInsets;
    [NSLayoutConstraint activateConstraints:@[
        [_topBar.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_topBar.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_topBar.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_topBar.bottomAnchor constraintEqualToAnchor:_flashSwitchButton.bottomAnchor],
        
        [_flashSwitchButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor],
        [_flashSwitchButton.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor],
        [_flashSwitchButton.heightAnchor constraintEqualToConstant:40],
        [_flashSwitchButton.widthAnchor constraintEqualToConstant:80],
        
        [_deviceSwitchButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor],
        [_deviceSwitchButton.topAnchor constraintEqualToAnchor:_flashSwitchButton.topAnchor],
        [_deviceSwitchButton.heightAnchor constraintEqualToConstant:40],
        [_deviceSwitchButton.widthAnchor constraintEqualToConstant:60],
        
        [_bottomContentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_bottomContentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_bottomContentView.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor],
        [_bottomContentView.heightAnchor constraintEqualToConstant:140],
        
        [_closeButton.leadingAnchor constraintEqualToAnchor:_bottomContentView.leadingAnchor],
        [_closeButton.bottomAnchor constraintEqualToAnchor:_bottomContentView.bottomAnchor],
        [_closeButton.widthAnchor constraintEqualToConstant:120],
        [_closeButton.heightAnchor constraintEqualToConstant:64],

        [_shutter.centerXAnchor constraintEqualToAnchor:_bottomContentView.centerXAnchor],
        [_shutter.bottomAnchor constraintEqualToAnchor:_bottomContentView.bottomAnchor],
        [_shutter.widthAnchor constraintEqualToConstant:64],
        [_shutter.heightAnchor constraintEqualToConstant:64],

        [_doneButton.trailingAnchor constraintEqualToAnchor:_bottomContentView.trailingAnchor],
        [_doneButton.bottomAnchor constraintEqualToAnchor:_bottomContentView.bottomAnchor],
        [_doneButton.widthAnchor constraintEqualToConstant:120],
        [_doneButton.heightAnchor constraintEqualToConstant:64],
    ]];
    
    dispatch_block_t block = ^{
        self.bottomPreview = [[XYPhotoSelectedAssetPreviewView alloc] init];
        self.bottomPreview.translatesAutoresizingMaskIntoConstraints = false;
        self.bottomPreview.hideControls = true;
        self.bottomPreview.backgroundColor = [UIColor blackColor];
        self.bottomPreview.delegate = self.delegate;
        [self.bottomContentView addSubview:self.bottomPreview];
        
        self.selectedScriptLabel = [[UILabel alloc] init];
        self.selectedScriptLabel.translatesAutoresizingMaskIntoConstraints = false;
        if (@available(iOS 13.0, *)) {
            self.selectedScriptLabel.textColor = [UIColor systemBackgroundColor];
        } else {
            self.selectedScriptLabel.textColor = [UIColor whiteColor];
        }
        self.selectedScriptLabel.font = [UIFont systemFontOfSize:14];
        self.selectedScriptLabel.textAlignment = NSTextAlignmentRight;
        [self.bottomContentView addSubview:self.selectedScriptLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.bottomPreview.trailingAnchor constraintEqualToAnchor:self.bottomContentView.trailingAnchor],
            [self.bottomPreview.leadingAnchor constraintEqualToAnchor:self.bottomContentView.leadingAnchor],
            [self.bottomPreview.topAnchor constraintEqualToAnchor:self.bottomContentView.topAnchor],
            [self.bottomPreview.heightAnchor constraintEqualToConstant:60],
            
            [self.selectedScriptLabel.topAnchor constraintEqualToAnchor:self.bottomPreview.bottomAnchor],
            [self.selectedScriptLabel.leadingAnchor constraintEqualToAnchor:self.bottomContentView.leadingAnchor constant:8],
            [self.selectedScriptLabel.trailingAnchor constraintEqualToAnchor:self.bottomContentView.trailingAnchor constant:8],
            [self.selectedScriptLabel.heightAnchor constraintEqualToConstant:14],\
        ]];
        [self selectedAssetsChanged];
    };
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                block();
            } else {
                [UIAlertController xy_showAlertPhotoSettingIfUnauthorized];
            }
        });
    }];
}

- (void)didMoveToWindow
{
	[super didMoveToWindow];
	_bottomPreview.assetArray = [XYPhotoSelectedAssetManager sharedManager].selectedAssets;
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
		case UIImagePickerControllerCameraFlashModeAuto: {
			[_flashSwitchButton setTitle:@"自动" forState:UIControlStateNormal];
		}
			break;
		case UIImagePickerControllerCameraFlashModeOn: {
			[_flashSwitchButton setTitle:@"打开" forState:UIControlStateNormal];
		}
			break;
		case UIImagePickerControllerCameraFlashModeOff: {
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

- (void)setDelegate:(id<XYPhotoCameraOverlayViewDelegate>)delegate
{
	_delegate = delegate;
	_bottomPreview.delegate = delegate;
}

#pragma mark - actions

- (void)flashButtonClick:(UIButton *)sender
{
	if ([_delegate respondsToSelector:@selector(cameraOverlayView:didSwitchedFlashMode:)] && [UIAlertController xy_showAlertCameraSettingIfUnauthorized]) {
		
		switch (_flashMode) {
			case UIImagePickerControllerCameraFlashModeAuto: {
				self.flashMode = UIImagePickerControllerCameraFlashModeOn;
			}
				break;
			case UIImagePickerControllerCameraFlashModeOn: {
				self.flashMode = UIImagePickerControllerCameraFlashModeOff;
			}
				break;
			case UIImagePickerControllerCameraFlashModeOff: {
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
	NSArray *assets = [XYPhotoSelectedAssetManager sharedManager].selectedAssets;
	NSInteger max = (NSInteger)[XYPhotoSelectedAssetManager sharedManager].maxNumberOfAssets;
	if (max==0) {
		_selectedScriptLabel.text = @(assets.count).stringValue;
	} else {
		_selectedScriptLabel.text = [NSString stringWithFormat:@"(%zd / %zd)",assets.count,max];
	}
}


@end
