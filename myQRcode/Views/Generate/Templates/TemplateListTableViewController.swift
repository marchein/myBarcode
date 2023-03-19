//
//  TemplateListTableViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class TemplateListTableViewController: UITableViewController {
    
    var generateVC: GenerateViewController?
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Model.Templates.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.Templates[section].count - 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.TemplateCell, for: indexPath)
        cell.textLabel?.text = Model.Templates[indexPath.section][indexPath.row + 1].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Model.Templates[section][0].name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: myQRcodeSegues.EditTemplateSegue, sender: Model.Templates[indexPath.section][indexPath.row + 1])
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == myQRcodeSegues.EditTemplateSegue,
            let editVC = segue.destination as? TemplateEditingTableViewController {
            // provide selected template to editing VC
            editVC.selectedTemplate = sender as? Template
            // provide generate VC to editing VC
            editVC.generateVC = self.generateVC
            
            // If template has been modified (^= reused) hide back button
            if let selectedTemplate = editVC.selectedTemplate, selectedTemplate.modified {
                editVC.isSingleView = true
            }
        }
    }
}
