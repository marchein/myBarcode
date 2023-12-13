//
//  Code+CoreData.swift
//  myBarcode
//
//  Created by Marc Hein on 07.02.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

extension Code {
    @discardableResult
    func addToCoreData() -> HistoryItem {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            fatalError("Could not find AppDelegate")
        }

        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let newItem = HistoryItem(context: managedObjectContext)
        newItem.content = self.content
        newItem.date = self.date
        newItem.category = self.category == HistoryCategory.generate
        
        if self is Code128 {
            newItem.type = myBarcode.codeValues[.CODE128]
        } else if self is PDF417 {
            newItem.type = myBarcode.codeValues[.PDF417]
        } else if self is Aztec {
            newItem.type = myBarcode.codeValues[.AZTEC]
        } else {
            newItem.type = myBarcode.codeValues[.QR]
        }
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        return newItem
    }
}
