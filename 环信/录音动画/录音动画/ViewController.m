//
//  ViewController.m
//  录音动画
//
//  Created by lizhongqiang on 16/5/9.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "ViewController.h"
#import "HWProgressImageView.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController (){
    AVAudioRecorder *_recoder;
    NSNumber      *_formatIDKey;
    NSNumber     *_sampleRate;
    NSNumber     *_numberOfChannelsKey;
    NSNumber     *_linearPCMBitDepthKey;
    NSNumber     *_isFloatKey;
    NSURL        *_urlReconder;
    NSTimer      *_timer;
}
@property (nonatomic, strong) UIButton *btn ;
@property (nonatomic, strong) HWProgressImageView *dynamicProgress;
@end

@implementation ViewController

- (UIButton *)btn{
    if (_btn == nil) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn setTitle:@"点击录音" forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btn.frame = CGRectMake(50, 100, 100, 30);
        [_btn addTarget:self action:@selector(recordAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}

- (HWProgressImageView *)dynamicProgress {
    if (_dynamicProgress == nil) {
        _dynamicProgress = [[HWProgressImageView alloc]initWithFrame:CGRectMake(0, 0, 35, 58.5)];
        _dynamicProgress.image = [UIImage imageNamed:@"wave70x117@2x"];
        _dynamicProgress.hasGrayscaleBackground = NO;
        _dynamicProgress.verticalProgress = YES;
        
        _dynamicProgress.progress = 0.5;
       
        _dynamicProgress.center = CGPointMake(self.view.center.x, self.view.center.y-13);
    }
    return _dynamicProgress;
}
- (void)initSetting {
    
    // 默认8k 16bit 双声道
    _formatIDKey = [NSNumber numberWithInt:kAudioFormatLinearPCM];
    _sampleRate  = [NSNumber numberWithFloat:8000.];
    _numberOfChannelsKey = [NSNumber numberWithInt:2];
    _linearPCMBitDepthKey = [NSNumber numberWithInt:16];
    _isFloatKey = [NSNumber numberWithBool:YES];
}

- (void)start {
    [self initSetting];
    if (_recoder) {
        NSLog(@"录音实例已创建，请稍后重试。");
        return;
    }
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
        return;
    }
    
    NSMutableDictionary *settingDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [settingDict setObject:_formatIDKey forKey:AVFormatIDKey];
    [settingDict setObject:_sampleRate forKey:AVSampleRateKey];
    [settingDict setObject:_numberOfChannelsKey forKey:AVNumberOfChannelsKey];
    [settingDict setObject:_linearPCMBitDepthKey forKey:AVLinearPCMBitDepthKey];
    [settingDict setObject:_isFloatKey forKey:AVLinearPCMIsFloatKey];
    
    if (!_urlReconder) {
        _urlReconder = [NSURL URLWithString:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/temp.caf"]];
    }
    
    error = nil;
    _recoder = [[AVAudioRecorder alloc] initWithURL:_urlReconder settings:settingDict error:&error];
    if (error && error.code != 0) {
        NSLog(@"AVAudioRecorder alloc initwithURL error");
        return;
    }
    
    _recoder.meteringEnabled = YES;
    [_recoder prepareToRecord];
    [_recoder record];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(timer:) userInfo:nil repeats:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.btn];
    [self.view addSubview:self.dynamicProgress];
    self.view.backgroundColor = [UIColor redColor];
}

-(void)timer:(NSTimer *)theTimer {
    
    // 录音实例被释放，则停止定时器
    if (!_recoder) {
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    // 发送当前的录音大小
    [_recoder updateMeters];
    float soundLoudly = [_recoder peakPowerForChannel:0];
    CGFloat soundMouter = pow(10, (0.005 * soundLoudly));
    
    [self.dynamicProgress setProgress:soundMouter];
}
- (void)recordAction {
    [self start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
