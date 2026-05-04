#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import "GeJieFloatWindow.h"

// Hook target to hide the old UI from shopeehook
%hook UIWindow

- (void)makeKeyAndVisible {
    // Heuristic: If this is not our window, but a UIWindow with UIWindowLevelAlert (which shopeehook uses), we hide it.
    if (![self isKindOfClass:NSClassFromString(@"GeJieFloatWindow")]) {
        if (self.windowLevel >= UIWindowLevelAlert && [self.subviews count] > 0) {
            // Check subviews for signatures of the old app
            for (UIView *view in self.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    if ([label.text containsString:@"格界"] || [label.text containsString:@"虾皮"]) {
                        self.hidden = YES;
                        self.alpha = 0;
                        return; // Hide the original window completely
                    }
                }
            }
        }
    }
    %orig;
}

%end

// Hide alert controller from old tweak
%hook UIAlertController

- (void)viewWillAppear:(BOOL)animated {
    if (self.title && ([self.title containsString:@"格界"] || [self.title containsString:@"虾皮"])) {
        // Discard the old alert
        return;
    }
    %orig;
}

%end

%hook UIApplication

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Show our modern float window
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[GeJieFloatWindow sharedWindow] show];
        });
        
        // Dynamically load the original shopeehook.dylib if it exists
        // so that its core functionalities (unban, memory hooking) are active.
        void *handle = dlopen("/Library/MobileSubstrate/DynamicLibraries/shopeehook.dylib", RTLD_LAZY);
        if (handle) {
            NSLog(@"[GeJie] Successfully loaded original shopeehook.dylib");
        } else {
            NSLog(@"[GeJie] Failed to load shopeehook.dylib");
        }
    });
}

%end

%ctor {
    // Initialize our tweak
    NSLog(@"[GeJie] Tweak loaded, preparing to overlay UI...");
}