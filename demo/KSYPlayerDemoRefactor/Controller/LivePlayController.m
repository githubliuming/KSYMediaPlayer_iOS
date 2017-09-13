//
//  LivePlayController.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/11.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "LivePlayController.h"
#import "RecordeViewController.h"
#import "LivePlayOperationView.h"
#import "KSYUIVC.h"
#import "AppDelegate.h"
#import "PlayerViewModel.h"

@interface LivePlayController ()
@property (nonatomic, strong) RecordeViewController     *recordeController;
@property (nonatomic, strong) LivePlayOperationView     *playOperationView;
@property (nonatomic, assign) NSInteger                  rotateIndex;
@end

@implementation LivePlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rotateIndex = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:)name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [self setupUI];
    [self setupOperationBlock];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.allowRotation = YES;
}

- (void)dealloc {
    NSLog(@"LivePlayController dealloced");
}

- (void)setFullScreen:(BOOL)fullScreen {
    self.playOperationView.fullScreen = fullScreen;
}

- (void)statusBarOrientationChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL fullScreen = (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft);
    [self.playerViewModel fullScreenHandlerForLivePlayController:self isFullScreen:fullScreen];
}

- (void)setupUI {
    [self.view addSubview:self.playOperationView];
    [self.playOperationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (LivePlayOperationView *)playOperationView {
    if (!_playOperationView) {
        _playOperationView = [[LivePlayOperationView alloc] initWithVideoModel:self.currentVideoModel];
    }
    return _playOperationView;
}

- (void)setupOperationBlock  {
    
    __weak typeof(self) weakSelf = self;
    
    self.recordeController = [[RecordeViewController alloc] initWithPlayer:self.player screenRecordeFinishedBlock:^{
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.view sendSubviewToBack:strongSelf.playOperationView];
        [strongSelf.view sendSubviewToBack:strongSelf.player.view];
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationPortrait) {
//            [strongSelf.playerViewModel fullScreenHandlerForPlayController:strongSelf isFullScreen:NO];
        }
    }];
    
    self.playOperationView.playStateBlock = ^(VCPlayHandlerState state) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (state == VCPlayHandlerStatePause) {
            [strongSelf.player pause];
        } else if (state == VCPlayHandlerStatePlay) {
            [strongSelf.player play];
        }
    };
    self.playOperationView.screenShotBlock = ^{
        typeof(weakSelf) strongSelf = weakSelf;
        UIImage *thumbnailImage = strongSelf.player.thumbnailImageAtCurrentTime;
        [KSYUIVC saveImageToPhotosAlbum:thumbnailImage];
    };
    self.playOperationView.screenRecordeBlock = ^{
        typeof(weakSelf) strongSelf = weakSelf;
        //        [strongSelf.playOperationView bringSubviewToFront:strongSelf.player.view];
        //        [strongSelf.playOperationView bringSubviewToFront:strongSelf.volumeBrightControlView];
        [strongSelf.view addSubview:strongSelf.recordeController.view];
        [strongSelf addChildViewController:strongSelf.recordeController];
        [strongSelf.recordeController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(strongSelf.view);
        }];
        [strongSelf.recordeController startRecorde];
    };
    // 镜像block
    self.playOperationView.mirrorBlock = ^{
        typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.player.mirror = YES;
    };
    // 画面旋转block
    self.playOperationView.pictureRotateBlock = ^{
        typeof(weakSelf) strongSelf = weakSelf;
        NSArray *rotates = @[@0, @90, @180, @270];
        if (strongSelf.rotateIndex < rotates.count) {
            strongSelf.player.rotateDegress = [rotates[strongSelf.rotateIndex] intValue];
            strongSelf.rotateIndex += 1;
        } else {
            strongSelf.rotateIndex = 0;
        }
    };
    
    // 点赞block
}

#pragma mark --
#pragma mark - notification handler

-(void)handlePlayerNotify:(NSNotification*)notify {
    [self notifyHandler:notify];
}

#pragma mark --
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    if([keyPath isEqual:@"currentPlaybackTime"]) {
        
    }
    //    else if([keyPath isEqual:@"clientIP"])
    //    {
    //        NSLog(@"client IP is %@\n", [change objectForKey:NSKeyValueChangeNewKey]);
    //    }
    //    else if([keyPath isEqual:@"localDNSIP"])
    //    {
    //        NSLog(@"local DNS IP is %@\n", [change objectForKey:NSKeyValueChangeNewKey]);
    //    }
    else if ([keyPath isEqualToString:@"player"]) {
        if (self.player) {
            
        } else {
            
        }
    }
}

@end