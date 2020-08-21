//
//  HistoryTableViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 16.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet var noItemsView: NoItemsView!
    
    var category: HistoryCategory?
    // MARK: - Properties
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<HistoryItem>? {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }
    weak var delegate: HistoryItemDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.category == nil {
            self.category = .generate
        }
        
        self.updateFetchedResultsController()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
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
            
            // Create fetched results controlelr
            fetchedResultsController = NSFetchedResultsController<HistoryItem>(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: #keyPath(HistoryItem.isoDate),
                cacheName: nil)
            do {
                try fetchedResultsController!.performFetch()
                self.tableView.reloadData()
            } catch {
                //self.showAlert(alertText: "Fehler", alertMessage: "Es ist ein Fehler bei der iCloud Synchronisation aufgetreten: \(error)", closeButton: "Schließen")
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = self.fetchedResultsController?.sections?.count, sections > 0 else {
            self.noItemsView.category = self.category
            self.tableView.backgroundView = self.noItemsView
            self.tableView.separatorStyle = .none
            return 0
        }
        self.tableView.backgroundView = nil
        self.tableView.separatorStyle = .singleLine
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryItemTableViewCell.reuseIdentifier, for: indexPath) as? HistoryItemTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        configureCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    private func configureCell(cell: HistoryItemTableViewCell, indexPath: IndexPath) {
        guard let historyItem = self.fetchedResultsController?.object(at: indexPath) else {
            //self.showAlert(alertText: "Fehler", alertMessage: "No mood retrieved for indexPath: \(indexPath)", closeButton: "Schließen")
            fatalError("No historyItem retrieved for indexPath: \(indexPath)")
        }
        cell.historyItem = historyItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let historyItem = self.fetchedResultsController?.object(at: indexPath) else {
            //self.showAlert(alertText: "Fehler", alertMessage: "No mood retrieved for indexPath: \(indexPath)", closeButton: "Schließen")
            fatalError("No historyItem retrieved for indexPath: \(indexPath)")
        }
        if self.category == HistoryCategory.generate {
            self.delegate?.userSelectedHistoryItem(item: historyItem)
            self.dismiss(self)
        } else {
            self.dismiss(animated: true) {
                self.delegate?.userSelectedHistoryItem(item: historyItem)
            }
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
        }
    }
    
    // MARK:- NSFetchedResultsControllerDelegate
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
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// protocol used for sending data back
protocol HistoryItemDelegate: class {
    func userSelectedHistoryItem(item: HistoryItem)
}
