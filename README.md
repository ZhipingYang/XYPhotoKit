# XYPhotoKit

基于PhotoKit开发的照片获取方式，支持多选单选（对应的UI略有不同），支持iCloud获取相册等

<p align="center">
<img width= 24.6% src="https://user-images.githubusercontent.com/9360037/79872498-74b01600-8418-11ea-99b5-9b2dafd8bc31.jpeg">
<img width= 24.6% src="https://user-images.githubusercontent.com/9360037/79872488-6eba3500-8418-11ea-89d5-5b481949612f.jpeg">
<img width= 24.6% src="https://user-images.githubusercontent.com/9360037/79872506-7679d980-8418-11ea-8f83-e5ace8d8b87f.jpeg">
<img width=24.8% src="https://user-images.githubusercontent.com/9360037/79872515-77ab0680-8418-11ea-80cc-38edf2da176e.jpeg">

<img width= 24.6% src="https://user-images.githubusercontent.com/9360037/79879298-163b6580-8421-11ea-9e7d-4dcc4a177267.jpeg">
<img width= 24.6% src="https://user-images.githubusercontent.com/9360037/79879319-1c314680-8421-11ea-9987-b2d9d7d1db1d.jpeg">
<img width= 24.6% src="https://user-images.githubusercontent.com/9360037/79872504-7548ac80-8418-11ea-9cf7-8973a403dd0f.jpeg">
<img width= 24.6% src="https://user-images.githubusercontent.com/9360037/79872508-77127000-8418-11ea-9fb6-3bd9e344d7c7.jpeg">

</p>

## 使用方式

详情见`demo`查看

### 相册获取方式

| 属性  | 说明 | 
| --- | --- |
| **Controller** | |
| XYPhotoMultiImagePicker | NavigationController,承载两个VC栈、相册相关参数初始化工作及 delegate & datasource |
| XYPhotoAlbumListController | 系统和用户的相册列表（tableview），根据CLPhotoMultiPickerStartPosition来确定初始展示哪个VC界面 |
| XYPhotoAlbumDetailController | 某个相册的详情（collectionView），单选多选照片的不同交互主要完成于此，可进入大图预览 |
| XYPhotoPreviewViewController | 大图预览（XYHorizontalScrollView）|

### 用法

```objc

XYPhotoMultiImagePicker *multiImagePicker = [[XYPhotoMultiImagePicker alloc] init];
multiImagePicker.pickerDelegate = self;
multiImagePicker.pickerDataSource = self;
multiImagePicker.mediaType = PHAssetMediaTypeImage; // 支持图片和视屏
multiImagePicker.maxNumberOfAssets = 9; // 最多选择九张照片
multiImagePicker.assetCollectionViewColumnCount = 4; // 获取
multiImagePicker.startPosition = CLPhotoMultiPickerStartPositionAlbums; // 相册列表开始进入
multiImagePicker.allowNetRequestIfiCloud = YES; // 支持iCloud网络获取
[self presentViewController:multiImagePicker animated:YES completion:nil];


#pragma mark - XYPhotoMultiImagePickerDelegate, XYPhotoMultiImagePickerDataSource

- (void)multiImagePicker:(XYPhotoMultiImagePicker *)multiImagePicker selectedAssets:(NSArray<PHAsset *> *)assets
{
	_selectedAssets = assets;

	NSLog(@"%@", @(assets.count));
}

- (NSArray<PHAsset *> *)multiImagePickerLoadPresetSelectedAssets
{
	return _selectedAssets;
}

```

### 相机获取方式

| 属性  | 说明 | 
| --- | --- |
| **Controller** | |
| XYPhotoMultiCameraPicker | NavigationController,承载XYPhotoCameraController、相机相关参数初始化工作及 delegate & datasource |
| XYPhotoCameraController | 基于ImagePickerController，需要有相机和相册两个权限做交互，可进入大图预览 |
| XYPhotoPreviewViewController | 大图预览（XYHorizontalScrollView）|

### 用法

```objc

XYPhotoMultiCameraPicker *camera = [[XYPhotoMultiCameraPicker alloc] init];
camera.pickerDelegate = self;
camera.pickerDataSource = self;
camera.maxNumberOfAssets = 9; // 最多选择九张照片
camera.allowNetRequestIfiCloud = YES; // 支持iCloud网络获取
[self presentViewController:camera animated:YES completion:nil];

#pragma mark - XYPhotoMultiCameraPickerDelegate, XYPhotoMultiCameraPickerDataSource

- (void)multiCameraPicker:(XYPhotoMultiCameraPicker *)multiImagePicker selectedAssets:(NSArray<PHAsset *> *)assets
{
	_selectedAssets = assets.copy;
	NSLog(@"%@",assets);
}

- (NSArray<PHAsset *> *)multiCameraPickerLoadPresetSelectedAssets
{
	return _selectedAssets;
}

```

## 综述

以上获取都是PHAsset对象，PHAsset 非常灵活，详见[文档](https://developer.apple.com/documentation/photos/phasset)，同步异步请求、支持网络、请求progress等等可以查看 `PHImageRequestOptions`

> 例如：支持网络获取（如果是本地就直接本地获取）asset对象大小为`targetSize`的图片
> 闭包中可能会有多次回调（本地图片）越来越高清，当网络请求时非特殊情况下不可直接获取原图尺寸`CGSizeMake(asset.pixelWidth, asset.pixelHeight)`

```objc
PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
options.networkAccessAllowed = YES;

_imageRequestId = [self.imageManager requestImageForAsset:asset
                                               targetSize:_targetSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
	BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue]
							&& ![info objectForKey:PHImageErrorKey]
							&& ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
    if (downloadFinined) { self.imageRequestId = 0; }
    if (result) { self.imageView.image = result; }
}];
```


## todo & upgrade

- [x] 视频播放
- [ ] 拆分类的层级（比如接入LocalImagePicker等等）
- [ ] 完善其他获取照片的拓展方法 & 工具（视频压缩、图片压缩，指定相册图片写入等等）
- [ ] 添加iCloud加载的请求等待提示
- [ ] 大图预览添加过渡动画，视频播放、消失添加fade
- [ ] 大图预览改换使用pageController
- [x] 持久化&有效性验证：对PHAsset持久化存储只需储存 `photoAsset.localIdentifier`的唯一标识，验证对象是否还存在于相册中（即有效性）需要对唯一标识做遍历对比
