    //
    //  MyBackendLib.swift
    //  PaymentSDKSwift
    //
    //  Created by Gustavo Sotelo on 19/09/17.
    //  Copyright © 2017 Payment. All rights reserved.
    //
    
    import Foundation
    import PaymentSDK
    
    class MyBackendLib
    {
        static let myBackendUrl = "https://example-Payment-backend.herokuapp.com/"
        
        static func verifyTrx(uid:String, transactionId:String, type:Int, value:String, callback:@escaping (_ error:PaymentSDKError?, _ verified:Bool) ->Void)
        {
            var verifyType = "BY_AMOUNT"
            if type == 1
            {
                verifyType = "BY_AUTH_CODE"
            }
            
            let params = ["uid": uid, "transaction_id": transactionId, "type": verifyType, "value":value]
            makeRequestPOST("verify-transaction", parameters: params as NSDictionary) { (error, statusCode, responseData) in
                
                if statusCode == 200
                {
                    callback(nil,true)
                }
                else
                {
                    do {
                        var dataR = (responseData as! [String:Any])
                        if dataR["error"] != nil
                        {
                            dataR = dataR["error"] as! [String:Any]
                        }
                        let errorPa =  PaymentSDKError.createError(statusCode!, description: dataR["description"] as! String, help: dataR["help"] as? String, type: dataR["type"] as? String) //parse error in strutcture
                        
                        callback(errorPa,false)
                    }
                }
            }
        }
        
        
        static func deleteCard(uid:String, cardToken:String, callback:@escaping (_ deleted:Bool) ->Void)
        {
            let params = ["token": cardToken, "uid": uid]
            makeRequestPOST("delete-card", parameters: params as NSDictionary) { (error, statusCode, responseData) in
                
                if statusCode == 200
                {
                    callback(true)
                }
                else
                {
                    callback(false)
                }
            }
        }
        
        
        static func debitCard(uid:String, cardToken:String, sessionId:String, devReference:String, amount:Double, description:String, callback:@escaping (_ error:NSError?, _ transaction:PaymentTransaction?) ->Void)
        {
            let params = ["uid": uid, "token": cardToken, "session_id": sessionId, "amount": String(format: "%.2f", amount), "dev_reference":devReference, "description":description] as NSDictionary
            makeRequestPOST("create-charge", parameters: params) { (error, statusCode, responseData) in
                if error == nil
                {
                    if statusCode == 200
                    {
                        let responseD = responseData as! [String:Any]
                        let transaction = responseD["transaction"] as! [String:Any]
                        let trx = PaymentTransaction()
                        trx.amount = transaction["amount"] as? NSNumber
                        trx.status = transaction["status"] as? String
                        trx.statusDetail = transaction["status_detail"] as? Int as NSNumber?
                        trx.transactionId = transaction["id"] as? String
                        if let authCode = Int(transaction["authorization_code"] as! String) {
                            trx.authorizationCode = NSNumber(value:authCode)
                        }
                            
                        trx.carrierCode = transaction["carrier_code"] as? String
                        trx.message = transaction["message"] as? String
                        
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                        
                        if let paymentdate = (responseD["payment_date"] as? String)
                        {
                            trx.paymentDate = dateFormatter.date(from: paymentdate)
                        }
                        if trx.statusDetail == 11
                        {
                            callback(nil, trx)
                        }
                        else if trx.statusDetail != 3
                        {
                            
                            callback(error, trx)
                        }
                        else
                        {
                            callback(nil, trx)
                        }
                        
                        
                    }
                    else
                    {
                        do {
                       
                            
                            callback(error, nil)
                        }
                        
                    }
                }
                else
                {
                    callback(error, nil)
                }
            }
        }
        static func listCard(uid:String, callback:@escaping (_ cardList:[PaymentCard]?) ->Void)
        {
            let parameters = ["uid": uid] as [String:Any]
            makeRequestGet("get-cards", parameters: parameters as NSDictionary) { (error, statusCode, responseData) in
                
                
                var responseCards = [PaymentCard]()
                if error == nil
                {
                    if statusCode == 200
                    {
                        let responseObj = responseData as! NSDictionary
                        let cardsArray = responseObj["cards"] as! [[String:Any]]
                        
                        
                        for card in cardsArray
                        {
                            let pCard = PaymentCard()
                            pCard.bin = "\(card["bin"]!)"
                            pCard.token = "\(card["token"]!)"
                            pCard.cardHolder = "\(card["holder_name"]!)"
                            pCard.expiryMonth = card["expiry_month"] as! String
                            pCard.expiryYear = card["expiry_year"] as! String
                            pCard.termination = "\(card["number"]!)"
                            pCard.status = "\(card["status"]!)"
                            pCard.type = "\(card["type"]!)"
                            responseCards.append(pCard)
                        }
                    }
                    
                    callback(responseCards)
                        
                    
                }
                else
                {
                    callback(responseCards)
                }
                
            }
        }
        static func makeRequestGet(_ urlToRequest:String, parameters:NSDictionary, responseCallback:@escaping (_ error:NSError?, _ statusCode:Int?,_ responseData:Any?) ->Void)
        {
            var completeUrl = self.myBackendUrl + urlToRequest
            var bodyData = ""
            for (key,value) in parameters{
                let scapedKey = (key as! String).addingPercentEncoding(
                    withAllowedCharacters: .urlHostAllowed)!
                let scapedValue = (value as! String).addingPercentEncoding(
                    withAllowedCharacters: .urlHostAllowed)!
                bodyData += "\(scapedKey)=\(scapedValue)&"
            }
            completeUrl += "?" + bodyData
            let url:URL? = URL(string: completeUrl)
            let session = URLSession.shared
            
            var request = URLRequest(url:url!)
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request){ data, resp, err in
                
                if err == nil
                {
                    var json:Any? = nil
                    
                    do{
                        json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                    }
                    catch {
                        
                    }
                    
                    if json == nil{
                        let error = NSError(domain: "JSON", code: 400, userInfo: ["parsing" : false])
                        print ("parsing json error")
                        responseCallback(error, 400,nil)
                    }
                    else
                    {
                        
                        
                        responseCallback(err as NSError?, (resp as! HTTPURLResponse).statusCode, json)
                    }
                }
                else
                {
                    responseCallback(err as NSError?, 400, nil)
                }
            }
            task.resume()
        }
        static func makeRequestPOST(_ urlToRequest:String, parameters:NSDictionary, responseCallback:@escaping (_ error:NSError?, _ statusCode:Int?,_ responseData:Any?) ->Void)
        {
            let completeUrl = self.myBackendUrl + urlToRequest
            let url:URL? = URL(string: completeUrl)
            let session = URLSession.shared
            
            var request = URLRequest(url:url!)
            request.httpMethod = "POST"
            request.httpBody = encodeParams(parameters)
            
            let task = session.dataTask(with: request){
                data, resp, err in
                print(data as Any)
                if err == nil
                {
                    var json:Any? = nil
                    
                    do{
                        json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                        print(json as Any)
                    }
                    catch {
                        
                    }
                    
                    if json == nil{
                        let error = NSError(domain: "JSON", code: 400, userInfo: ["parsing" : false])
                        print ("parsing json error")
                        if resp != nil
                        {
                            
                            responseCallback(error, (resp as! HTTPURLResponse).statusCode,nil)
                        }
                        else
                        {
                            responseCallback(error, 400,nil)
                        }
                    }
                    else
                    {
                        
                        print(json as Any)
                        responseCallback(err as NSError?, (resp as! HTTPURLResponse).statusCode, json)
                    }
                }
                else
                {
                    responseCallback(err as NSError?, 400, nil)
                }
            }
            task.resume()
        }
        static func encodeParams(_ parameters:NSDictionary) ->Data?
        {
            var bodyData = ""
            for (key,value) in parameters{
                let scapedKey = (key as! String).addingPercentEncoding(
                    withAllowedCharacters: .urlHostAllowed)!
                let scapedValue = (value as! String).addingPercentEncoding(
                    withAllowedCharacters: .urlHostAllowed)!
                bodyData += "\(scapedKey)=\(scapedValue)&"
            }
            print(bodyData)
            return bodyData.data(using: String.Encoding.utf8, allowLossyConversion: true)
        }
    }
    
