//
//  MyBackendLib.m
//  PaymentSDKObjC
//
//  Created by Gustavo Sotelo on 27/11/17.
// Sample of  MyBackendLib. The implementation of these methods may be different on your application.
//  Copyright © 2017 Payment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PaymentSDK/PaymentSDK-Swift.h>
#import "MyBackendLib.h"

@implementation MyBackendLib
static NSString *myBackendUrl = @"https://example-Payment-backend.herokuapp.com/";

+(NSString *)myBackendUrl{
    return myBackendUrl;
}

+ (void) verifyTrxWithId:(NSString*)uid type:(int)type value:(NSString*)val callback:(void (^)(PaymentSDKError *error, BOOL *verified))callback
{
    //TODO implement verify sample
}
+ (void) deleteCardWithId:(NSString*)uid cardToken:(NSString*)cardToken callback:(void (^)(BOOL *deleted))callback
{
    //TODO implement deletecard 
}
+ (void) debitCardWithId:(NSString*)uid cardToken:(NSString*)cardToken sessionId:(NSString*)sessionId devReference:(NSString*)devReference amount:(double)amount description:(NSString*)description callback:(void (^)(NSError *error, PaymentTransaction *transaction))callback
{
    NSDictionary *params = @{@"uid": uid, @"token":cardToken, @"session_id":sessionId, @"amount": [NSString stringWithFormat:@"%.2f", amount], @"dev_reference":devReference, @"description":description};
    
    [self makeRequestPostFromUrl:@"create-charge" parameters:params responseCallback:^(NSError *error, NSInteger status, id responseData) {
        if (error == nil)
        {
            if (status == 200)
            {
                NSDictionary *responseD = (NSDictionary *)responseData;
                NSDictionary *transaction = responseD[@"transaction"];
                PaymentTransaction *trx = [[PaymentTransaction alloc] init];
                
                trx.amount = transaction[@"amount"];
                trx.status = transaction[@"status"];
                trx.statusDetail = transaction[@"status_detail"];
                trx.transactionId = transaction[@"id"];
                trx.carrierCode = transaction[@"carrier_code"];
                trx.message = transaction[@"message"];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
                
                if (responseD[@"payment_date"] != nil)
                {
                    trx.paymentDate = [dateFormatter dateFromString:responseD[@"payment_date"]];
                }
                if ([trx.statusDetail integerValue] != 3)
                {
                    callback(error,trx);
                }
                else
                {
                    callback(nil, trx);
                }
                
                
            }
            else
            {
              callback(error,nil);
            }
        }
        else
        {
            callback(error,nil);
        }
        
    }];
    
}
+ (void) listCardWithId:(NSString*)uid callback:(void (^)(NSMutableArray *cardList))callback
{
    NSDictionary *parameters = @{@"uid" : uid};
    
    [self makeRequestGetFromUrl:@"get-cards" parameters:parameters
               responseCallback:^(NSError *error, NSInteger status, id responseData) {
                   NSMutableArray *responseCards = [[NSMutableArray alloc] init];
                   if (error == nil)
                   {
                       if(status == 200)
                       {
                           NSDictionary *responseObj = (NSDictionary*)responseData;
                           NSArray *cardsArray = (NSArray*)responseObj[@"cards"];
                           for(NSDictionary* card in cardsArray)
                           {
                               PaymentCard *pCard = [[PaymentCard alloc] init];
                               pCard.bin = (NSString*) card[@"bin"];
                               pCard.token = (NSString*)  card[@"token"];
                               pCard.cardHolder = (NSString*)  card[@"holder_name"];
                               pCard.expiryMonth = (NSString*) card[@"expiry_month"];
                               pCard.expiryYear = (NSString*) card[@"expiry_year"];
                               pCard.termination = (NSString*)  card[@"number"];
                               pCard.status = (NSString*) card[@"status"];
                               pCard.type = (NSString*) card[@"type"];
                               [responseCards addObject:pCard];
                           }
                           
                           callback(responseCards);
                       }
                       else
                       {
                           callback(responseCards);
                       }
                   }
                   else
                   {
                       callback(responseCards);
                   }
               }];
    
}
+ (void) makeRequestGetFromUrl:(NSString*)urlToRequest parameters:(NSDictionary*)parameters responseCallback:(void (^)(NSError *error, NSInteger status,  id responseData))responseCallback
{
    NSLog(@"%@",self.myBackendUrl);
    NSString *completeUrl = [self.myBackendUrl stringByAppendingString:urlToRequest];
    NSString *bodyData = @"";
    for (NSString* key in parameters) {
        NSString *value = (NSString*)[parameters objectForKey:key];
        NSString *scapedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
        NSString *scapedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
        bodyData = [NSString stringWithFormat:@"%@&%@=%@", bodyData, scapedKey, scapedValue];
        // do stuff
    }
    completeUrl = [NSString stringWithFormat:@"%@?%@", completeUrl, bodyData];
    NSURL *url = [NSURL URLWithString:completeUrl];
    
    NSURLSession *session = NSURLSession.sharedSession;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@", data);
        if (error == nil)
        {
            id json = nil;
            
            json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            
            if (!json) {
                responseCallback(error,400,nil);
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                responseCallback(error, [httpResponse statusCode], json);
            }
        }
        else
        {
            responseCallback(error, 400, nil);
        }
    }];
    [task resume];
}
+ (void) makeRequestPostFromUrl:(NSString*)urlToRequest parameters:(NSDictionary*)parameters responseCallback:(void (^)(NSError *error, NSInteger status,  id responseData))responseCallback
{
    NSString *completeUrl = [self.myBackendUrl stringByAppendingString:urlToRequest];
    NSURL *url = [NSURL URLWithString:completeUrl];
    
    NSURLSession *session = NSURLSession.sharedSession;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [self encodeParameters:parameters];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil)
        {
            id json = nil;
            
            json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            
            if (!json) {
                responseCallback(error,400,nil);
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                responseCallback(error, [httpResponse statusCode], json);
            }
        }
        else
        {
            responseCallback(error, 400, nil);
        }
    }];
    [task resume];
    
}

+ (NSData*) encodeParameters:(NSDictionary*)parameters
{
    NSString *bodyData = @"";
    for (NSString* key in parameters) {
        NSString *value = (NSString*)[parameters objectForKey:key];
        NSString *scapedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
        NSString *scapedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
        bodyData = [NSString stringWithFormat:@"%@&%@=%@", bodyData, scapedKey, scapedValue];
        // do stuff
    }
    return [bodyData dataUsingEncoding:NSUTF8StringEncoding];
}



@end
