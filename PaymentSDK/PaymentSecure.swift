//
//  PaymentSecure.swift
//  PaymentSDKSample
//
//  Created by Gustavo Sotelo on 04/05/16.
//  Copyright © 2016 Payment. All rights reserved.
//

import Foundation
import UIKit

class PaymentSecure: NSObject

{
    let targetUrlDev = "https://tst.kaptcha.com/logo.htm"
    let targetUrlProd = "https://ssl.kaptcha.com/logo.htm"
    var merchantId:String  = "500005"  {
        didSet
        {
            deviceCollector.merchantID = Int(self.merchantId)!
        }
    }
    let deviceCollector:KDataCollector = KDataCollector.shared()
    var testMode = true
    var callback:((_ err:NSError?) -> Void)?
    
    init(testMode:Bool)
    {
        deviceCollector.locationCollectorConfig = KLocationCollectorConfig.requestPermission
        
        // KDataCollector.shared().environment = KEnvironment.production
        if(testMode)
        {
            deviceCollector.environment = KEnvironment.test
            //self.deviceCollector.setCollectorUrl(targetUrlDev)
        }
        else{
            deviceCollector.environment = KEnvironment.production
            
            //self.deviceCollector.setCollectorUrl(targetUrlProd)
        }
        self.callback = nil
        super.init()
        
    }
    
    open func getSecureSessionId() -> String!
    {
        let sessioniD = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        
        collect(sessioniD) { (error) in
            
        }
        return sessioniD
    }
    
    func generateSessionId() -> String!
    {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
    
    func collect(_ sessionId:String, callback:@escaping (_ err:NSError?) -> Void)
    {
        deviceCollector.collect(forSession: sessionId) { (sessionID, success, error) in
            callback(error as NSError?)
            // Add handler code here if desired. The completion block is optional.
        }
    }
    
    func onCollectorStart() {
        
    }
    
    func onCollectorSuccess() {
        self.callback!(nil)
    }
    func onCollectorError(errorCode: Int32, withError error: NSError!) {
        
        self.callback!(error)
        
    }
    override func isEqual(_ anObject: Any?) -> Bool {
        return super.isEqual(anObject)
    }
    
    static func getIpAddress(_ callback:@escaping (_ ipAddress:String?)->Void)
    {
        var ip = "127.0.0.1"
        
        let completeUrl = "https://ccapi-stg.globalpay.com.co/api/cc/ip"
        let url:URL? = URL(string: completeUrl)
        let session = URLSession.shared
        
        var request = URLRequest(url:url!)
        /*do
         {
         
         let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
         request.HTTPBody = data
         }
         catch {
         
         }
         */
        request.httpMethod = "GET"
        
        
        let task = session.dataTask(with: request){ data, resp, err in
            
            if err == nil
            {
                ip = String(data: data!, encoding: String.Encoding.utf8)!
                
            }
            callback(ip)
        }
        task.resume()
    }
    
    
    
    
}
