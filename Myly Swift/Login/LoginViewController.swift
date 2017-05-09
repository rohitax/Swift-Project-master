//
//  LoginViewController.swift
//  Myly Swift
//
//  Created by Rohitax Rajguru on 29/04/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import EZAlertController
import TKKeyboardControl
import Alamofire
import Alertift
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txt_username: SkyFloatingLabelTextField!
    @IBOutlet weak var txt_password: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.view.addKeyboardPanningWithFrameBasedActionHandler({ (keyboardFrameInView, opening, closing) in
            
            // Move interface objects accordingly
            // Animation block is handled for you
            
            }, constraintBasedActionHandler: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.view.removeKeyboardControl()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action Methods
    
    @IBAction func btn_login_tap(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        if (txt_username.text!.isEmpty) ||
            (txt_password.text!.isEmpty) {
            
            EZAlertController.alert(kProjectName,
                                    message: txt_username.text!.isEmpty ? "Mobile Number is empty." : "Password is empty.",
                                    acceptMessage: "OK",
                                    acceptBlock: {
                
                if (self.txt_username.text!.isEmpty) {
                    self.txt_username.becomeFirstResponder()
                }
                else {
                    self.txt_password.becomeFirstResponder()
                }
            })
        }
        else {
            
            let dict = ["UserName": self.txt_username.text!,
                        "Password": self.txt_password.text!,
                        "AppName": "myly"]
            
            WebAPI.callWebAPI(parametersToBePassed: dict, functionToBeCalled: kPostParentLogin, controller: self, completion: {(response: Dictionary<String, Any>) -> Void in
                
                if response["ResponseCode"] != nil {
                    
                    let responseCode = response["ResponseCode"] as! NSNumber
                    
                    if responseCode == 1 {
                        self.saveStudentDetails(response)
                    }
                    else {
                        
                        let message = response["StudentDetails"] ?? kError
                        Alertift.alert(title: kProjectName,
                                       message: message as? String)
                            .action(.default("OK"))
                            .show(on: self)
                    }
                }
            })
        }
    }
    
    func saveStudentDetails(_ dict_response: Dictionary<String, Any>) -> Void {
        
        let container = NSPersistentContainer(name: "Myly_Swift")
        container.performBackgroundTask() { (moc) in
            //let managedObjectContext = Delegate.appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "StudentDetails", in: moc)!
            
            let arr_studentDetails: Array = dict_response["StudentDetails"] as! [Dictionary<String, Any>]
            
            for dict_studentDetails in arr_studentDetails {
                
                let obj_studentDetails = StudentDetails(entity: entity, insertInto: moc)
                //let obj = StudentDetails(entity: entity, insertInto: moc)
                
                for (key, element) in dict_studentDetails {
                    
                    if ((element as? NSNull) == nil)  {
                        obj_studentDetails.setValue(element, forKey: key.lowerFirstCharacter())
                    }
                    else {
                        obj_studentDetails.setValue(nil, forKey: key.lowerFirstCharacter())
                    }
                }
                
                do {
                    try moc.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
        return
        let managedObjectContext = Delegate.appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "StudentDetails", in: managedObjectContext)!
        
        let arr_studentDetails: Array = dict_response["StudentDetails"] as! [Dictionary<String, Any>]
        
        for dict_studentDetails in arr_studentDetails {
            
            let obj_studentDetails = NSManagedObject(entity: entity, insertInto: managedObjectContext)
            
            for (key, element) in dict_studentDetails {
                obj_studentDetails.setValue(element, forKey: key.lowerFirstCharacter())
            }
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    @IBAction func btn_forgotPassword_tap(_ sender: AnyObject) {
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
