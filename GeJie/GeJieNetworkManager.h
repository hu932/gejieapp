#import <Foundation/Foundation.h>

@interface GeJieNetworkManager : NSObject

@property (nonatomic, strong) NSString *token;

+ (instancetype)sharedManager;

- (void)loginWithCompletion:(void (^)(BOOL success, NSString *errorMsg))completion;
- (void)fetchTaskWithCompletion:(void (^)(BOOL success, NSDictionary *taskData, NSString *errorMsg))completion;
- (void)submitTaskWithItemId:(NSString *)itemId shopId:(NSString *)shopId result:(NSString *)result completion:(void (^)(BOOL success, NSString *errorMsg))completion;

@end