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
import Networking
//import Networking+HTTPRequests

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
        
        if (txt_username.text!.isEmpty) || (txt_password.text!.isEmpty) {
            
            EZAlertController.alert(kProjectName, message: txt_password.text!.isEmpty ? "Password is empty." : "Username is empty.", acceptMessage: "OK", acceptBlock: {
                
                if (self.txt_username.text!.isEmpty) {
                    self.txt_username.becomeFirstResponder()
                }
                else {
                    self.txt_password.becomeFirstResponder()
                }
                
            })
            
        }
        else {
            let networking = Networking(baseURL: kServerURL)
            
            networking.post("PostUnRegisterMemberMobileInformation", parameters: ["UserName" : self.txt_username.text!, "Password" : self.txt_password.text!, "AppName" : "myly"]) { result in
                
                //print(result.error?.description ?? "test")
            }
                /*
                 {
                 "json" : {
                 "username" : "jameson",
                 "password" : "secret"
                 },
                 "url" : "http://httpbin.org/post",
                 "data" : "{"password" : "secret","username" : "jameson"}",
                 "headers" : {
                 "Accept" : "application/json",
                 "Content-Type" : "application/json",
                 "Host" : "httpbin.org",
                 "Content-Length" : "44",
                 "Accept-Language" : "en-us"
                 }
                 }
                 */
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
