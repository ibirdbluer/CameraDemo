//
//  EditImageViewController.m
//  CameraDemo_OC
//
//  Created by Gregory Qian on 01/09/2017.
//  Copyright © 2017 Gregory Qian. All rights reserved.
//

#import "EditImageViewController.h"

@interface EditImageViewController ()

@end

@implementation EditImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (IBAction)savePhoto:(UIButton *)sender {
    //存入本地相册
    UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
}
- (IBAction)cancel:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(editDismiss)]) {
        [self.delegate editDismiss];
    }
    [self.navigationController popViewControllerAnimated:true];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
