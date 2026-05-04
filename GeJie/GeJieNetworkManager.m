#import "GeJieNetworkManager.h"

#define BASE_URL @"https://eqwofaygdsjko.uk:443"

@implementation GeJieNetworkManager

+ (instancetype)sharedManager {
    static GeJieNetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)loginWithIdentifier:(NSString *)identifier
                   password:(NSString *)password
                  completion:(void (^)(BOOL success, NSString *errorMsg))completion {
    if (identifier.length == 0 || password.length == 0) {
        if (completion) completion(NO, @"标识或密码不能为空");
        return;
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/user/login", BASE_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    
    NSDictionary *bodyDict = @{@"username": identifier, @"password": password};
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:nil];
    request.HTTPBody = bodyData;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completion) completion(NO, error.localizedDescription);
            return;
        }
        
        NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (respDict && respDict[@"data"] && respDict[@"data"][@"token"]) {
            self.token = respDict[@"data"][@"token"];
            if (completion) completion(YES, nil);
        } else {
            if (completion) completion(NO, @"Login failed: No token returned");
        }
    }];
    [task resume];
}

- (void)fetchTaskWithCompletion:(void (^)(BOOL success, NSDictionary *taskData, NSString *errorMsg))completion {
    if (!self.token) {
        if (completion) completion(NO, nil, @"Not logged in");
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/task/take", BASE_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completion) completion(NO, nil, error.localizedDescription);
            return;
        }
        
        NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (respDict && [respDict[@"code"] integerValue] == 200) {
            if (completion) completion(YES, respDict[@"data"], nil);
        } else {
            if (completion) completion(NO, nil, respDict ? respDict[@"msg"] : @"Unknown error");
        }
    }];
    [task resume];
}

- (void)submitTaskWithItemId:(NSString *)itemId shopId:(NSString *)shopId result:(NSString *)result completion:(void (^)(BOOL success, NSString *errorMsg))completion {
    if (!self.token) {
        if (completion) completion(NO, @"Not logged in");
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/task/submit/v2", BASE_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    
    NSString *shopeeUrl = [NSString stringWithFormat:@"https://shopee.tw/api/v4/pdp/get_pc?display_model_id=0&item_id=%@&model_selection_logic=3&shop_id=%@&tz_offset_in_minutes=480&detail_level=0", itemId, shopId];
    
    NSDictionary *bodyDict = @{
        @"appVersion": @"vv2",
        @"url": shopeeUrl,
        @"result": result ? result : @"{\"error\":null,\"bff_meta\":null}"
    };
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:nil];
    request.HTTPBody = bodyData;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completion) completion(NO, error.localizedDescription);
            return;
        }
        if (completion) completion(YES, nil);
    }];
    [task resume];
}

@end