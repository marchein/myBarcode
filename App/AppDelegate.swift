//
//  AppDelegate.swift
//  myBarcode
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
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return false
        }
        setDefaultTab(tabVC: tabBarController)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScannerAction),
            name: .startScanner,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGenerateAction),
            name: .startGenerator,
            object: nil
        )
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        MatomoTracker.shared.userId = deviceId
        
        #if DEBUG
        if CommandLine.arguments.contains("UITestingDarkModeEnabled") {
            window?.overrideUserInterfaceStyle = .dark
        }
        #endif
        
        myBarcodeMatomo.track(action: myBarcodeMatomo.basicAction, name: myBarcodeMatomo.appStartAction)
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Save changes in the application's managed object context when the application transitions to the background.
        saveContext()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        MatomoTracker.shared.dispatch()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "History")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
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
    
    // MARK: - App Intent
    private func openAppBase(tabVC: UITabBarController, showScanner: Bool = false) {
        if showScanner {
            tabVC.selectedIndex = 1
            return
        }
        tabVC.selectedIndex = 0
    }
    
    @objc private func handleScannerAction() {
        DispatchQueue.main.async {
            guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
                return
            }
            
            self.openAppBase(tabVC: tabBarController, showScanner: true)
        }
    }
    
    @objc private func handleGenerateAction() {
        DispatchQueue.main.async {
            guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
                return
            }
            
            self.openAppBase(tabVC: tabBarController, showScanner: false)
        }
    }
    
    // Remove the observer when the app delegate is deallocated
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
