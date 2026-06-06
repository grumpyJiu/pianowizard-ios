/**
 * PWUI.m — PianoWizard UIKit Implementation
 * All views match Android Compose version visually.
 */
#import "PWUI.h"

// ── Color Macros (matched to Android PWTheme) ────────────
#define GLASS_BG     [UIColor colorWithRed:0.91 green:0.94 blue:1.0 alpha:0.70]
#define PURPLE       [UIColor colorWithRed:0.66 green:0.33 blue:0.97 alpha:1.0]
#define PINK         [UIColor colorWithRed:0.96 green:0.25 blue:0.37 alpha:1.0]
#define BLUE         [UIColor colorWithRed:0.29 green:0.49 blue:1.0 alpha:1.0]
#define GREEN        [UIColor colorWithRed:0.20 green:0.78 blue:0.35 alpha:1.0]
#define DARK_GRAY    [UIColor colorWithRed:0.17 green:0.24 blue:0.31 alpha:1.0]
#define TEXT_SEC     [UIColor colorWithRed:0.48 green:0.48 blue:0.48 alpha:1.0]
#define ACCENT_BLUE  [UIColor colorWithRed:0.29 green:0.49 blue:1.0 alpha:1.0]
#define RED_CLOSE    [UIColor colorWithRed:1.0 green:0.30 blue:0.31 alpha:1.0]

// ============================================================
// MARK: - Floating Ball
// ============================================================
@implementation PWFloatingBall {
    UIView *_gradientView;
}

+ (instancetype)show {
    PWFloatingBall *ball = [[PWFloatingBall alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    ball.backgroundColor = [UIColor clearColor];
    return ball;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Gradient circle
        _gradientView = [[UIView alloc] initWithFrame:self.bounds];
        _gradientView.layer.cornerRadius = 24;
        _gradientView.clipsToBounds = YES;

        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = _gradientView.bounds;
        gradient.colors = @[(id)PURPLE.CGColor, (id)PINK.CGColor];
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint = CGPointMake(1, 1);
        gradient.cornerRadius = 24;
        [_gradientView.layer addSublayer:gradient];
        [self addSubview:_gradientView];

        // Shadow
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowRadius = 6;
        self.layer.shadowOpacity = 0.2;

        // Music note
        UILabel *icon = [[UILabel alloc] initWithFrame:self.bounds];
        icon.text = @"♪";
        icon.textAlignment = NSTextAlignmentCenter;
        icon.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
        icon.textColor = [UIColor whiteColor];
        [self addSubview:icon];

        // Tap gesture
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)didTap {
    if (self.onTap) self.onTap();
}
@end

// ============================================================
// MARK: - Glass Player View (350×130pt — matches Android)
// ============================================================
@implementation PWPlayerView {
    UILabel *_titleLabel, *_timeCur, *_timeTotal, *_speedLabel;
    UIView *_progressBar, *_progressFill;
    UIButton *_closeBtn, *_favBtn, *_prevBtn, *_playBtn, *_nextBtn;
    UIButton *_speedDown, *_speedReset, *_speedUp, *_speedUp02;
    BOOL _isFavorite, _isPlaying, _isPaused;
}

+ (instancetype)show {
    return [[PWPlayerView alloc] initWithFrame:CGRectMake(0, 0, 340, 130)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = GLASS_BG;
        self.layer.cornerRadius = 28;
        self.clipsToBounds = YES;
        self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.25].CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowRadius = 10;
        self.layer.shadowOpacity = 0.1;

        CGFloat pad = 14, w = frame.size.width, h = frame.size.height;

        // ── Album Art ─────────────────────────────────
        UIView *album = [[UIView alloc] initWithFrame:CGRectMake(pad, (h-62)/2, 62, 62)];
        album.layer.cornerRadius = 31;
        album.clipsToBounds = YES;
        CAGradientLayer *g = [CAGradientLayer layer];
        g.frame = album.bounds;
        g.colors = @[(id)[UIColor colorWithRed:0.4 green:0.49 blue:0.92 alpha:1].CGColor,
                      (id)[UIColor colorWithRed:0.46 green:0.29 blue:0.64 alpha:1].CGColor];
        [album.layer addSublayer:g];
        UILabel *note = [[UILabel alloc] initWithFrame:album.bounds];
        note.text = @"♪"; note.textAlignment = NSTextAlignmentCenter;
        note.font = [UIFont systemFontOfSize:26]; note.textColor = [UIColor whiteColor];
        [album addSubview:note];
        [self addSubview:album];

        // ── Title ─────────────────────────────────────
        CGFloat rightX = pad + 62 + 10, rightW = w - rightX - pad;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(rightX, pad, rightW, 18)];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        _titleLabel.textColor = DARK_GRAY; _titleLabel.text = @"未选择歌曲";
        [self addSubview:_titleLabel];

        // ── Progress ──────────────────────────────────
        CGFloat py = pad + 18 + 6;
        _timeCur = [self timeLabel:CGRectMake(rightX, py, 32, 12)];
        _progressBar = [[UIView alloc] initWithFrame:CGRectMake(rightX+36, py+4, rightW-72, 2.5)];
        _progressBar.backgroundColor = [UIColor colorWithRed:0.88 green:0.92 blue:0.94 alpha:1];
        _progressBar.layer.cornerRadius = 1.25;
        _progressBar.clipsToBounds = YES;
        _progressFill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2.5)];
        _progressFill.backgroundColor = [UIColor colorWithRed:0.23 green:0.51 blue:0.96 alpha:1];
        [_progressBar addSubview:_progressFill];
        _timeTotal = [self timeLabel:CGRectMake(rightX+rightW-32, py, 32, 12)];
        [self addSubview:_progressBar];

        // ── Controls ──────────────────────────────────
        CGFloat cy = py + 12 + 8;
        _favBtn = [self circleBtn:CGRectMake(rightX, cy, 34, 34) icon:@"heart" color:PINK sel:@selector(onFav)];
        _prevBtn = [self circleBtn:CGRectMake(rightX+44, cy, 34, 34) icon:@"backward.end.fill" color:ACCENT_BLUE sel:@selector(onPrevTap)];
        _playBtn = [self circleBtn:CGRectMake(rightX+44+40, cy, 42, 42) icon:@"play.fill" color:ACCENT_BLUE sel:@selector(onPlayTap)];
        _nextBtn = [self circleBtn:CGRectMake(rightX+44+40+48, cy, 34, 34) icon:@"forward.end.fill" color:ACCENT_BLUE sel:@selector(onNextTap)];
        [self addSubview:_favBtn];
        [self addSubview:_prevBtn];
        [self addSubview:_playBtn];
        [self addSubview:_nextBtn];

        // ── Speed Capsules ────────────────────────────
        CGFloat sx = rightX + 120;
        _speedDown  = [self capsuleBtn:CGRectMake(sx, cy+4, 42, 26) text:@"-0.1" sel:@selector(onSpeedDown)];
        _speedReset = [self capsuleBtn:CGRectMake(sx+46, cy+4, 42, 26) text:@"还原" sel:@selector(onSpeedReset)];
        _speedUp    = [self capsuleBtn:CGRectMake(sx+92, cy+4, 42, 26) text:@"+0.1" sel:@selector(onSpeedUp)];
        _speedUp02  = [self capsuleBtn:CGRectMake(sx+138, cy+4, 42, 26) text:@"+0.2" sel:@selector(onSpeedUp02)];
        _speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(sx+184, cy+4, 40, 26)];
        _speedLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
        _speedLabel.textColor = TEXT_SEC; _speedLabel.text = @"1.0x";
        [self addSubview:_speedDown]; [self addSubview:_speedReset];
        [self addSubview:_speedUp]; [self addSubview:_speedUp02]; [self addSubview:_speedLabel];

        // ── Close Button ──────────────────────────────
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(w-30, 4, 24, 24);
        _closeBtn.backgroundColor = RED_CLOSE;
        _closeBtn.layer.cornerRadius = 12;
        [_closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        _closeBtn.titleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
        [_closeBtn addTarget:self action:@selector(onCloseTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeBtn];

        // Drag gesture
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (UILabel *)timeLabel:(CGRect)frame {
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.font = [UIFont systemFontOfSize:10]; l.textColor = [UIColor colorWithRed:0.58 green:0.64 blue:0.69 alpha:1];
    l.text = @"00:00"; l.textAlignment = NSTextAlignmentCenter;
    [self addSubview:l]; return l;
}

- (UIButton *)circleBtn:(CGRect)frame icon:(NSString *)icon color:(UIColor *)color sel:(SEL)sel {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = frame;
    b.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    b.layer.cornerRadius = frame.size.width / 2;
    b.layer.borderColor = [color colorWithAlphaComponent:0.5].CGColor;
    b.layer.borderWidth = 1.5;
    [b setImage:[UIImage systemImageNamed:icon] forState:UIControlStateNormal];
    b.tintColor = color;
    [b addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return b;
}

- (UIButton *)capsuleBtn:(CGRect)frame text:(NSString *)text sel:(SEL)sel {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = frame;
    b.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    b.layer.cornerRadius = 13;
    [b setTitle:text forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    [b setTitleColor:[UIColor colorWithRed:0.35 green:0.42 blue:0.50 alpha:1] forState:UIControlStateNormal];
    [b addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return b;
}

// ── Actions ──────────────────────────────────────────
- (void)onCloseTap { if (self.onClose) self.onClose(); }
- (void)onFav { if (self.onFavorite) self.onFavorite(); }
- (void)onPrevTap { if (self.onPrev) self.onPrev(); }
- (void)onPlayTap { if (self.onPlayPause) self.onPlayPause(); }
- (void)onNextTap { if (self.onNext) self.onNext(); }
- (void)onSpeedDown { if (self.onSpeedDown) self.onSpeedDown(); }
- (void)onSpeedReset { if (self.onSpeedReset) self.onSpeedReset(); }
- (void)onSpeedUp { if (self.onSpeedUp) self.onSpeedUp(); }
- (void)onSpeedUp02 { if (self.onSpeedUp02) self.onSpeedUp02(); }

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint t = [gesture translationInView:self.superview];
    self.superview.center = CGPointMake(self.superview.center.x + t.x, self.superview.center.y + t.y);
    [gesture setTranslation:CGPointZero inView:self.superview];
}

// ── State Setters ────────────────────────────────────
- (void)setSongName:(NSString *)name { _titleLabel.text = name; }
- (void)setProgress:(float)progress current:(NSString *)cur total:(NSString *)tot {
    _timeCur.text = cur; _timeTotal.text = tot;
    CGRect f = _progressFill.frame;
    f.size.width = _progressBar.frame.size.width * progress;
    _progressFill.frame = f;
}
- (void)setPlaying:(BOOL)playing paused:(BOOL)paused {
    _isPlaying = playing; _isPaused = paused;
    NSString *icon = (playing && !paused) ? @"pause.fill" : @"play.fill";
    [_playBtn setImage:[UIImage systemImageNamed:icon] forState:UIControlStateNormal];
}
- (void)setFavorite:(BOOL)fav {
    _isFavorite = fav;
    NSString *icon = fav ? @"heart.fill" : @"heart";
    [_favBtn setImage:[UIImage systemImageNamed:icon] forState:UIControlStateNormal];
    _favBtn.tintColor = fav ? RED_CLOSE : ACCENT_BLUE;
}
- (void)setSpeed:(NSString *)speed { _speedLabel.text = speed; }
@end

// ============================================================
// MARK: - Card Info View
// ============================================================
@implementation PWCardInfoView {
    UILabel *_keyLabel, *_expiryLabel, *_deviceLabel, *_statusLabel;
    UIButton *_closeBtn, *_changeBtn;
}

+ (instancetype)show {
    return [[PWCardInfoView alloc] initWithFrame:CGRectMake(0, 0, 320, 260)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = GLASS_BG;
        self.layer.cornerRadius = 34;
        self.clipsToBounds = YES;

        // Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 200, 22)];
        title.text = @"卡密信息"; title.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBlack];
        title.textColor = DARK_GRAY; [self addSubview:title];

        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(frame.size.width-40, 14, 26, 26);
        _closeBtn.backgroundColor = RED_CLOSE; _closeBtn.layer.cornerRadius = 13;
        [_closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        _closeBtn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        [_closeBtn addTarget:self action:@selector(onCloseTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeBtn];

        // Status badge
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 46, 288, 36)];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.layer.cornerRadius = 10; _statusLabel.clipsToBounds = YES;
        _statusLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBlack];
        [self addSubview:_statusLabel];

        // Info rows
        [self infoRow:76 label:@"卡密" value:@"" tag:&_keyLabel];
        [self infoRow:108 label:@"到期时间" value:@"试用1小时" tag:&_expiryLabel];
        [self infoRow:140 label:@"设备ID" value:@"---" tag:&_deviceLabel];

        // Change button
        _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeBtn.frame = CGRectMake(16, 178, 288, 44);
        _changeBtn.backgroundColor = PURPLE; _changeBtn.layer.cornerRadius = 10;
        [_changeBtn setTitle:@"更换卡密" forState:UIControlStateNormal];
        _changeBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
        [self addSubview:_changeBtn];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)infoRow:(CGFloat)y label:(NSString *)label value:(NSString *)value tag:(UILabel **)tag {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(16, y, 60, 20)];
    lbl.text = label; lbl.font = [UIFont systemFontOfSize:13]; lbl.textColor = TEXT_SEC;
    [self addSubview:lbl];
    UILabel *val = [[UILabel alloc] initWithFrame:CGRectMake(80, y, 224, 20)];
    val.text = value; val.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    val.textColor = DARK_GRAY; val.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self addSubview:val];
    if (tag) *tag = val;
}

- (void)setCardKey:(NSString *)key verified:(BOOL)verified deviceId:(NSString *)did {
    _keyLabel.text = key.length ? key : @"未输入";
    _deviceLabel.text = did;
    if (verified) {
        _statusLabel.text = @"已激活 · 有效";
        _statusLabel.backgroundColor = [UIColor colorWithRed:0.83 green:0.93 blue:0.86 alpha:1];
        _statusLabel.textColor = [UIColor colorWithRed:0.08 green:0.34 blue:0.15 alpha:1];
    } else {
        _statusLabel.text = @"未验证 · 待激活";
        _statusLabel.backgroundColor = [UIColor colorWithRed:1.0 green:0.95 blue:0.80 alpha:1];
        _statusLabel.textColor = [UIColor colorWithRed:0.52 green:0.33 blue:0.02 alpha:1];
    }
}

- (void)onCloseTap { if (self.onClose) self.onClose(); }
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint t = [gesture translationInView:self.superview];
    self.superview.center = CGPointMake(self.superview.center.x + t.x, self.superview.center.y + t.y);
    [gesture setTranslation:CGPointZero inView:self.superview];
}
@end

// ============================================================
// MARK: - Backup View
// ============================================================
@implementation PWBackupView {
    UILabel *_countLabel;
}

+ (instancetype)show {
    return [[PWBackupView alloc] initWithFrame:CGRectMake(0, 0, 340, 250)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = GLASS_BG; self.layer.cornerRadius = 34; self.clipsToBounds = YES;

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 200, 22)];
        title.text = @"收藏备份与恢复"; title.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBlack];
        title.textColor = DARK_GRAY; [self addSubview:title];

        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 44, 300, 18)];
        _countLabel.font = [UIFont systemFontOfSize:13]; _countLabel.textColor = TEXT_SEC;
        [self addSubview:_countLabel];

        NSArray *buttons = @[
            @{@"title":@"📁 备份到本地", @"color":PURPLE, @"sel":NSStringFromSelector(@selector(onLocal))},
            @{@"title":@"☁️ 上传到云端", @"color":BLUE, @"sel":NSStringFromSelector(@selector(onUpload))},
            @{@"title":@"⬇️ 从云端恢复", @"color":GREEN, @"sel":NSStringFromSelector(@selector(onDownload))},
        ];
        for (int i = 0; i < buttons.count; i++) {
            NSDictionary *b = buttons[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(16, 72 + i * 52, 308, 44);
            btn.backgroundColor = b[@"color"]; btn.layer.cornerRadius = 12;
            [btn setTitle:b[@"title"] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
            [btn addTarget:self action:NSSelectorFromString(b[@"sel"]) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }

        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(frame.size.width-42, 14, 26, 26);
        closeBtn.backgroundColor = RED_CLOSE; closeBtn.layer.cornerRadius = 13;
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        closeBtn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        [closeBtn addTarget:self action:@selector(onCloseTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)setFavoriteCount:(NSInteger)count { _countLabel.text = [NSString stringWithFormat:@"当前收藏 %ld 首歌曲", (long)count]; }
- (void)onLocal { if (self.onBackupLocal) self.onBackupLocal(); }
- (void)onUpload { if (self.onUploadServer) self.onUploadServer(); }
- (void)onDownload { if (self.onDownloadServer) self.onDownloadServer(); }
- (void)onCloseTap { if (self.onClose) self.onClose(); }

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint t = [gesture translationInView:self.superview];
    self.superview.center = CGPointMake(self.superview.center.x + t.x, self.superview.center.y + t.y);
    [gesture setTranslation:CGPointZero inView:self.superview];
}
@end
