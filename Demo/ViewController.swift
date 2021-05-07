//
//  ViewController.swift
//  Demo
//
//  Created by Ernesto Gonzalez Nochebuena on 17/12/20.
//  Copyright © 2020 Paymentez. All rights reserved.
//

import UIKit
import PaymentSDK

class ViewController: PaymentAddNativeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let paymentAddVC = self.addPaymentWidget(toView: self.view, delegate: nil, uid:UserModel.uid, email:UserModel.email)
        
        paymentAddVC.baseFontColor = .black
        paymentAddVC.baseColor = .blue
        paymentAddVC.backgroundColor = .white
        paymentAddVC.showLogo = true
    
    
//        paymentAddVC.baseFont = UIFont(name: "Your Font", size: 12) ?? UIFont.systemFont(ofSize: 12)
        // Do any additional setup after loading the view.
    }

}

