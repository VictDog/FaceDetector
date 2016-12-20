//
//  ViewController.m
//  FaceDetector
//
//  Created by Mac on 2016/12/20.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>

#define imageName [NSString stringWithFormat:@"face-%d", _imageTag]

@interface ViewController ()
@property (weak, nonatomic)   IBOutlet UILabel *label;
@property (weak, nonatomic)   IBOutlet UIImageView *imageView;
@property (nonatomic, assign) int imageTag;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.imageTag = 1;
    self.imageView.image = [UIImage imageNamed:imageName];
    [self faceDetectWithImage:[UIImage imageNamed:imageName]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 上一张图片
- (IBAction)theLastPicture:(id)sender {
    
    if (_imageTag > 1) {
        _imageTag -= 1;
    } else {
        _imageTag = 1;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"已经是第一张图片了" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    self.imageView.image = [UIImage imageNamed:imageName];
    [self faceDetectWithImage:[UIImage imageNamed:imageName]];
}

#pragma mark - 下一张图片
- (IBAction)theNextPicture:(id)sender {
    
    if (_imageTag < 6) {
        _imageTag += 1;
    } else {
        _imageTag = 6;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"已经是最后一张图片了" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    self.imageView.image = [UIImage imageNamed:imageName];
    
    [self faceDetectWithImage:[UIImage imageNamed:imageName]];
}

#pragma mark - 识别人脸
- (void)faceDetectWithImage:(UIImage *)image {
    
    for (UIView *view in _imageView.subviews) {
        [view removeFromSuperview];
    }
    
    // 图像识别能力：可以在CIDetectorAccuracyHigh(较强的处理能力)与CIDetectorAccuracyLow(较弱的处理能力)中选择，因为想让准确度高一些在这里选择CIDetectorAccuracyHigh
    NSDictionary *opts = [NSDictionary dictionaryWithObject:
                          CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    // 将图像转换为CIImage
    CIImage *faceImage = [CIImage imageWithCGImage:image.CGImage];
    CIDetector *faceDetector=[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    // 识别出人脸数组
    NSArray *features = [faceDetector featuresInImage:faceImage];
    // 得到图片的尺寸
    CGSize inputImageSize = [faceImage extent].size;
    //将image沿y轴对称
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
    //将图片上移
    transform = CGAffineTransformTranslate(transform, 0, -inputImageSize.height);
    
    // 取出所有人脸
    for (CIFaceFeature *faceFeature in features){
        //获取人脸的frame
        CGRect faceViewBounds = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        CGSize viewSize = _imageView.bounds.size;
        CGFloat scale = MIN(viewSize.width / inputImageSize.width,
                            viewSize.height / inputImageSize.height);
        CGFloat offsetX = (viewSize.width - inputImageSize.width * scale) / 2;
        CGFloat offsetY = (viewSize.height - inputImageSize.height * scale) / 2;
        // 缩放
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
        // 修正
        faceViewBounds = CGRectApplyAffineTransform(faceViewBounds,scaleTransform);
        faceViewBounds.origin.x += offsetX;
        faceViewBounds.origin.y += offsetY;
    
        //描绘人脸区域
        UIView* faceView = [[UIView alloc] initWithFrame:faceViewBounds];
        faceView.layer.borderWidth = 2;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        [_imageView addSubview:faceView];
    
        // 判断是否有左眼位置
        if(faceFeature.hasLeftEyePosition){}
        // 判断是否有右眼位置
        if(faceFeature.hasRightEyePosition){}
        // 判断是否有嘴位置
        if(faceFeature.hasMouthPosition){}
    }
    self.label.text = [NSString stringWithFormat:@"识别出了%ld张脸", features.count];
}
@end
