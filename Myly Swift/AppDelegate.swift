//
//  AppDelegate.swift
//  Myly Swift
//
//  Created by Rohitax Rajguru on 29/04/17.
//  Copyright © 2017 EduCommerce Technologies. All rights reserved.
//

import UIKit
import CoreData
import INSPersistentContainer
import November

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    typealias NSPersistentContainer         = INSPersistentContainer
    typealias NSPersistentStoreDescription  = INSPersistentStoreDescription
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        
        if let isUserLoggedIn = UserDefaults.standard.object(forKey: kUserLoggedIn) {
            if isUserLoggedIn as! Bool {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: String(describing: TabBarViewController.self))
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Myly_Swift")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Custom Methods
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func fetchDataFromCoreData(_ str_entityName: String, withPredicate predicate: NSPredicate) -> Array<Any>? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: str_entityName)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let arr_studentDetails = try managedObjectContext.fetch(fetchRequest)
            return arr_studentDetails
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension String {
    
    func capitalizedFirst() -> String {
        let first = self[self.startIndex ..< self.index(startIndex, offsetBy: 1)]
        let rest = self[self.index(startIndex, offsetBy: 1) ..< self.endIndex]
        return first.uppercased() + rest.lowercased()
    }
    
    func capitalizedFirst(with: Locale?) -> String {
        let first = self[self.startIndex ..< self.index(startIndex, offsetBy: 1)]
        let rest = self[self.index(startIndex, offsetBy: 1) ..< self.endIndex]
        return first.uppercased(with: with) + rest.lowercased(with: with)
    }
    
    func lowerizedFirst() -> String {
        let first = self[self.startIndex ..< self.index(startIndex, offsetBy: 1)]
        let rest = self[self.index(startIndex, offsetBy: 1) ..< self.endIndex]
        return first.lowercased() + rest.uppercased()
    }
    
    func lowerizedFirst(with: Locale?) -> String {
        let first = self[self.startIndex ..< self.index(startIndex, offsetBy: 1)]
        let rest = self[self.index(startIndex, offsetBy: 1) ..< self.endIndex]
        return first.lowercased(with: with) + rest.uppercased(with: with)
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }
}

extension String {
    
    mutating func lowerFirstCharacter() -> String {
        var str_firstCharacter = self[0] as String
        str_firstCharacter = str_firstCharacter.lowerizedFirst()
        
        let index = self.index(self.startIndex, offsetBy: 0)
        self.replaceSubrange(index...index, with: str_firstCharacter)
        return self
    }
}

extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
    func nsRange(from range: Range<Index>) -> NSRange {
        let lower = UTF16View.Index(range.lowerBound, within: utf16)
        let upper = UTF16View.Index(range.upperBound, within: utf16)
        return NSRange(location: utf16.startIndex.distance(to: lower), length: lower.distance(to: upper))
    }
}

extension String {
    
    func getDateFromString(_ str_currentDateFormat: String,
                           inFormat str_expectedDateFormat: String) -> Date? {
        
        let str_dateTime = self.truncateMilliSecondsInString(self)
        let date = Date(string: str_dateTime, format: str_currentDateFormat)
        
        guard str_currentDateFormat != str_expectedDateFormat else {
            return date
        }
        
        let str_date = date?.string(withFormat: str_expectedDateFormat)
        
        if let date = Date(string: str_date!, format: str_expectedDateFormat) {
            return date
        }
        return nil
    }
    
    func getLeafUpdateDate() -> Date? {
        
        let arr_parts = self.components(separatedBy: ".")
        return Date(string: arr_parts[0], format: "yyyyMMddHHmmss")
    }
    
    func truncateMilliSecondsInString(_ str_time: String) -> String {
        
        guard str_time.contains(".") else {
            return str_time
        }
        
        if str_time.uppercased().contains("T") {
            return str_time.components(separatedBy: ".")[0]
        }
        return str_time
    }
}

extension String {
    
    var isNumeric: Bool {
        guard self.characters.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self.characters).isSubset(of: nums)
    }
}
