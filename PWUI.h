/**
 * PWUI.h — PianoWizard UIKit Views
 * All UI is implemented in UIKit to be compatible with Theos/tweak compilation.
 * Matches the Android Compose UI pixel-for-pixel.
 */

#import <UIKit/UIKit.h>

// ── Glass Player View ───────────────────────────────────
@interface PWPlayerView : UIView
+ (instancetype)show;
- (void)setSongName:(NSString *)name;
- (void)setProgress:(float)progress current:(NSString *)cur total:(NSString *)tot;
- (void)setPlaying:(BOOL)playing paused:(BOOL)paused;
- (void)setFavorite:(BOOL)fav;
- (void)setSpeed:(NSString *)speed;
@property (nonatomic, copy) void(^onClose)(void);
@property (nonatomic, copy) void(^onPlayPause)(void);
@property (nonatomic, copy) void(^onPrev)(void);
@property (nonatomic, copy) void(^onNext)(void);
@property (nonatomic, copy) void(^onFavorite)(void);
@property (nonatomic, copy) void(^onSpeedDown)(void);
@property (nonatomic, copy) void(^onSpeedUp)(void);
@property (nonatomic, copy) void(^onSpeedReset)(void);
@property (nonatomic, copy) void(^onSpeedUp02)(void);
@end

// ── Floating Ball ────────────────────────────────────────
@interface PWFloatingBall : UIView
+ (instancetype)show;
@property (nonatomic, copy) void(^onTap)(void);
@end

// ── Card Info Panel ──────────────────────────────────────
@interface PWCardInfoView : UIView
+ (instancetype)show;
@property (nonatomic, copy) void(^onClose)(void);
- (void)setCardKey:(NSString *)key verified:(BOOL)verified deviceId:(NSString *)did;
@end

// ── Backup Panel ─────────────────────────────────────────
@interface PWBackupView : UIView
+ (instancetype)show;
@property (nonatomic, copy) void(^onClose)(void);
@property (nonatomic, copy) void(^onBackupLocal)(void);
@property (nonatomic, copy) void(^onUploadServer)(void);
@property (nonatomic, copy) void(^onDownloadServer)(void);
- (void)setFavoriteCount:(NSInteger)count;
@end

// ── Main Panel ───────────────────────────────────────────
@interface PWMainPanelView : UIView
+ (instancetype)show;
@property (nonatomic, copy) void(^onClose)(void);
- (void)setSongs:(NSArray<NSDictionary *> *)songs;
- (void)setTotalCount:(NSInteger)count forTab:(NSString *)tab;
@end

// ── Settings Panel ───────────────────────────────────────
@interface PWSettingsView : UIView
+ (instancetype)show;
@property (nonatomic, copy) void(^onClose)(void);
@end
