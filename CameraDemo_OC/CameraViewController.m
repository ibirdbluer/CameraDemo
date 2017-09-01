//
//  CameraViewController.m
//  CameraDemo_OC
//
//  Created by Gregory Qian on 01/09/2017.
//  Copyright © 2017 Gregory Qian. All rights reserved.
//

#import "CameraViewController.h"
#import "EditImageViewController.h"
#import "CollectionViewCell.h"

@interface CameraViewController () <UICollectionViewDelegate, UICollectionViewDataSource>{
    GPUImageStillCamera *imageCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageView *iv;
    
    EditImageViewController *imageVC;
    
    NSArray *filterArray;
    BOOL filterListIsOpen;
    NSInteger selectedIndex;
}
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UICollectionView *actionCollectionView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.slider.hidden = YES;
    filterArray = @[@"Contrast", @"Brightness", @"RGB", @"Hue", @"Exposure", @"Gamma"];
    filterListIsOpen = NO;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(80, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 2;
    
    self.actionCollectionView.collectionViewLayout = layout;

    
    imageCamera=[[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
    //AVCaptureDevicePositionBack为后摄像头 front为前置摄像头
    //AVCaptureSessionPreset1920x1080为分辨率 另外还支持多种分辨率
    //AVCaptureSessionPreset1280x720 等等等等
    
    imageCamera.outputImageOrientation=UIInterfaceOrientationPortrait;
    
    filter=[[GPUImageFilter alloc] init]; //默认滤镜.
    /*官方版本如下:
     GPUImageFilter *customFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"CustomShader"];
     这个CustomShader是自定义的滤镜文件.如果没有,那就使用默认滤镜
     */
    [imageCamera addTarget:filter];
    
    iv=[[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-128)];
    iv.fillMode=kGPUImageFillModePreserveAspectRatioAndFill;
    /*显示模式分为三种
     typedef NS_ENUM(NSUInteger, GPUImageFillModeType) {
     kGPUImageFillModeStretch,                       // Stretch to fill the full view, which may distort the image outside of its normal aspect ratio
     kGPUImageFillModePreserveAspectRatio,           // Maintains the aspect ratio of the source image, adding bars of the specified background color
     kGPUImageFillModePreserveAspectRatioAndFill     // Maintains the aspect ratio of the source image, zooming in on its center to fill the view
     };
     */
    [filter addTarget:iv];
    [self.view insertSubview:iv atIndex:0];
//    [self.view addSubview:iv];//将显示view加入父类
    [imageCamera startCameraCapture];//开启摄像头
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button Action

// 翻转摄像头
- (IBAction)switchCamera:(UIButton *)sender {
}

// 获取图片
- (IBAction)takePhoto:(UIButton *)sender {
    [imageCamera capturePhotoAsImageProcessedUpToFilter:filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if(error){
            return;
        }
        [imageCamera stopCameraCapture];
        
        imageVC.image = processedImage;
        imageVC.imageView.image = processedImage;

    }];

}

#pragma mark - Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (filterListIsOpen) {
        return 3 + filterArray.count;
    }
    return 3;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *title;
    switch (indexPath.row) {
        case 0:
            title = @"照片";
            break;
        case 1:
            title = @"正方形";
            break;
        case 2:
            title = @"滤镜";
            break;
        default:
            title = filterArray[indexPath.row - 3];
            break;
    }
    cell.titleLabel.text = title;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = indexPath.row;
    switch (indexPath.row) {
            // 长方形照片
        case 0:
            iv.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-128);
            break;
        case 1:
            // 正方形照片
            iv.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
            break;
        case 2:
            // “ 滤镜 ”
            filterListIsOpen = !filterListIsOpen;
            [collectionView reloadData];
            break;
        default:
            // 各种滤镜
            [imageCamera removeAllTargets];
            [filter removeAllTargets];
            self.slider.hidden = NO;

            for (int i = 3; i < filterArray.count + 3; i++) {
                NSString *filterName = filterArray[indexPath.row - i];
                if ([filterName isEqualToString:@"Contrast"]) {
                    [self.slider setMinimumValue:0.0];
                    [self.slider setMaximumValue:4.0];
                    [self.slider setValue:1.0];
                    
                    filter = [[GPUImageContrastFilter alloc] init];
                    break;
  
                }else if ([filterName isEqualToString:@"Brightness"]) {
                    [self.slider setMinimumValue:-1.0];
                    [self.slider setMaximumValue:1.0];
                    [self.slider setValue:0.0];
                    
                    filter = [[GPUImageBrightnessFilter alloc] init];
                    break;
                }else if ([filterName isEqualToString:@"RGB"]) {
                    [self.slider setMinimumValue:0.0];
                    [self.slider setMaximumValue:2.0];
                    [self.slider setValue:1.0];
                    
                    filter = [[GPUImageRGBFilter alloc] init];
                    break;
                }else if ([filterName isEqualToString:@"Hue"]) {
                    [self.slider setMinimumValue:0.0];
                    [self.slider setMaximumValue:360.0];
                    [self.slider setValue:90.0];
                    
                    filter = [[GPUImageHueFilter alloc] init];
                    break;
                }else if ([filterName isEqualToString:@"Exposure"]) {
                    [self.slider setMinimumValue:-4.0];
                    [self.slider setMaximumValue:4.0];
                    [self.slider setValue:0.0];
                    
                    filter = [[GPUImageExposureFilter alloc] init];
                    break;
                }else if ([filterName isEqualToString:@"Gamma"]) {
                    [self.slider setMinimumValue:0.0];
                    [self.slider setMaximumValue:3.0];
                    [self.slider setValue:1.0];
                    
                    filter = [[GPUImageGammaFilter alloc] init];
                    break;
                }

            }
            
            [imageCamera addTarget:filter];
            
            imageCamera.runBenchmark = YES;
            
            [filter addTarget:iv];
            [imageCamera startCameraCapture];
            
            break;
    }

}
- (IBAction)updateFilter:(UISlider *)sender {
    for (int i = 3; i < filterArray.count + 3; i++) {
        [imageCamera resetBenchmarkAverage];
        NSString *filterName = filterArray[selectedIndex - i];
        if ([filterName isEqualToString:@"Contrast"]) {
            [(GPUImageContrastFilter *)filter setContrast:[sender value]];
            break;

        }else if ([filterName isEqualToString:@"Brightness"]) {
            [(GPUImageBrightnessFilter *)filter setBrightness:[sender value]];
            break;

        }else if ([filterName isEqualToString:@"RGB"]) {
             [(GPUImageRGBFilter *)filter setGreen:[sender value]];
            break;

        }else if ([filterName isEqualToString:@"Hue"]) {
            [(GPUImageHueFilter *)filter setHue:[sender value]];
            break;

        }else if ([filterName isEqualToString:@"Exposure"]) {
             [(GPUImageExposureFilter *)filter setExposure:[sender value]];
            break;

        }else if ([filterName isEqualToString:@"Gamma"]) {
            [(GPUImageGammaFilter *)filter setGamma:[sender value]];
            break;

        }
        
    }
}








#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    imageVC = (EditImageViewController *)segue.destinationViewController;
    
    
}


@end
