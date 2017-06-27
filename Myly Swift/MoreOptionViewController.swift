//
//  MoreOptionViewController.swift
//  Myly Swift
//
//  Created by EduCommerce Technologies on 12/05/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import UIKit

class MoreOptionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        SyncAPI.syncTask(self, completion: {(response: Dictionary<String, Any>) -> Void in
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
