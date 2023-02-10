//
//  TemplateEditingTableViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class TemplateEditingTableViewController: UITableViewController, UITextFieldDelegate {
    var isSingleView = false
    var selectedTemplate: Template?
    var generateVC: GenerateViewController?
    var textFields: [UITextField] = []
    var isSetup = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (isSingleView) {
            self.navigationItem.hidesBackButton = true
        }
    }
    
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
                let textFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.Identifier, for: indexPath) as! TextFieldTableViewCell
                
                if let selectedTemplate = selectedTemplate, selectedTemplate.modified {
                    textFieldTableViewCell.textField.text = selectedTemplate.parameterValues[indexPath.section]
                }
                
                if let placeholder = selectedTemplate?.placeholders[indexPath.section] {
                    textFieldTableViewCell.textField.placeholder = placeholder
                }

                return textFieldTableViewCell
            }
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Cells.GenerateCell, for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let template = selectedTemplate else {
            return nil
        }
        
        return template.parameters.count > section ? template.parameters[section] : nil
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 {
            self.generateButtonTapped()
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func generateButtonTapped() {
        var parameterValues: [String] = []
        let numberOfButtons = tableView.numberOfSections - 1
        for i in 0..<numberOfButtons {
            let indexPath = IndexPath(row: 0, section: i)
            let cell = tableView.cellForRow(at: indexPath)
            if let segmentedCell = cell as? SegmentedControlTableViewCell, let options = segmentedCell.options {
                parameterValues.append(options[segmentedCell.segmentedControl.selectedSegmentIndex])
            } else if let textFieldCell = cell as? TextFieldTableViewCell, let parameter = textFieldCell.textField.text  {
                parameterValues.append(parameter)
            }
        }
        let usedTemplate = self.selectedTemplate!.copy() as! Template
        usedTemplate.parameterValues = parameterValues
        usedTemplate.setModifiedTemplate()
        
        self.dismiss(animated: true) {
            if let resultString = usedTemplate.resultString, let generateVC = self.generateVC {
                generateVC.usedTemplate = usedTemplate
                generateVC.tableView.reloadData()
                generateVC.enterQR(content: resultString)
            }
        }
    }
    
    private func setupTextFields() {
        let numberOfLastImportantTF = selectedTemplate == Model.Templates[0] ? 2 : 1
        for sectionIndex in 0..<tableView.numberOfSections - numberOfLastImportantTF {
            let indexPath = IndexPath(row: 0, section: sectionIndex)
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
        // last section is always generate button
        let sectionOfGenerateButton = self.tableView.numberOfSections - 1
        let generateCell = tableView.cellForRow(at: IndexPath(row: 0, section: sectionOfGenerateButton)) as! ButtonTableViewCell
        generateCell.accessibilityIdentifier = "generateQRCodeFromTemplateCell"
        generateCell.isEnabled = checkIfGenerationIsPossible()
    }
}
