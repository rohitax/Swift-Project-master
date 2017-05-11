//
//  ForgotPasswordViewController.swift
//  Myly Swift
//
//  Created by EduCommerce Technologies on 11/05/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Alertift
import TKKeyboardControl

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txt_mobileNumber: SkyFloatingLabelTextField!
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
        
        self.setNoteTextInTextView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.view.endEditing(true)
        self.view.removeKeyboardControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK : - Action Methods
    
    @IBAction func btn_submit_tap(_ sender: AnyObject) {
        
        if (txt_mobileNumber.text!.isEmpty) {
            
            Alertift.alert(title: kProjectName,
                           message: "Mobile Number is empty.")
                .action(.default("OK")) {
                    
                    self.txt_mobileNumber.becomeFirstResponder()
                }
                .show(on: self)
        }
        else {
            self.forgotPasswordTask()
        }
    }
    
    @IBAction func btn_back_tap(_ sender: AnyObject?) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - WS Methods
    
    func forgotPasswordTask() -> Void {
        
        WebAPI.callWebAPI(parametersToBePassed: ["Mobile": self.txt_mobileNumber.text!],
                          functionToBeCalled: kPostForgotPassword,
                          controller: self) { (response: Dictionary<String, Any>) in
                            
                            if response["ResponseCode"] != nil {
                                
                                let responseCode = response["ResponseCode"] as? Int8
                                let message = response["StudentDetails"] ?? kError
                                
                                let alert = Alertift.alert(title: kProjectName,
                                                           message: message as? String)
                                if responseCode == 1 {
                                    alert.action(.default("OK")) {
                                            self.btn_back_tap(nil)
                                        }
                                        .show(on: self)
                                }
                                else {
                                    alert.action(.default("OK"))
                                        .show(on: self)
                                }
                            }
        }
    }

    // MARK: - Custom Methods
    
    func setNoteTextInTextView() {
        
        let str_mutableAttributedString = NSMutableAttributedString(string: kForgotPasswordNoteForMyly, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
        
        let rangeOfString = str_mutableAttributedString.string.range(of: "support@mylyapp.com")
        
        let nsRange = str_mutableAttributedString.string.nsRange(from: rangeOfString!)
        
        str_mutableAttributedString.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: nsRange)
        
        self.txt_note.attributedText = str_mutableAttributedString
        self.txt_note.textAlignment = NSTextAlignment.center
    }
    
    // MARK: - UITextField Delegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let compSepByCharInSet = string.components(separatedBy: numberSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
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
