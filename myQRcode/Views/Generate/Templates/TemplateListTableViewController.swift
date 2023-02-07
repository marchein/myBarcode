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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.Templates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.TemplateCell, for: indexPath)
        cell.textLabel?.text = Model.Templates[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: myQRcodeSegues.EditTemplateSegue, sender: Model.Templates[indexPath.row])
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == myQRcodeSegues.EditTemplateSegue, let editVC = segue.destination as? TemplateEditingTableViewController {
            // provide selected template to editing VC
            editVC.selectedTemplate = sender as? Template
            // provide generate VC to editing VC
            editVC.generateVC = self.generateVC
        }
    }
}
