#import <UIKit/UIKit.h>

@interface GeJieFloatWindow : UIWindow

+ (instancetype)sharedWindow;
- (void)show;
- (void)hide;
- (void)updateStatus:(NSString *)status;

@end