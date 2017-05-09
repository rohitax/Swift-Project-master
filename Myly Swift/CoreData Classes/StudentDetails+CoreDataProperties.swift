//
//  StudentDetails+CoreDataProperties.swift
//  
//
//  Created by EduCommerce Technologies on 09/05/17.
//
//

import Foundation
import CoreData


extension StudentDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StudentDetails> {
        return NSFetchRequest<StudentDetails>(entityName: "StudentDetails")
    }

    @NSManaged public var student_IsSoftDelete: Int16
    @NSManaged public var student_MiddleName: String?
    @NSManaged public var student_Gender: String?
    @NSManaged public var student_LastName: String?
    @NSManaged public var student_EnrollmentNo: String?
    @NSManaged public var isSMSDisabled: Int16
    @NSManaged public var profilePicture: String?
    @NSManaged public var databaseID: Int16
    @NSManaged public var student_ClassID: Double
    @NSManaged public var student_FirstName: String?
    @NSManaged public var notificationSettingID: Int16
    @NSManaged public var student_SchoolID: Double
    @NSManaged public var schoolLogo: String?
    @NSManaged public var student_Password: String?
    @NSManaged public var student_BranchID: Double
    @NSManaged public var student_IsActive: Int16
    @NSManaged public var sMSSettingID: Int16
    @NSManaged public var student_ID: Double
    @NSManaged public var student_PrimaryEmailID: String?
    @NSManaged public var class_Name: String?
    @NSManaged public var branch_Name: String?
    @NSManaged public var sMSBalance: Double
    @NSManaged public var student_IsProfileImageUpload: Int16
    @NSManaged public var student_DOB: String?

}
