#import "GeJieFloatWindow.h"
#import "GeJieNetworkManager.h"

@interface GeJieFloatWindow ()

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UITextField *identifierField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) CGPoint startTouchPoint;

@end

@implementation GeJieFloatWindow

+ (instancetype)sharedWindow {
    static GeJieFloatWindow *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    sharedInstance = [[self alloc] initWithWindowScene:windowScene];
                    break;
                }
            }
        }
        if (!sharedInstance) {
            sharedInstance = [[self alloc] initWithFrame:CGRectMake(20, 100, 60, 60)];
        }
    });
    return sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene API_AVAILABLE(ios(13.0)) {
    self = [super initWithWindowScene:windowScene];
    if (self) {
        self.frame = CGRectMake(20, 100, 60, 60);
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.windowLevel = UIWindowLevelAlert + 1;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 30;
    self.isExpanded = NO;
    
    // Setup blur background
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:blurView];
    
    // Toggle Button (Gj Icon)
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleButton.frame = CGRectMake(0, 0, 60, 60);
    [self.toggleButton setTitle:@"Gj" forState:UIControlStateNormal];
    self.toggleButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.toggleButton addTarget:self action:@selector(toggleExpanded) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toggleButton];
    
    // Add pan gesture for dragging
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
    
    // Setup expanded content view
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 200, 180)];
    self.contentView.alpha = 0;
    [self addSubview:self.contentView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 20)];
    self.titleLabel.text = @"格界 v1.0";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];
    
    self.identifierField = [[UITextField alloc] initWithFrame:CGRectMake(20, 36, 160, 30)];
    self.identifierField.placeholder = @"输入标识";
    self.identifierField.textColor = [UIColor whiteColor];
    self.identifierField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.08];
    self.identifierField.layer.cornerRadius = 8;
    self.identifierField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.identifierField.leftViewMode = UITextFieldViewModeAlways;
    [self.contentView addSubview:self.identifierField];

    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20, 72, 160, 30)];
    self.passwordField.placeholder = @"输入密码";
    self.passwordField.secureTextEntry = YES;
    self.passwordField.textColor = [UIColor whiteColor];
    self.passwordField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.08];
    self.passwordField.layer.cornerRadius = 8;
    self.passwordField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    [self.contentView addSubview:self.passwordField];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 106, 180, 24)];
    self.statusLabel.text = @"等待连接...";
    self.statusLabel.textColor = [UIColor lightGrayColor];
    self.statusLabel.font = [UIFont systemFontOfSize:12];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 1;
    [self.contentView addSubview:self.statusLabel];
    
    self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.actionButton.frame = CGRectMake(20, 134, 160, 36);
    [self.actionButton setTitle:@"开始运行" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.actionButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    self.actionButton.layer.cornerRadius = 18;
    [self.actionButton addTarget:self action:@selector(actionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.actionButton];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    if (self.isExpanded) return; // Don't drag when expanded
    
    CGPoint translation = [pan translationInView:self.superview];
    CGPoint center = self.center;
    center.x += translation.x;
    center.y += translation.y;
    self.center = center;
    [pan setTranslation:CGPointZero inView:self.superview];
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        // Snap to edge
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat x = (self.center.x < screenWidth / 2) ? 30 : screenWidth - 30;
        [UIView animateWithDuration:0.3 animations:^{
            self.center = CGPointMake(x, self.center.y);
        }];
    }
}

- (void)toggleExpanded {
    self.isExpanded = !self.isExpanded;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.isExpanded) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 200, 180);
            self.layer.cornerRadius = 20;
            self.toggleButton.frame = CGRectMake(70, 0, 60, 60);
            self.contentView.alpha = 1;
        } else {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 60, 60);
            self.layer.cornerRadius = 30;
            self.toggleButton.frame = CGRectMake(0, 0, 60, 60);
            self.contentView.alpha = 0;
        }
    } completion:nil];
}

- (void)updateStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = status;
    });
}

- (void)actionButtonClicked {
    [self updateStatus:@"正在登录..."];
    [[GeJieNetworkManager sharedManager] loginWithIdentifier:self.identifierField.text password:self.passwordField.text completion:^(BOOL success, NSString *errorMsg) {
        if (success) {
            [self updateStatus:@"登录成功，获取任务..."];
            [self startTaskLoop];
        } else {
            [self updateStatus:[NSString stringWithFormat:@"登录失败: %@", errorMsg]];
        }
    }];
}

- (void)startTaskLoop {
    [[GeJieNetworkManager sharedManager] fetchTaskWithCompletion:^(BOOL success, NSDictionary *taskData, NSString *errorMsg) {
        if (success) {
            [self updateStatus:[NSString stringWithFormat:@"获取到任务: %@", taskData]];
            // Mock: Submit task after 2 seconds
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[GeJieNetworkManager sharedManager] submitTaskWithItemId:@"mockItem" shopId:@"mockShop" result:nil completion:^(BOOL s, NSString *e) {
                    if (s) {
                        [self updateStatus:@"任务提交成功"];
                    } else {
                        [self updateStatus:[NSString stringWithFormat:@"任务提交失败: %@", e]];
                    }
                }];
            });
        } else {
            [self updateStatus:[NSString stringWithFormat:@"获取任务失败: %@", errorMsg]];
        }
    }];
}

- (void)show {
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

// Pass touch events to the views behind if they are not touching our subviews
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.isExpanded) {
        return YES;
    }
    return CGRectContainsPoint(self.toggleButton.frame, point);
}

@end