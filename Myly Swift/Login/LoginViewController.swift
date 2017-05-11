//
//  LoginViewController.swift
//  Myly Swift
//
//  Created by Rohitax Rajguru on 29/04/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import TKKeyboardControl
import Alertift
import CoreData

let managedObjectContext = Delegate.appDelegate.persistentContainer.viewContext

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txt_username: SkyFloatingLabelTextField!
    @IBOutlet weak var txt_password: SkyFloatingLabelTextField!
    @IBOutlet weak var txt_note: UITextView!
    
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
            
            Alertift.alert(title: kProjectName,
                           message: txt_username.text!.isEmpty ? "Mobile Number is empty." : "Password is empty.")
                .action(.default("OK")) {
                    
                    if (self.txt_username.text!.isEmpty) {
                        self.txt_username.becomeFirstResponder()
                    }
                    else {
                        self.txt_password.becomeFirstResponder()
                    }
                }
                .show(on: self)
        }
        else {
            self.loginTask()
        }
    }
    
    @IBAction func btn_forgotPassword_tap(_ sender: AnyObject) {
        
        
    }
    
    // MARK: - WS Methods
    
    func loginTask() -> Void {
        
        let dict_parameters = ["UserName": self.txt_username.text!,
                               "Password": self.txt_password.text!]
        
        WebAPI.callWebAPI(parametersToBePassed: dict_parameters,
                          functionToBeCalled: kPostParentLogin,
                          controller: self,
                          completion: {(response: Dictionary<String, Any>) -> Void in
                            
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
    
    // MARK: - Custom Methods
    
    func saveStudentDetails(_ dict_response: Dictionary<String, Any>) -> Void {
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = managedObjectContext.persistentStoreCoordinator
        privateContext.perform {
            
            let entity = NSEntityDescription.entity(forEntityName: StudentDetails.description(), in: managedObjectContext)!
            
            let arr_studentDetails: Array = dict_response["StudentDetails"] as! [Dictionary<String, Any>]
            
            for dict_studentDetails in arr_studentDetails {
                
                if !self.checkIfStudentDetailsExist(dict_studentDetails) {
                    let obj_studentDetails = StudentDetails(entity: entity, insertInto: managedObjectContext)
                    self.saveDataInAttributes(dict_studentDetails, studentDetailObject: obj_studentDetails)
                }
            }
        }
    }
    
    func checkIfStudentDetailsExist(_ dict_studentDetails: Dictionary<String, Any>) -> Bool {
        
        let fetchRequest = NSFetchRequest<StudentDetails>(entityName: StudentDetails.description())
        fetchRequest.predicate = NSPredicate(format: "student_ID == %f", dict_studentDetails["Student_ID"] as! Double);
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let arr_record = try managedObjectContext.fetch(fetchRequest)
            
            if arr_record.count > 0 {
                let obj_studentDetails = arr_record[0]
                self.saveDataInAttributes(dict_studentDetails, studentDetailObject: obj_studentDetails)
                return true
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return false
    }
    
    func saveDataInAttributes(_ dict_studentDetails: Dictionary<String, Any>,
                              studentDetailObject obj_studentDetails: StudentDetails) -> Void {
        
        for (key, element) in dict_studentDetails {
            
            var str_key = key
            if ((element as? NSNull) == nil)  {
                obj_studentDetails.setValue(element, forKey: str_key.lowerFirstCharacter())
            }
            else {
                obj_studentDetails.setValue(nil, forKey: str_key.lowerFirstCharacter())
            }
        }
        self.save()
    }
    
    func save() -> Void  {
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
