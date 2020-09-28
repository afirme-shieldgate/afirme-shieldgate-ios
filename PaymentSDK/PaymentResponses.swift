//
//  paymentResponse.swift
//  paymentSDKSample
//
//  Created by Gustavo Sotelo on 04/05/16.
//  
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

enum PaymentSDKTypeAddError:Int
{
    
    case unauthorized = 0
    case insuficientParams = 1
    case invalidFormat = 2
    case operationNotAllowed = 3
    case invalidConfiguration = 4
}

enum PaymentSDKDebitStatus
{
    case authorized
}

class PaymentDebitResponse
{
    var transactionId = ""
    var status:PaymentSDKDebitStatus?
    var statusDetail = ""
    var paymentDate:Date?
    var amount = 0.0
    var carrierData:[String:Any]?
    var cardData:[String:Any]?
    
    
}



@objcMembers open class PaymentSDKError:NSObject
{
    open var code = 500
    open var descriptionData = "Internal Error"
    open var help:String?
    open var type:String?
    
    
    
    init(code:Int, description:String, help:String?, type:String?)
    {
        self.code = code
        self.descriptionData = description
        self.help = help
        self.type = type
        
    }
    
    fileprivate func convertStringToDictionary(_ text: String!) -> [String:Any]? {
        if let data = text.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .mutableContainers]) as? [String:Any]
                return json
            } catch let error as NSError  {
                print (error)
                print("Something went wrong with Params")
            }
        }
        return nil
    }
    
    
    static func createError(_ err:NSError) -> PaymentSDKError
    {
        return PaymentSDKError(code: 500, description: err.localizedDescription, help: err.debugDescription, type:nil)
    }
    @objc public static func createError(_ code:Int, description:String, help:String?, type:String?) -> PaymentSDKError
    {
        return PaymentSDKError(code: code, description: description, help: help, type:type)
    }
}
