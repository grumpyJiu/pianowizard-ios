/**
 * PianoWizard iOS Tweak Entry Point
 * Injects into SpringBoard to provide floating piano overlay.
 *
 * Architecture (from reference):
 *   - UIWindow for floating overlays
 *   - DragView for draggable panels
 *   - PTFakeMetaTouch for auto-play
 *   - PWPluginBridge (ObjC) bridges to Swift UI
 */

#import <substrate.h>
#import <UIKit/UIKit.h>

// Forward declare bridge class (defined in PWPluginBridge.m)
@interface PWPluginBridge : NSObject
+ (instancetype)shared;
- (void)startPlugin;
- (void)stopPlugin;
@end

static PWPluginBridge *bridge = nil;

// ─── Hook SpringBoard ────────────────────────────────────
static void (*orig_didFinishLaunching)(id, SEL, UIApplication *);
static void hook_didFinishLaunching(id self, SEL _cmd, UIApplication *app) {
    orig_didFinishLaunching(self, _cmd, app);

    if (!bridge) {
        bridge = [PWPluginBridge shared];
        [bridge startPlugin];
    }
}

// ─── Hook UIApplication sendEvent for global touch ────────
// Needed to detect touches in other apps for coordinate setup
static void (*orig_sendEvent)(id, SEL, UIEvent *);
static void hook_sendEvent(id self, SEL _cmd, UIEvent *event) {
    orig_sendEvent(self, _cmd, event);
    // Forward to plugin for coordinate detection
}

// ─── Constructor ──────────────────────────────────────────
__attribute__((constructor))
static void pianoWizardInit() {
    @autoreleasepool {
        Class sbClass = NSClassFromString(@"SpringBoard");
        if (sbClass) {
            MSHookMessageEx(sbClass,
                @selector(applicationDidFinishLaunching:),
                (IMP)&hook_didFinishLaunching,
                (IMP*)&orig_didFinishLaunching);
        }

        MSHookMessageEx([UIApplication class],
            @selector(sendEvent:),
            (IMP)&hook_sendEvent,
            (IMP*)&orig_sendEvent);
    }
}
