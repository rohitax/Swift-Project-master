//
//  WelcomeScreenViewController.swift
//  Myly Swift
//
//  Created by EduCommerce Technologies on 11/05/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import UIKit

class WelcomeScreenViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let arr_images = ["img_welcome1", "img_welcome2", "img_welcome3", "img_welcome4", "img_welcome5"]
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    let screenSize: CGRect = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addImagesInScrollView()
    }

    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    
    func addImagesInScrollView() -> Void {
        
        for index in 0 ..< arr_images.count {
            
            frame.origin.x = screenSize.size.width * CGFloat(index)
            frame.size = screenSize.size
            let subView = UIView(frame: frame)
            
            let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: screenSize.size.width, height: screenSize.size.height))
            imageview.image = UIImage.init(named: arr_images[index])
            subView.addSubview(imageview)
            self.scrollview .addSubview(subView)
        }
        
        self.scrollview.contentSize = CGSize(width: screenSize.size.width * CGFloat(arr_images.count), height: screenSize.size.height)
    }
    
    // MARK: - Action Methods
    
    @IBAction func btn_skip_tap(_ sender: Any?) {
        
        let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavigation")
        self.present(navigationController!, animated: true)
    }

    @IBAction func btn_next_tap(_ sender: Any) {
        
        let count = CGFloat(self.arr_images.count - 1)
        if self.scrollview.contentOffset.x >= (count * screenSize.size.width) {
            self.btn_skip_tap(nil)
            return
        }
        
        self.scrollview.setContentOffset(CGPoint(x: self.scrollview.contentOffset.x + screenSize.size.width, y: self.scrollview.contentOffset.y), animated: true)
    }
    
    @IBAction func pageControl_tap(_ sender: UIPageControl) {
        
        let page = CGFloat(sender.currentPage)
        self.scrollview.setContentOffset(CGPoint(x: (page * screenSize.size.width), y: self.scrollview.contentOffset.y), animated: true)
    }
    
    // MARK: - UIScrollView Delegate Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageWidth = scrollView.frame.size.width
        let page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        pageControl.currentPage = Int(page)
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
