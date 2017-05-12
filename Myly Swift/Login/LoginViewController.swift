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
import FormToolbar

let managedObjectContext = Delegate.appDelegate.persistentContainer.viewContext

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txt_username: SkyFloatingLabelTextField!
    @IBOutlet weak var txt_password: SkyFloatingLabelTextField!
    @IBOutlet weak var txt_note: UITextView!
    
    private lazy var toolbar: FormToolbar = {
        return FormToolbar(inputs: self.inputs)
    }()
    
    private var inputs: [FormInput] {
        return [txt_username, txt_password]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setNoteTextInTextView()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.view.addKeyboardPanningWithFrameBasedActionHandler({ (keyboardFrameInView, opening, closing) in
            
            // Move interface objects accordingly
            // Animation block is handled for you
            
            }, constraintBasedActionHandler: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.view.endEditing(true)
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
    
    func showAlert(_ title: String, message: String, actions: [Alertift.Action], handler: [()->()]) -> Void {
        
        let alert = Alertift.alert(title: kProjectName,
                                   message: message)
        
        for action in actions {
            alert.action(actions[0])
        }
        
        Alertift.alert(title: title,
                       message: message)
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
    
    func setNoteTextInTextView() {
        
        let str_mutableAttributedString = NSMutableAttributedString(string: kLoginNoteForMyly, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: kFontSizeForNoteTextView)])
        
        let rangeOfString = str_mutableAttributedString.string.range(of: "hello@mylyapp.com")
        
        let nsRange = str_mutableAttributedString.string.nsRange(from: rangeOfString!)
        
        str_mutableAttributedString.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: nsRange)
        
        self.txt_note.attributedText = str_mutableAttributedString
        self.txt_note.textAlignment = NSTextAlignment.center
    }
    
    func saveStudentDetails(_ dict_response: Dictionary<String, Any>) -> Void {
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = managedObjectContext.persistentStoreCoordinator
        privateContext.perform {
            
            let entity = NSEntityDescription.entity(forEntityName: StudentDetails.description(), in: managedObjectContext)!
            
            let arr_studentDetails: Array = dict_response["StudentDetails"] as! [Dictionary<String, Any>]
            
            if arr_studentDetails.count > 0 {
                
                for dict_studentDetails in arr_studentDetails {
                    
                    if !self.checkIfStudentDetailsExist(dict_studentDetails) {
                        let obj_studentDetails = StudentDetails(entity: entity, insertInto: managedObjectContext)
                        self.saveDataInAttributes(dict_studentDetails, studentDetailObject: obj_studentDetails)
                    }
                }
                self.saveDetailsInUserDefaults(arr_studentDetails)
                self.navigateToWall()
            }
            else {
                Alertift.alert(title: kProjectName,
                               message: kNoStudentsExist)
                    .action(.default("OK"))
                    .show(on: self)
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
    
    func saveDetailsInUserDefaults(_ arr_studentDetails: [Dictionary<String, Any>]) -> Void {
        
        let dict_firstStudent = arr_studentDetails[0]
        let studentId = dict_firstStudent["student_ID"] as! Double
        let databaseId = dict_firstStudent["DatabaseID"] as! Int16
        
        UserDefaults.standard.set(studentId, forKey: "studentId")
        UserDefaults.standard.set(databaseId, forKey: "databaseId")
        UserDefaults.standard.set("1", forKey: "userLoggedIn")
    }
    
    func navigateToWall() -> Void {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: MoreOptionViewController.description())
        self.navigationController?.show(controller!, sender: self)
    }
    
    // MARK: - UITextField Delegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.txt_username {
            let compSepByCharInSet = string.components(separatedBy: numberSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        toolbar.update()
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
