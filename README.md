# CLPhotoKit

基于PhotoKit开发的照片获取方式，支持多选单选（对应的UI略有不同），支持iCloud获取相册等

## 使用方式

详情见`demo`查看

### 相册获取方式

| 属性  | 说明 | 
| --- | --- |
| **Controller** | |
| CKPhotoMultiImagePicker | NavigationController,承载两个VC栈、相册相关参数初始化工作及 delegate & datasource |
| CKPhotoAlbumListController | 系统和用户的相册列表（tableview），根据CLPhotoMultiPickerStartPosition来确定初始展示哪个VC界面 |
| CKPhotoAlbumDetailController | 某个相册的详情（collectionView），单选多选照片的不同交互主要完成于此，可进入大图预览 |
| CKPhotoPreviewViewController | 大图预览（CKHorizontalScrollView）|

### 用法

```objc

CKPhotoMultiImagePicker *multiImagePicker = [[CKPhotoMultiImagePicker alloc] init];
multiImagePicker.pickerDelegate = self;
multiImagePicker.pickerDataSource = self;
multiImagePicker.mediaType = PHAssetMediaTypeImage; // 支持图片和视屏
multiImagePicker.maxNumberOfAssets = 9; // 最多选择九张照片
multiImagePicker.assetCollectionViewColumnCount = 4; // 获取
multiImagePicker.startPosition = CLPhotoMultiPickerStartPositionAlbums; // 相册列表开始进入
multiImagePicker.allowNetRequestIfiCloud = YES; // 支持iCloud网络获取
[self presentViewController:multiImagePicker animated:YES completion:nil];


#pragma mark - CKPhotoMultiImagePickerDelegate, CKPhotoMultiImagePickerDataSource

- (void)multiImagePicker:(CKPhotoMultiImagePicker *)multiImagePicker selectedAssets:(NSArray<PHAsset *> *)assets
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
| CKPhotoMultiCameraPicker | NavigationController,承载CKPhotoCameraController、相机相关参数初始化工作及 delegate & datasource |
| CKPhotoCameraController | 基于ImagePickerController，需要有相机和相册两个权限做交互，可进入大图预览 |
| CKPhotoPreviewViewController | 大图预览（CKHorizontalScrollView）|

### 用法

```objc

CKPhotoMultiCameraPicker *camera = [[CKPhotoMultiCameraPicker alloc] init];
camera.pickerDelegate = self;
camera.pickerDataSource = self;
camera.maxNumberOfAssets = 9; // 最多选择九张照片
camera.allowNetRequestIfiCloud = YES; // 支持iCloud网络获取
[self presentViewController:camera animated:YES completion:nil];

#pragma mark - CKPhotoMultiCameraPickerDelegate, CKPhotoMultiCameraPickerDataSource

- (void)multiCameraPicker:(CKPhotoMultiCameraPicker *)multiImagePicker selectedAssets:(NSArray<PHAsset *> *)assets
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

_imageRequestId = [self.imageManager requestImageForAsset:_asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
	BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue]
							&& ![info objectForKey:PHImageErrorKey]
							&& ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
	if (downloadFinined) {
		_imageRequestId = 0;
	}
	_imageView.image = result;
}];
```


## TODO

- [x] 视频播放
- [ ] 拆分类的层级（比如接入LocalImagePicker等等）
- [ ] 完善其他获取照片的拓展方法 & 工具（视频压缩、图片压缩，指定相册图片写入等等）
- [ ] 添加iCloud加载的请求等待提示
- [x] 持久化&有效性验证：对PHAsset持久化存储只需储存 `photoAsset.localIdentifier`的唯一标识，验证对象是否还存在于相册中（即有效性）需要对唯一标识做遍历对比
