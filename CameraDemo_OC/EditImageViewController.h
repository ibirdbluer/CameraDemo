//
//  EditImageViewController.h
//  CameraDemo_OC
//
//  Created by Gregory Qian on 01/09/2017.
//  Copyright © 2017 Gregory Qian. All rights reserved.
//

#import "ViewController.h"

@interface EditImageViewController : ViewController

@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
