//
//  AddCustomViewController.h
//  PaymentSDKObjC
//
//  Created by Gustavo Sotelo on 11/05/16.
//  Copyright © 2016 Payment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PaymentSDK/PaymentSDK-Swift.h>

@interface AddCustomViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong) PaymentAddNativeViewController *PaymentAddVC;
@end
