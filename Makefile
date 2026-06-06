# PianoWizard iOS Tweak — Pure ObjC/UIKit
export TARGET = iphone:clang:latest:14.0
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PianoWizard

PianoWizard_FILES = \
    Tweak.xm \
    PWPluginBridge.m \
    PWUI.m \
    DragView.m \
    PTFakeMetaTouch.m \
    IOHIDEvent+KIF.m \
    CALayer-KIFAdditions.m \
    CGGeometry-KIFAdditions.m \
    NSBundle-KIFAdditions.m

PianoWizard_FRAMEWORKS = UIKit Foundation CoreGraphics
PianoWizard_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
