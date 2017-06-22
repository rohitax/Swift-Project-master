//
//  SyncAPI.swift
//  Myly Swift
//
//  Created by Rohitax Rajguru on 18/05/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import Foundation

class SyncAPI {
    
    class func syncTask(_ controller: UIViewController) -> Void {
        
        let studentId = UserDefaults.standard.value(forKey: kStudentId) as! NSNumber
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        let dict_parameters: Dictionary<String, Any> = ["StudentID": "\(String(describing: formatter.string(from: studentId)))",
                               "LastSyncdate": "",
                               "AdvtXML": "",
                               "AppVersion": "100",
                               "MMI_UUID": UIDevice.current.identifierForVendor!.uuidString]
        
        WebAPI.callWebAPI(parametersToBePassed: dict_parameters,
                          functionToBeCalled: kPostSyncDataWithDate,
                          controller: controller,
                          completion: {(response: Dictionary<String, Any>) -> Void in
                            
                            if response["ResponseCode"] != nil {
                                
                                let responseCode = response["ResponseCode"] as! NSNumber
                                
//                                if responseCode == 1 {
//                                    self.saveStudentDetails(response)
//                                }
//                                else {
//                                    
//                                    let message = response["StudentDetails"] ?? kError
//                                    Alert.showAlert(message: (message as? String)!,
//                                                    actions: [.default("OK")],
//                                                    handler: nil,
//                                                    completionHandler: nil,
//                                                    onController: self)
//                                }
                            }
        })
    }
    
}
