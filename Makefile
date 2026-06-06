# PianoWizard iOS Tweak - Built with Theos
# iOS 光遇自动弹琴插件

export TARGET = iphone:clang:latest:14.0
export ARCHS = arm64 arm64e
export DEBUG = 0
export FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PianoWizard

PianoWizard_FILES = \
    Tweak.xm \
    Sources/PWPluginBridge.m \
    Sources/DragView.m \
    Sources/PTFakeMetaTouch.m \
    Sources/IOHIDEvent+KIF.m \
    Sources/CALayer-KIFAdditions.m \
    Sources/CGGeometry-KIFAdditions.m \
    Sources/NSBundle-KIFAdditions.m \
    $(wildcard Sources/*.swift)

PianoWizard_FRAMEWORKS = UIKit SwiftUI Combine Foundation CoreGraphics

PianoWizard_SWIFTFLAGS = -target arm64-apple-ios14.0

PianoWizard_LDFLAGS = -lsandbox -lsubstrate
PianoWizard_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
