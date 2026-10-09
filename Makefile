ARCHS = arm64
TARGET = iphone:clang:latest:13.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = ScreenProtection
ScreenProtection_FILES = Tweak.m
ScreenProtection_CFLAGS = -fobjc-arc
ScreenProtection_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/library.mk
