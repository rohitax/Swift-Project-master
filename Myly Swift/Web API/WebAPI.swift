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

class WebAPI: NSObject {

    class func callWebAPI(parametersToBePassed param: Dictionary<String, Any>, functionToBeCalled function: String, completion: @escaping (_ response: Dictionary<String, Any>) -> Void) {
        
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
                EZAlertController.alert(kProjectName,
                                        message: "Some error occured.",
                                        acceptMessage: "OK",
                                        acceptBlock: {}
                )
                debugPrint("Debug Print :", response)
            }
            else {
                
                do {
                    
                    let myJson = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as Any
                    
                    let dict_response = Delegate.appDelegate.convertToDictionary(text: myJson as! String)
                    print(dict_response ?? "Some error occured")
                    completion(dict_response ?? ["": ""])
                    
                }
                catch let error as NSError {
                    print(error.description)
                }
            }
            
            KRProgressHUD.dismiss()
        }
    }
    
}
