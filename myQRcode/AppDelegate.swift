//
//  AppDelegate.swift
//  myQRcode
//
//  Created by Marc Hein on 24.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import CoreData
import UIKit
import HeinHelpers
import MatomoTracker


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let tabBarController = self.window?.rootViewController as? UITabBarController, let items = tabBarController.tabBar.items {
            if #available(iOS 13.0, *) {
                items[0].image = UIImage(systemName: "qrcode")
                items[1].image = UIImage(systemName: "qrcode.viewfinder")
            }
            
            setDefaultTab(tabVC: tabBarController)
            
            let deviceId = UIDevice.current.identifierForVendor?.uuidString
            MatomoTracker.shared.userId = deviceId
            if (HeinHelpers.isSimulatorOrTestFlight()) {
                MatomoTracker.shared.logger = DefaultLogger(minLevel: .verbose)
            }

            #if DEBUG
            if #available(iOS 13.0, *), CommandLine.arguments.contains("UITestingDarkModeEnabled") {
                window?.overrideUserInterfaceStyle = .dark
            }
            #endif
            
            myQRcodeMatomo.track(action: myQRcodeMatomo.basicAction, name: myQRcodeMatomo.appStartAction)
            
            return true
        }
        
        return false
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Save changes in the application's managed object context when the application transitions to the background.
        saveContext()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
          The persistent container for the application. This implementation
          creates and returns a container, having loaded the store for the
          application to it. This property is optional since there are legitimate
          error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "History")
        container.loadPersistentStores(completionHandler: { _, error in
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
    func saveContext() {
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
    
    // MARK: - Tab Bar
    func setDefaultTab(tabVC: UITabBarController) {
        let tabIndex = UserDefaults.standard.integer(forKey: localStoreKeys.defaultTab)
        if let selectedTab = TabOption(rawValue: tabIndex) {
            tabVC.selectedIndex = selectedTab.rawValue
        } else {
            HeinHelpers.showMessage(
                title: "Error",
                message: "Invalid index provided in setDefaultTab(tabVC:, index: \(tabIndex)",
                on: (self.window?.rootViewController)!
            )
        }
    }
}
