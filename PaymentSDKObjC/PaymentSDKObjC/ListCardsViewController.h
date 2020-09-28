//
//  ListCardsViewController.h
//  PaymentSDKObjC
//
//  Created by Gustavo Sotelo on 27/11/17.
//  Copyright © 2017 Payment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PaymentSDK/PaymentSDK-Swift.h>

@protocol CardSelectedDelegate

- (void) cardSelected:(PaymentCard*)card;
@end

@interface ListCardsViewController : UITableViewController<PaymentCardAddedDelegate>
@property (strong) id<CardSelectedDelegate>cardSelectedDelegate;
@property (strong) NSMutableArray *cardList;
@end
