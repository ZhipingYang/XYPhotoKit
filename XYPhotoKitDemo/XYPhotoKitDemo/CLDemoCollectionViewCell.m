//
//  CLDemoCollectionViewCell.m
//  CLPhotoKitDemo
//
//  Created by XcodeYang on 13/09/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "CLDemoCollectionViewCell.h"

@implementation CLDemoCollectionViewCell

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.contentView.layer.borderWidth = 0.5;
	self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

@end
