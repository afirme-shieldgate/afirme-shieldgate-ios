//
//  PaymentCardScan.swift
//  PaymentSDKSample
//
//  Created by Gustavo Sotelo on 04/05/16.
//  Copyright © 2016 Payment. All rights reserved.
//

import Foundation

class PaymentCardScan:NSObject, CardIOPaymentViewControllerDelegate
{
    
    //MARK - CardIO
    var viewController:UIViewController?
    
    var callback:((_ infoCard:CardIOCreditCardInfo?)->Void)?
    var scanVc:CardIOPaymentViewController?
    
    override init()
    {
        super.init()
        self.scanVc = CardIOPaymentViewController(paymentDelegate: self)
        self.scanVc?.hideCardIOLogo = true
    }
    
    func showScan(_ vc:UIViewController, callback:@escaping (_ infoCard:CardIOCreditCardInfo?)->Void)
    
    {
        self.callback = callback
        self.scanVc = CardIOPaymentViewController(paymentDelegate: self)
        vc.present(self.scanVc!, animated: true, completion: nil)
        
    }
    
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        self.scanVc?.dismiss(animated: true, completion: nil)
        callback!(nil)
        
    }
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        self.scanVc?.dismiss(animated: true, completion: nil)
        callback!(cardInfo)
        
    }
}
