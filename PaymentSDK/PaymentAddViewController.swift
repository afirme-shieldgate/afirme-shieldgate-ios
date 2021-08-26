//
//  PaymentAddViewController.swift
//  PaymentSDK
//
//  Created by Gustavo Sotelo on 11/05/16.
//  Copyright © 2016 Payment. All rights reserved.
//

import UIKit

class PaymentAddViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var urlToLoad = ""
    var callback:((_ error:PaymentSDKError?, _ isClose:Bool, _ added:Bool) -> Void)? = nil
    
    @IBOutlet weak var webView: UIWebView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    init(callback:@escaping (_ error:PaymentSDKError?, _ isClose:Bool, _ added:Bool) -> Void)
    {
        
        self.urlToLoad = ""
        self.callback = callback
        let privatePath : NSString? = Bundle.main.privateFrameworksPath as NSString?
        if privatePath != nil {
            let path = privatePath!.appendingPathComponent("PaymentSDK.framework")
            let bundle =  Bundle(path: path)
            super.init(nibName: "PaymentAddViewController", bundle: bundle)
        }
        else
        {
            super.init()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closeAction(_ sender: Any) {
        
        self.dismiss(animated: true) { 
            self.callback!(nil, true, false)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
