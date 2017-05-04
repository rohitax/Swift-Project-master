//
//  WebAPI.swift
//  Myly Swift
//
//  Created by EduCommerce Technologies on 03/05/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import UIKit
import Alamofire
import EZAlertController
import KRProgressHUD
import Alertift
import ASToast

class WebAPI: NSObject {

    class func callWebAPI(parametersToBePassed param: Dictionary<String, Any>, functionToBeCalled function: String, controller: UIViewController, completion: @escaping (_ response: Dictionary<String, String>) -> Void) {
        
        if !Reachability.isConnectedToNetwork() {
            
            if let topController = UIApplication.topViewController() {
                topController.view.makeToast(message: kNoInternetConnectivity,
                                          backgroundColor: UIColor.black,
                                          messageColor: nil)
            }
            else {
                Alertift.alert(title: kProjectName,
                               message: kNoInternetConnectivity)
                    .action(.default("OK"))
                    .show(on: controller)
            }
            return;
        }
        
        KRProgressHUD.show()
        
        let headers: HTTPHeaders = ["Accept": "application/json", "Content-Type" :"application/json"]
        
        Alamofire.request(kServerURL + function, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            // original URL request
            //print("Request is :", response.request!)
            
            // HTTP URL response --> header and status code
            //print("Response received is :", response.response!)
            
            // server data : example 267 bytes
            //print("Response data is :", response.data!)
            
            // result of response serialization : SUCCESS / FAILURE
            //print("Response result is :", response.result)
            
            //debugPrint("Debug Print :", response)
            
            if !response.result.isSuccess {
                debugPrint("Debug Print :", response)
                Alertift.alert(title: kProjectName,
                               message: kError)
                    .action(.default("OK"))
                    .show(on: controller)
            }
            else {
                
                do {
                    
                    let myJson = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as Any
                    
                    let dict_response = Delegate.appDelegate.convertToDictionary(text: myJson as! String)
                    print(dict_response ?? kError)
                    
                    if dict_response != nil {
                        
                        let convertedDict: [String: String] = dict_response!.mapPairs { (key, value) in
                            (key, String(describing: value))
                        }
                        completion(convertedDict)
                    }
                    
                }
                catch let error as NSError {
                    print(error.description)
                }
            }
            
            KRProgressHUD.dismiss()
        }
    }
    
}

extension Dictionary {
    //    Since Dictionary conforms to CollectionType, and its Element typealias is a (key, value) tuple, that means you ought to be able to do something like this:
    //
    //    result = dict.map { (key, value) in (key, value.uppercaseString) }
    //
    //    However, that won't actually assign to a Dictionary-typed variable. THE MAP METHOD IS DEFINED TO ALWAYS RETURN AN ARRAY (THE [T]), even for other types like dictionaries. If you write a constructor that'll turn an array of two-tuples into a Dictionary and all will be right with the world:
    //  Now you can do this:
    //    result = Dictionary(dict.map { (key, value) in (key, value.uppercaseString) })
    //
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
    //    You may even want to write a Dictionary-specific version of map just to avoid explicitly calling the constructor. Here I've also included an implementation of filter:
    //    let testarr = ["foo" : 1, "bar" : 2]
    //    let result = testarr.mapPairs { (key, value) in (key, value * 2) }
    //    result["bar"]
    func mapPairs<OutKey: Hashable, OutValue>( transform: (Element) throws -> (OutKey, OutValue)) rethrows -> [OutKey: OutValue] {
        return Dictionary<OutKey, OutValue>(try map(transform))
    }
    
}
