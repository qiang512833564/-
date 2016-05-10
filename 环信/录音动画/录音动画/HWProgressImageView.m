//
//  HWProgressImageView.m
//  录音动画
//
//  Created by lizhongqiang on 16/5/9.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//
#import "HWProgressImageView.h"

@interface HWProgressImageView ()

- (UIImage *) partialImageWithPercentage:(float)percentage vertical:(BOOL)vertical grayscaleRest:(BOOL)grayscaleRest orginImage:(UIImage *)originImage;

@end

@implementation HWProgressImageView

@synthesize progress               = _progress;
@synthesize hasGrayscaleBackground = _hasGrayscaleBackground;
@synthesize verticalProgress       = _verticalProgress;

- (UIImage *) partialImageWithPercentage:(float)percentage vertical:(BOOL)vertical grayscaleRest:(BOOL)grayscaleRest orginImage:(UIImage *)originImage {
    const int ALPHA = 0;
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, originImage.size.width * originImage.scale, originImage.size.height * originImage.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [originImage CGImage]);

    int x_origin = vertical ? 0 : width * percentage;
    int y_to = vertical ? height * (1.f -percentage) : height;
    
    for(int y = 0; y < y_to; y++) {
        for(int x = x_origin; x < width; x++) {
            /// 把每个像素的位置，改成相应的灰度
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];///这里是把刚才绘图的 context 对应像素一个一个的从内存中取出来
            
            /// 下面是，修改相应的像素
            if (grayscaleRest) {
                // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
                uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE]; /// 这里的一般情况下是固定的，个人理解，图片内透明颜色的像素，对应的 gray 依然是透明的
                
                // set the pixels to gray
                rgbaPixel[RED] = gray;
                rgbaPixel[GREEN] = gray;
                rgbaPixel[BLUE] = gray;
            }
            else {
                rgbaPixel[ALPHA] = 0;
                rgbaPixel[RED] = 0;
                rgbaPixel[GREEN] = 0;
                rgbaPixel[BLUE] = 0;
            }
        }
    }

    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:originImage.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

- (void)dealloc
{
    self.originalImage = nil;
}

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self commonInit];
    }
    return self;
    
}

- (void)commonInit{
    
    _progress = 0.f;
    _hasGrayscaleBackground = YES;
    _verticalProgress = YES;
    _originalImage = self.image;
    
}

#pragma mark - Custom Accessor

- (void)setImage:(UIImage *)image{
    
    [super setImage:image];
    
    if (!_internalUpdating) {
        self.originalImage = image;
        [self updateDrawing];
    }
    
    _internalUpdating = NO;
}

- (void)setProgress:(float)progress{
    
    _progress = MIN(MAX(0.f, progress), 1.f);
    [self updateDrawing];
    
}

- (void)setHasGrayscaleBackground:(BOOL)hasGrayscaleBackground{
    
    _hasGrayscaleBackground = hasGrayscaleBackground;
    [self updateDrawing];
    
}

- (void)setVerticalProgress:(BOOL)verticalProgress{
    
    _verticalProgress = verticalProgress;
    [self updateDrawing];
    
}

#pragma mark - drawing

- (void)updateDrawing{
    
    _internalUpdating = YES;
    self.image = [self partialImageWithPercentage:_progress vertical:_verticalProgress grayscaleRest:true orginImage:_originalImage];
}

@end