# PianoWizard iOS Tweak
export TARGET = iphone:clang:latest:14.0
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PianoWizard

# All ObjC files (flat in this directory)
PianoWizard_FILES = \
    Tweak.xm \
    DragView.m \
    PTFakeMetaTouch.m \
    IOHIDEvent+KIF.m \
    CALayer-KIFAdditions.m \
    CGGeometry-KIFAdditions.m \
    NSBundle-KIFAdditions.m \
    PWPluginBridge.m \
    PWPluginLoader.swift \
    PWOverlayManager.swift \
    PWPlayerView.swift \
    PWFloatingBallView.swift \
    PWCardInfoView.swift \
    PWTheme.swift \
    PWModels.swift \
    PWMusicEngine.swift \
    PWNetworkClient.swift

PianoWizard_FRAMEWORKS = UIKit SwiftUI Combine Foundation
PianoWizard_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
