//
//  MoreOptionViewController.swift
//  Myly Swift
//
//  Created by EduCommerce Technologies on 12/05/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class MoreOptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    var obj_studentDetail: StudentDetails?
    var obj_branchDetail: BranchDetail?
    
    let obj_syncAPI = SyncAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        obj_syncAPI.syncTask(self, completion: {(response: Dictionary<String, Any>) -> Void in
            self.fetchData()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    
    func fetchData() -> Void {
        
        let arr_studentDetails = Delegate.appDelegate.fetchDataFromCoreData(StudentDetails.description(), withPredicate: NSPredicate(format: "student_ID == %f", UserDefaults.standard.value(forKey: kStudentId) as! Double))
        
        if let arr_data = arr_studentDetails {
            if arr_data.count > 0 {
                obj_studentDetail = arr_data[0] as? StudentDetails
                
                let str_branchId = String(describing: obj_studentDetail?.student_BranchID.cleanValue)
                
                let arr_branchDetails = Delegate.appDelegate.fetchDataFromCoreData(BranchDetail.description(), withPredicate: NSPredicate(format: "branch_Id == %@", "1408"))
                if (arr_branchDetails?.count)! > 0 {
                    obj_branchDetail = arr_branchDetails?[0] as? BranchDetail
                }
            }
        }
        
        self.tableview.reloadData()
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableview.dequeueReusableCell(withIdentifier: String(describing: AboutInstitutionTableViewCell.self), for: indexPath) as! AboutInstitutionTableViewCell
        
        cell.lbl_instituteName.text = obj_studentDetail?.branch_Name
        cell.img_instituteImage.sd_setShowActivityIndicatorView(true)
        cell.img_instituteImage.sd_setIndicatorStyle(.gray)
        
        if let str_branchLogo = obj_branchDetail?.branchLogo {
            cell.img_instituteImage.sd_setImage(with: URL(string: str_branchLogo))
        }
        
        return cell
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

extension Double
{
    var cleanValue: String
    {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
