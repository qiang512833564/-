//
//  UIImage+GIF.h
//  LBGIFImage
//
//  Created by Laurin Brandner on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GIF)

/// 根据 git 文件的名字（文件格式为name.gif），从 bundle 中获取
+ (UIImage *)sd_animatedGIFNamed:(NSString *)name;

/// 直接处理 git 文件的二进制数据，然后返回一个 image 对象
+ (UIImage *)sd_animatedGIFWithData:(NSData *)data;


/// 对 git image 进行 尺寸 修剪操作
- (UIImage *)sd_animatedImageByScalingAndCroppingToSize:(CGSize)size;

@end
