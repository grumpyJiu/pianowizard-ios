/**
 * PianoWizard Plugin Bridge (ObjC)
 *
 * Bridges Swift UI (PWOverlayManager) with ObjC hook (Tweak.xm).
 * Also provides PTFakeMetaTouch integration for auto-play.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Forward declare Swift class
@class PWPluginBridge;

@interface PWPluginBridge : NSObject
+ (instancetype)shared;
- (void)startPlugin;
- (void)stopPlugin;
- (void)showMainPanel;
- (void)hideMainPanel;
- (void)playSongAtKeys:(NSArray<NSValue *> *)points durations:(NSArray<NSNumber *> *)durations;
@end

// ============================================================
// Touch simulation wrapper (uses PTFakeMetaTouch)
// ============================================================
@interface PWTouchSimulator : NSObject
/// Tap at a screen point
+ (void)tapAtPoint:(CGPoint)point;
/// Hold at a point for duration (ms)
+ (void)holdAtPoint:(CGPoint)point duration:(NSTimeInterval)duration;
/// Release all touches
+ (void)releaseTouches;
@end

@implementation PWTouchSimulator

+ (void)tapAtPoint:(CGPoint)point {
    NSInteger pointId = [objc_getClass("PTFakeMetaTouch") getAvailablePointId];
    [objc_getClass("PTFakeMetaTouch") fakeTouchId:pointId
                                          AtPoint:point
                                  withTouchPhase:UITouchPhaseBegan];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [objc_getClass("PTFakeMetaTouch") fakeTouchId:pointId
                                              AtPoint:point
                                      withTouchPhase:UITouchPhaseEnded];
    });
}

+ (void)holdAtPoint:(CGPoint)point duration:(NSTimeInterval)duration {
    NSInteger pointId = [objc_getClass("PTFakeMetaTouch") getAvailablePointId];
    [objc_getClass("PTFakeMetaTouch") fakeTouchId:pointId
                                          AtPoint:point
                                  withTouchPhase:UITouchPhaseBegan];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [objc_getClass("PTFakeMetaTouch") fakeTouchId:pointId
                                              AtPoint:point
                                      withTouchPhase:UITouchPhaseEnded];
    });
}

+ (void)releaseTouches {
    // PTFakeMetaTouch manages touches internally, no cleanup needed
}

@end
