//
//  CKPhotoTableCell.m
//  XYPhotoKitDemo
//
//  Created by XcodeYang on 12/22/14.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CKPhotoTableCell.h"
#import "CKPhotoKitHelper.h"
#import "CKPhotoSelectedAssetManager.h"
#import "CKPhotoDataCategory.h"

NSString *const CKPhotoTableCellReuseIdentifier = @"CKPhotoTableCellReuseIdentifier";

@interface CKPhotoTableCell ()

@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImageView *backImageView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation CKPhotoTableCell

- (instancetype)init
{
    if (self = [super init]) {
        [self commonSetup];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonSetup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup
{
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	UIImageView *(^creatImageBlock)(CGRect frame) = ^(CGRect frame){
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
		imageView.contentMode = UIViewContentModeScaleAspectFill;
		imageView.clipsToBounds = YES;
		imageView.layer.borderColor = [UIColor whiteColor].CGColor;
		imageView.layer.borderWidth = 1.0/[UIScreen mainScreen].scale;
		[self.contentView addSubview:imageView];
		return imageView;
	};
	
	CGFloat width = 68, left = 16, top = 11;
	self.backImageView = creatImageBlock(CGRectMake(left+2*2, top-2*2, width-4*2, width-4*2));
	self.centerImageView = creatImageBlock(CGRectMake(left+2, top-2, width-4, width-4));
	self.mainImageView = creatImageBlock(CGRectMake(left, top, width, width));
	
	self.titleLabel = [[UILabel alloc] init];
	[self.contentView addSubview:self.titleLabel];
	
	self.subtitleLabel = [[UILabel alloc] init];
	self.subtitleLabel.font = [UIFont systemFontOfSize:12];
	[self.contentView addSubview:self.subtitleLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

	self.titleLabel.frame = CGRectMake(100, 20, self.contentView.frame.size.width-100, 20);
	self.subtitleLabel.frame = CGRectMake(100, CGRectGetMaxY(self.titleLabel.frame)+4, self.contentView.frame.size.width-100, 15);
}

- (void)setCollection:(PHAssetCollection *)collection
{
	_collection = collection;
	
	PHFetchOptions *fetchOptions = [PHFetchOptions new];
	fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
	
	PHAssetMediaType type = [CKPhotoSelectedAssetManager sharedManager].mediaType;
	if (type != PHAssetMediaTypeUnknown) {
		fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@", @(type)];
	}

	PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
	
	if (fetchResult.count<=0) {
		UIImage *placeholderImage = [UIImage xy_imageWithName:@"cl_photokit_placeholder"];
		[@[_mainImageView, _centerImageView, _backImageView] enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			obj.hidden = NO;
			obj.image = placeholderImage;
		}];
	} else {
		[self setImageView:_mainImageView withAsset:fetchResult.firstObject];
		
		_centerImageView.hidden = fetchResult.count<2;
		if (!_centerImageView.hidden) {
			[self setImageView:_centerImageView withAsset:fetchResult[1]];
		}
		
		_backImageView.hidden = fetchResult.count<3;
		if (!_backImageView.hidden) {
			[self setImageView:_backImageView withAsset:fetchResult[2]];
		}
	}
	
	self.titleLabel.text = collection.localizedTitle;
	self.subtitleLabel.text = [NSString stringWithFormat:@"%lu", (long)fetchResult.count];
}

- (void)setImageView:(UIImageView *)imageView withAsset:(PHAsset *)asset
{
	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = [CKPhotoSelectedAssetManager sharedManager].allowNetRequestIfiCloud;

	[[PHImageManager defaultManager] requestImageForAsset:asset
											   targetSize:CGSizeScale(imageView.frame.size, [UIScreen mainScreen].scale)
											  contentMode:PHImageContentModeAspectFill
												  options:options
											resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
												imageView.image = result;
											}];
}

+ (CGFloat)cellHeightWithItem:(id)item tableView:(UITableView *)tableView
{
	return CLPhotoCollectionCellRowHeight;
}

@end
