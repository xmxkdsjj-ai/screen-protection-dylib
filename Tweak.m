#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Undocumented iOS API. This is best-effort and may not exist on every iOS version.
@interface UIWindow (SecureScreen)
- (void)_setSecure:(BOOL)secure;
@end

static IMP originalMakeKeyAndVisible = NULL;

static void ProtectWindow(UIWindow *window) {
    if (window == nil || ![window respondsToSelector:@selector(_setSecure:)]) {
        return;
    }

    [window _setSecure:YES];
}

static void ApplySecureScreenProtection(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *application = UIApplication.sharedApplication;
        NSMutableArray<UIWindow *> *windows = [NSMutableArray array];

        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in application.connectedScenes) {
                if (![scene isKindOfClass:UIWindowScene.class] ||
                    scene.activationState != UISceneActivationStateForegroundActive) {
                    continue;
                }

                [windows addObjectsFromArray:((UIWindowScene *)scene).windows];
            }
        } else {
            [windows addObjectsFromArray:application.windows];
        }

        for (UIWindow *window in windows) {
            ProtectWindow(window);
        }
    });
}

static void ProtectedMakeKeyAndVisible(UIWindow *window, SEL selector) {
    if (originalMakeKeyAndVisible != NULL) {
        ((void (*)(id, SEL))originalMakeKeyAndVisible)(window, selector);
    }

    ProtectWindow(window);
}

static void InstallWindowHook(void) {
    Method method = class_getInstanceMethod(UIWindow.class, @selector(makeKeyAndVisible));
    if (method == NULL || originalMakeKeyAndVisible != NULL) {
        return;
    }

    originalMakeKeyAndVisible = method_getImplementation(method);
    method_setImplementation(method, (IMP)ProtectedMakeKeyAndVisible);
}

__attribute__((constructor))
static void ScreenProtectionInit(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        InstallWindowHook();

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            ApplySecureScreenProtection();

            [[NSNotificationCenter defaultCenter]
                addObserverForName:UIApplicationDidBecomeActiveNotification
                            object:nil
                             queue:NSOperationQueue.mainQueue
                        usingBlock:^(__unused NSNotification *notification) {
                ApplySecureScreenProtection();
            }];
        });
    });
}
