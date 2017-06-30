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
                    
                    if obj_managedObject.entity.propertiesByName.keys.contains(str_key.lowerFirstCharacter()) || obj_managedObject.entity.propertiesByName.keys.contains(str_key.lowerFirstCharacter() + "_") {
                        
                        if ((element as? NSNull) == nil)  {
                            
                            if let value = element as? NSNumber {
                                
                                if let attribute = obj_managedObject.entity.attributesByName[str_key.lowerFirstCharacter()],
                                    attribute.attributeType == .floatAttributeType {
                                    
                                    guard str_entityName == kEvent && str_key == "IsDeleted" else {
                                        obj_managedObject.setValue(value, forKey: str_key.lowerFirstCharacter())
                                        continue
                                    }
                                    obj_managedObject.setValue(value, forKey: str_key.lowerFirstCharacter())
                                                                    }
                                else {
                                    let str_value = "\(value)"
                                    guard str_entityName == kEvent && str_key == "isDeleted" else {
                                        obj_managedObject.setValue(str_value, forKey: str_key.lowerFirstCharacter())
                                        continue
                                    }
                                    obj_managedObject.setValue(str_value, forKey: "isDeleted_")
                                }
                            }
                            else {
                                if let attribute = obj_managedObject.entity.attributesByName[str_key.lowerFirstCharacter()],
                                    attribute.attributeType != .dateAttributeType {
            
                                    obj_managedObject.setValue(element, forKey: str_key.lowerFirstCharacter())
                                }
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
                self.addDateToEntities(str_entityName, fromData: dict, inObject: obj_managedObject)
                
                DispatchQueue.main.async {
                    self.save()
                }
            }
            
            if arr_attributesNotSaved.count > 0 {
                print("The attributes that are not present in entity \(str_entityName) are:\n \(arr_attributesNotSaved)")
            }
        }
    }
    
    func addDateToEntities(_ str_entityName: String, fromData dict_data: Dictionary<String, Any>, inObject obj: NSManagedObject) -> Void {
        
        switch str_entityName {
        case kAssignment:
            obj.setValue(self.fetchDataInDateType(dict_data["Assignement_CreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "assignement_CreatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["Assignement_CreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kEvent:
            obj.setValue(self.fetchDataInDateType(dict_data["Event_CreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "event_CreatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["Event_UpdatededOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "event_UpdatededOn")
            obj.setValue(self.fetchDataInDateType(dict_data["LeafUpdatedDate"] as? String, havingFormat: kDateTimeFormatLeafUpdateDate, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kMessage:
            obj.setValue(self.fetchDataInDateType(dict_data["Message_CreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "message_CreatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["LeafUpdatedDate"] as? String, havingFormat: kDateTimeFormatLeafUpdateDate, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kParentMessage:
            obj.setValue(self.fetchDataInDateType(dict_data["ParentMessageCreateOn"] as? String, havingFormat: "yyyy-MM-dd HH:mm:ss", inFormat: kDateTimeFormatServer), forKey: "parentMessageCreateOn")
            obj.setValue(self.fetchDataInDateType(dict_data["LeafUpdatedDate"] as? String, havingFormat: kDateTimeFormatLeafUpdateDate, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kFeeManagement:
            obj.setValue(self.fetchDataInDateType(dict_data["Activity_CreatedOn"] as? String, havingFormat: "EEE dd MMMM yyyy hh:mm a", inFormat: kDateTimeFormatServer), forKey: "activity_CreatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["LeafUpdatedDate"] as? String, havingFormat: kDateTimeFormatLeafUpdateDate, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kStudentMigration:
            obj.setValue(self.fetchDataInDateType(dict_data["Message_CreatedOn"] as? String, havingFormat: "yyyy-MM-dd HH:mm:ss", inFormat: kDateTimeFormatServer), forKey: "message_CreatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["LeafUpdatedDate"] as? String, havingFormat: kDateTimeFormatLeafUpdateDate, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kAdvertisement:
            obj.setValue(self.fetchDataInDateType(dict_data["Advt_CreatedDate"] as? String, havingFormat: "yyyy-MM-dd HH:mm:ss", inFormat: kDateTimeFormatServer), forKey: "advt_CreatedDate")
            obj.setValue(self.fetchDataInDateType(dict_data["Advt_UpdatedDate"] as? String, havingFormat: "yyyy-MM-dd HH:mm:ss", inFormat: kDateTimeFormatServer), forKey: "advt_UpdatedDate")
            obj.setValue(self.fetchDataInDateType(dict_data["LeafUpdatedDate"] as? String, havingFormat: kDateTimeFormatLeafUpdateDate, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kNewsLetter:
            obj.setValue(self.fetchDataInDateType(dict_data["NewsLetter_CreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "newsLetter_CreatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["NewsLetter_CreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kHoliday:
            obj.setValue(self.fetchDataInDateType(dict_data["Holliday_CreateDate"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "holliday_CreateDate")
            obj.setValue(self.fetchDataInDateType(dict_data["Holliday_UpdateDate"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "holliday_UpdateDate")
            obj.setValue(self.fetchDataInDateType(dict_data["Holliday_UpdateDate"] as? String ?? dict_data["Holliday_CreateDate"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kExamDetail:
            obj.setValue(self.fetchDataInDateType(dict_data["CancelDate"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "cancelDate")
            obj.setValue(self.fetchDataInDateType(dict_data["ExamCreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "examCreatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["ExamUpdatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "examUpdatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["ExamUpdatedOn"] as? String ?? dict_data["ExamCreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kExamResult:
            obj.setValue(self.fetchDataInDateType(dict_data["ExamResult_CreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "examResult_CreatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["ExamResult_UpdatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "examResult_UpdatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["ExamResult_UpdatedOn"] as? String ?? dict_data["ExamResult_CreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kExamOtherResult:
            obj.setValue(self.fetchDataInDateType(dict_data["ExamOtherResultCreatedON"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "examOtherResultCreatedON")
            obj.setValue(self.fetchDataInDateType(dict_data["examOtherResultUpdatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "examOtherResultUpdatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["ExamOtherResultUpdatedOn"] as? String ?? dict_data["ExamOtherResultCreatedON"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kStudentMigration:
            obj.setValue(self.fetchDataInDateType(dict_data["Message_CreatedOn"] as? String, havingFormat: "yyyy-MM-dd HH:mm:ss", inFormat: kDateTimeFormatServer), forKey: "message_CreatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["LeafUpdatedDate"] as? String, havingFormat: kDateTimeFormatLeafUpdateDate, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
        
        case kClub:
            obj.setValue(self.fetchDataInDateType(dict_data["ClubCreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "clubCreatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["ClubUpdatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "clubUpdatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["ClubUpdatedOn"] as? String ?? dict_data["ClubCreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
            
        case kGroup:
            obj.setValue(self.fetchDataInDateType(dict_data["GroupCreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "groupCreatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["GroupUpdatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "groupUpdatedOn")
            obj.setValue(self.fetchDataInDateType(dict_data["GroupUpdatedOn"] as? String ?? dict_data["GroupCreatedOn"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatLeafUpdateDate), forKey: "leafUpdatedDate")
        
        case kAction:
            obj.setValue(self.fetchDataInDateType(dict_data["AssociationDate"] as? String, havingFormat: kDateTimeFormatServer, inFormat: kDateTimeFormatServer), forKey: "associationDate")
            
        default:
            break
        }
    }
    
    func fetchDataInDateType(_ str_date: String?,
                             havingFormat str_currentDateFormat: String,
                             inFormat str_expectedDateFormat: String) -> Date? {
        
        if let str = str_date {
            guard let date = str.getDateFromString(str_currentDateFormat, inFormat: str_expectedDateFormat) else {
                return nil;
            }
            return date
        }
        return nil
    }
    
    func save() -> Void  {
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
