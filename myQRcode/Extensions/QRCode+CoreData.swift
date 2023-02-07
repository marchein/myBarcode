//
//  QRCode+CoreData.swift
//  myQRcode
//
//  Created by Marc Hein on 07.02.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

extension QRCode {
    private static var _coreDataObject = HistoryItem()

    var coreDataObject: HistoryItem? {
        get {
            guard
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return nil
            }
            
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            let newItem = HistoryItem(context: managedObjectContext)
            newItem.content = self.content
            newItem.date = self.date
            newItem.category = self.category == HistoryCategory.generate
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            return newItem
        }
    }
}
