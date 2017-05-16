//
//  TabBarViewController.swift
//  Myly Swift
//
//  Created by EduCommerce Technologies on 16/05/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    let tabBarImageInset: CGFloat = 6.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for tabBarItem in tabBar.items! {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsetsMake(tabBarImageInset, 0, -tabBarImageInset, 0)
        }
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
