//
//  Alert.swift
//  Myly Swift
//
//  Created by EduCommerce Technologies on 16/05/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import UIKit
import Alertift

class Alert: NSObject {

    typealias Completion = (()->())
    
    class func showAlert(_ title: String? = kProjectName, message: String, actions: [Alertift.Action], handler: [()->()]?, completionHandler: Completion?, onController controller: UIViewController) -> Void {
        
        var alert = Alertift.alert(title: kProjectName,
                                   message: message)
        
        var count = 0
        
        if let handler = handler {
            for closure in handler {
                alert = alert.action(actions[count]) {
                    closure()
                }
                count += 1
            }
        }
        else {
            for action in actions {
                alert = alert.action(action)
            }
        }
        
        alert.show(on: controller) {
            
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }
    }
    
}
