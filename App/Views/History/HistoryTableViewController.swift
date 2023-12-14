//
//  HistoryTableViewController.swift
//  myBarcode
//
//  Created by Marc Hein on 16.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import CoreData
import UIKit
import HeinHelpers

class HistoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    // MARK: - Outlets
    @IBOutlet var noItemsView: NoItemsView!
    
    // MARK: - Properties
    var category: HistoryCategory?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<HistoryItem>? {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }

    weak var delegate: HistoryItemDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.category == nil {
            self.category = .generate
        }
        
        self.updateFetchedResultsController()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        if category == HistoryCategory.generate {
            myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateHistory)
        } else {
            myBarcodeMatomo.track(action: myBarcodeMatomo.scanAction, name: myBarcodeMatomo.scanHistory)
        }
    }
    
    // MARK: - Core Data

    func updateFetchedResultsController() {
        guard let context = container?.viewContext else {
            return
        }
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<HistoryItem> = HistoryItem.fetchRequest()
            
            fetchRequest.returnsObjectsAsFaults = false
            
            // Configure fetch request
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "category == %@", NSNumber(value: self.category == HistoryCategory.generate))
            
            // Create fetched results controller
            fetchedResultsController = NSFetchedResultsController<HistoryItem>(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: #keyPath(HistoryItem.isoDate),
                cacheName: nil)
            do {
                try fetchedResultsController!.performFetch()
                self.tableView.reloadData()
            } catch {
                HeinHelpers.showMessage(title: "Fehler", message: "Es ist ein Fehler bei der iCloud Synchronisation aufgetreten: \(error)", on: self)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = self.fetchedResultsController?.sections?.count, sections > 0 else {
            self.noItemsView.category = self.category
            self.tableView.backgroundView = self.noItemsView
            self.tableView.separatorStyle = .none
            self.navigationItem.leftBarButtonItem = nil
            return 0
        }
        self.tableView.backgroundView = nil
        self.tableView.separatorStyle = .singleLine
        self.navigationItem.leftBarButtonItem = editButtonItem
        return sections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryItemTableViewCell.Identifier, for: indexPath) as? HistoryItemTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        self.configureCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    private func configureCell(cell: HistoryItemTableViewCell, indexPath: IndexPath) {
        guard let historyItem = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("No historyItem retrieved for indexPath: \(indexPath)")
        }
        cell.historyItem = historyItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let historyItem = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("No historyItem retrieved for indexPath: \(indexPath)")
        }

        self.dismiss(self)
        self.delegate?.userSelectedHistoryItem(item: historyItem)
        
        if self.category == HistoryCategory.generate {
            myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateHistorySelected)
        } else {
            myBarcodeMatomo.track(action: myBarcodeMatomo.scanAction, name: myBarcodeMatomo.scanHistorySelected)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            guard let objectToDelete = self.fetchedResultsController?.object(at: indexPath), let context = container?.viewContext else {
                return
            }
            context.delete(objectToDelete)
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("\(error) - \(error.userInfo)")
            }
            if category == HistoryCategory.generate {
                myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateHistoryDeleted)
            } else {
                myBarcodeMatomo.track(action: myBarcodeMatomo.scanAction, name: myBarcodeMatomo.generateHistoryDeleted)
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections([sectionIndex], with: .fade)
        case .delete:
            self.tableView.deleteSections([sectionIndex], with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    // MARK: - Actions
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// protocol used for sending data back
protocol HistoryItemDelegate: AnyObject {
    func userSelectedHistoryItem(item: HistoryItem)
}
