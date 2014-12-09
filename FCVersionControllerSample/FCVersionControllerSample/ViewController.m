//
//  ViewController.m
//  FCVersionControllerSample
//
//  Created by Harley on 14/12/9.
//  Copyright (c) 2014年 Flycent. All rights reserved.
//

#import "ViewController.h"
#import "FCVersionController.h"

@interface ViewController ()
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *checkingIndicator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    FCVersionController *versionController = [FCVersionController sharedController];
    [versionController setAppID:@"645394250"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkForUpdateAction:(id)sender
{
    FCVersionController *versionController = [FCVersionController sharedController];
    
    if (versionController.latestNewVersion) {
        [self showAlertForNewVersion:versionController.latestNewVersion];
        return;
    }
    
    self.checkButton.hidden = YES;
    [self.checkingIndicator startAnimating];
    
    __weak typeof(self) weakSelf = self;
    [versionController searchForUpdateFinished:^(FCVersionInfo *versionInfo) {
        if (!weakSelf) return;
        __strong typeof (weakSelf) strongSelf = weakSelf;
        
        strongSelf.checkButton.hidden = NO;
        [strongSelf.checkingIndicator stopAnimating];
        
        if (versionInfo)
        {
            [strongSelf showAlertForNewVersion:versionInfo];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"当前为最新版本!" message:versionController.latestNewVersion.releaseNotes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            return;
        }
    }];
}

- (void)showAlertForNewVersion:(FCVersionInfo*)version
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"有新版本！" message:version.releaseNotes delegate:self cancelButtonTitle:@"跳过" otherButtonTitles:@"更新", nil];
    [alert show];
    return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        FCVersionController *versionController = [FCVersionController sharedController];
        [versionController installLatestVersion];
    }
}

@end
