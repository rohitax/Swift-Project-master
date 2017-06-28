//
//  SyncAPI.swift
//  Myly Swift
//
//  Created by Rohitax Rajguru on 18/05/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import Foundation
import CoreData

class SyncAPI {
    
    var dict_response: Dictionary<String, Any> = [:]
    
    func syncTask(_ controller: UIViewController, completion: @escaping (_ response: Dictionary<String, Any>) -> Void) -> Void {
        
        let dict_parameters: Dictionary<String, Any> = ["StudentID": UserDefaults.standard.value(forKey: kStudentId) ?? "",
                               "LastSyncdate": "",
                               "AdvtXML": "",
                               "MMI_UUID": UIDevice.current.identifierForVendor!.uuidString]
        
        WebAPI.callWebAPI(parametersToBePassed: dict_parameters,
                          functionToBeCalled: kPostSyncDataWithDate,
                          controller: controller,
                          completion: {(response: Dictionary<String, Any>) -> Void in
                            
                            if response["ResponseCode"] != nil {
                                
                                self.dict_response = response
                                let responseCode = self.dict_response["ResponseCode"] as! NSNumber
                                
                                if responseCode == 1 {
                                    self.insertDataInCoreData()
                                }
                                else {
                                    Alert.showAlert(message: kError,
                                                    actions: [.default("OK")],
                                                    handler: nil,
                                                    completionHandler: nil,
                                                    onController: controller)
                                }
                            }
        })
    }
    
    func insertDataInCoreData() -> Void {
        
        let dict_tableMappingToEntities = ["Table": kEvent,
                                           "Table2": kMessage,
                                           "Table3": kParentMessage,
                                           "Table7": kStudentProfile,
                                           "Table8": kContactInfo,
                                           "Table14": kSchoolAttachment,
                                           "Table18": kEmployee,
                                           "Table19": kFeeManagement,
                                           "Table20": kBranchDetail,
                                           "Table21": kStudentMigration,
                                           "Table22": kAdvertisement,
                                           "Table23": kAdverstisementAttachment,
                                           "Table24": kPaymentDetails,
                                           "Table25": kEmployeeDetails,
                                           "Table26": kFeeReconcilation,
                                           "Table27": kParentMessageEmpId,
                                           "Table28": kNewsLetter,
                                           "Table29": kNewsLetterAttachment,
                                           "Table30": kAssignment,
                                           "Table31": kAssignmentAttachment,
                                           "Table32": kHoliday,
                                           "Table33": kTeacherCalendar,
                                           "Table34": kSubject,
                                           "Table35": kPeriod,
                                           "Table36": kCalendarDayOff,
                                           "Table37": kTeacherCalendarStatus,
                                           "Table38": kExamDetail,
                                           "Table39": kExamSubjectDetail,
                                           "Table40": kExamResult,
                                           "Table41": kExamResultDetail,
                                           "Table42": kExamTerm,
                                           "Table43": kExamType,
                                           "Table44": kExamSubType,
                                           "Table45": kExamOtherSkill,
                                           "Table46": kExamOtherResultSkill,
                                           "Table47": kExamOtherResult,
                                           "Table49": kMessageQueue,
                                           "Table50": kClub,
                                           "Table51": kAction,
                                           "Table52": kGroup,
                                           "Table53": kGroupStudent,
                                           "Table54": kClubStudent,
                                           "Table57": kExamAttachment,
                                           "Table58": kParentMessageAttachment,
                                           "Table59": kMenu
                                           ]
        for (key, element) in dict_tableMappingToEntities {
            let dict_particularKeyResult: Dictionary<String, Any> = dict_response["SyncData"] as! Dictionary<String, Any>
            self.insertDataInParticularEntity(element, arr_data:dict_particularKeyResult[key] as! Array<Dictionary<String, Any>>)
        }
        
        
    }
    
    func insertDataInParticularEntity(_ str_entityName: String, arr_data: Array<Dictionary<String, Any>>) -> Void {
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = managedObjectContext.persistentStoreCoordinator
        privateContext.perform {
        
            var arr_attributesNotSaved = [String]()
            for dict in arr_data {
                
                let obj_managedObject = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: str_entityName, in: privateContext)!, insertInto: privateContext)
                
                for (key, element) in dict {
                    
                    var str_key = key
                    
                    if obj_managedObject.entity.propertiesByName.keys.contains(str_key.lowerFirstCharacter()) {
                        
                        let dict_attributes = obj_managedObject.entity.attributesByName
                        for (key, element) in dict_attributes {
                            let attributeDesc = element 
                            print("\(key) type is \(attributeDesc.attributeType.rawValue)")
                            
                        }
                        
                        if ((element as? NSNull) == nil)  {
                            
                            if let value = element as? NSNumber {
                                let str_value = "\(value)"
                                obj_managedObject.setValue(str_value, forKey: str_key.lowerFirstCharacter())
                            }
                            else {
                                obj_managedObject.setValue(element, forKey: str_key.lowerFirstCharacter())
                            }
                        }
                        else {
                            obj_managedObject.setValue(nil, forKey: str_key.lowerFirstCharacter())
                        }
                    }
                    else {
                        arr_attributesNotSaved.append(str_key)
                    }
                }
                DispatchQueue.main.async {
                    self.save()
                }
                
            }
            
            if arr_attributesNotSaved.count > 0 {
                print("The attributes that are not present in entity \(str_entityName) are:\n \(arr_attributesNotSaved)")
            }
        }
    }
    
    func save() -> Void  {
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
