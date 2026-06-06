/**
 * PianoWizard Plugin Bridge (ObjC)
 * Manages floating windows and connects Tweak.xm to UIKit UI views.
 */
#import "PWUI.h"
#import <UIKit/UIKit.h>

@interface PWPluginBridge : NSObject
+ (instancetype)shared;
- (void)startPlugin;
- (void)stopPlugin;
@end

@interface PWPluginBridge ()
@property (nonatomic, strong) UIWindow *ballWindow;
@property (nonatomic, strong) UIWindow *playerWindow;
@property (nonatomic, strong) UIWindow *cardWindow;
@property (nonatomic, strong) UIWindow *backupWindow;
@end

@implementation PWPluginBridge

+ (instancetype)shared {
    static PWPluginBridge *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[PWPluginBridge alloc] init]; });
    return instance;
}

- (void)startPlugin {
    dispatch_async(dispatch_get_main_queue(), ^{ [self showFloatingBall]; });
}

- (void)stopPlugin {
    self.ballWindow = nil; self.playerWindow = nil;
    self.cardWindow = nil; self.backupWindow = nil;
}

- (void)showFloatingBall {
    CGFloat sw = UIScreen.mainScreen.bounds.size.width;
    self.ballWindow = [[UIWindow alloc] initWithFrame:CGRectMake(sw - 78, 120, 48, 48)];
    if (@available(iOS 13.0, *)) {
        self.ballWindow.windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
    }
    self.ballWindow.windowLevel = UIWindowLevelStatusBar + 100;
    self.ballWindow.backgroundColor = [UIColor clearColor];

    PWFloatingBall *ball = [PWFloatingBall show];
    ball.onTap = ^{ [self showPlayer]; };
    self.ballWindow.rootViewController = [[UIViewController alloc] init];
    self.ballWindow.rootViewController.view = ball;
    self.ballWindow.hidden = NO;

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ballPan:)];
    [self.ballWindow addGestureRecognizer:pan];
}

- (void)ballPan:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:g.view];
    g.view.frame = CGRectOffset(g.view.frame, t.x, t.y);
    [g setTranslation:CGPointZero inView:g.view];
}

- (void)showPlayer {
    CGFloat sw = UIScreen.mainScreen.bounds.size.width;
    self.playerWindow = [[UIWindow alloc] initWithFrame:CGRectMake((sw-340)/2, 480, 340, 130)];
    if (@available(iOS 13.0, *)) {
        self.playerWindow.windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
    }
    self.playerWindow.windowLevel = UIWindowLevelStatusBar + 100;
    self.playerWindow.backgroundColor = [UIColor clearColor];

    PWPlayerView *player = [PWPlayerView show];
    __weak typeof(self) ws = self;
    player.onClose = ^{ ws.playerWindow = nil; };
    self.playerWindow.rootViewController = [[UIViewController alloc] init];
    self.playerWindow.rootViewController.view = player;
    self.playerWindow.hidden = NO;
}

- (void)showCardInfo {
    CGFloat sw = UIScreen.mainScreen.bounds.size.width;
    self.cardWindow = [[UIWindow alloc] initWithFrame:CGRectMake((sw-320)/2, 260, 320, 260)];
    if (@available(iOS 13.0, *)) {
        self.cardWindow.windowScene = [UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
    }
    self.cardWindow.windowLevel = UIWindowLevelStatusBar + 100;
    self.cardWindow.backgroundColor = [UIColor clearColor];

    PWCardInfoView *card = [PWCardInfoView show];
    __weak typeof(self) ws = self;
    card.onClose = ^{ ws.cardWindow = nil; };
    self.cardWindow.rootViewController = [[UIViewController alloc] init];
    self.cardWindow.rootViewController.view = card;
    self.cardWindow.hidden = NO;
}
@end
