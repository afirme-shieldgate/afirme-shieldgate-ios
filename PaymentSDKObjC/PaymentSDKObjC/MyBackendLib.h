//
//  MyBackendLib.h
//  PaymentSDKObjC
//
//  Created by Gustavo Sotelo on 27/11/17.
//  Copyright © 2017 Payment. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <PaymentSDK/PaymentSDK-Swift.h>


@interface MyBackendLib : NSObject

+ (void) verifyTrxWithId:(NSString*)uid type:(int)type value:(NSString*)val callback:(void (^)(PaymentSDKError *error, BOOL *verified))callback;
+ (void) deleteCardWithId:(NSString*)uid cardToken:(NSString*)cardToken callback:(void (^)(BOOL *deleted))callback;
+ (void) debitCardWithId:(NSString*)uid cardToken:(NSString*)cardToken sessionId:(NSString*)sessionId devReference:(NSString*)devReference amount:(double)amount description:(NSString*)description callback:(void (^)(PaymentSDKError *error, PaymentTransaction *transaction))callback;
+ (void) listCardWithId:(NSString*)uid callback:(void (^)(NSMutableArray *cardList))callback;
@end
