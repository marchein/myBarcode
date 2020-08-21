//
//  TemplateEditingTableViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class TemplateEditingTableViewController: UITableViewController, UITextFieldDelegate {
    
    var selectedTemplate: Template?
    var generateVC: GenerateViewController?
    var textFields: [UITextField] = []
    var isSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextFields()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let template = selectedTemplate else {
            return 0
        }
        return template.parameters.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let template = selectedTemplate else {
            fatalError("Template is not set")
        }
        if indexPath.section < template.parameters.count {
            if template.parameterType[indexPath.section] == .Selector {
                let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedControlTableViewCell.Identifier, for: indexPath) as! SegmentedControlTableViewCell
                if !self.isSetup {
                    cell.options = template.options[indexPath.section]
                }
                self.isSetup = true
                return cell
            } else {
                return tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.Identifier, for: indexPath) as! TextFieldTableViewCell
            }
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "generateCell", for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let template = selectedTemplate else {
            return nil
        }
        if template.parameters.count > section {
            return template.parameters[section]
        } else {
            return nil
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 {
            self.generateButtonTapped()
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func generateButtonTapped() {
        var parameters: [String] = []
        for i in 0..<tableView.numberOfSections - 1 {
            let indexPath = IndexPath(row: 0, section: i)
            let cell = tableView.cellForRow(at: indexPath)
            if let segmentedCell = cell as? SegmentedControlTableViewCell, let options = segmentedCell.options {
                parameters.append(options[segmentedCell.segmentedControl.selectedSegmentIndex])
            } else if let textFieldCell = cell as? TextFieldTableViewCell, let parameter = textFieldCell.textField.text  {
                parameters.append(parameter)
            }
        }
        let usedTemplate = self.selectedTemplate!.copy() as! Template
        usedTemplate.parameters = parameters
        self.dismiss(animated: true) {
            if let resultString = usedTemplate.resultString, let generateVC = self.generateVC {
                generateVC.enterQR(content: resultString)
            }
        }
    }
    
    private func setupTextFields() {
        let numberOfLastImportantTF = selectedTemplate == Model.Templates[0] ? 2 : 1
        for i in 0..<tableView.numberOfSections - numberOfLastImportantTF {
            let indexPath = IndexPath(row: 0, section: i)
            let cell = tableView.cellForRow(at: indexPath)
            if let textFieldCell = cell as? TextFieldTableViewCell {
                self.textFields.append(textFieldCell.textField)
                textFieldCell.textField.delegate = self
                textFieldCell.textField.addTarget(self, action: #selector(setGenerateButton), for: UIControl.Event.editingChanged)

            }
        }
        self.setGenerateButton()
    }
    
    private func checkIfGenerationIsPossible() -> Bool {
        for textField in self.textFields {
            if textField.text?.isEmpty ?? true {
                return false
            }
        }
        return true
    }
    
    @objc func setGenerateButton() {
        let generateCell = tableView.cellForRow(at: IndexPath(row: 0, section: self.tableView.numberOfSections - 1)) as! ButtonTableViewCell
        generateCell.isEnabled = checkIfGenerationIsPossible()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
