//
//  HWProgressImageView.h
//  录音动画
//
//  Created by lizhongqiang on 16/5/9.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWProgressImageView : UIImageView{
    
    UIImage * _originalImage;
    
    BOOL      _internalUpdating;
}

@property (nonatomic) float progress;
@property (nonatomic) BOOL  hasGrayscaleBackground;

@property (nonatomic, getter = isVerticalProgress) BOOL verticalProgress;

@property(nonatomic, strong) UIImage * originalImage;

- (void)commonInit;
- (void)updateDrawing;
@end

@interface XHAudioHud : UIView
@property (nonatomic, assign) float progress;

- (void)setProgress:(float)progress;
- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
