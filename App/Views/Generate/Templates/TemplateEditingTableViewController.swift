//
//  TemplateEditingTableViewController.swift
//  myBarcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class TemplateEditingTableViewController: UITableViewController, UITextFieldDelegate {
    var isSingleView = false
    var selectedTemplate: Template!
    var generateVC: GenerateViewController?
    var isSetup = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // used for "reuse template" feature from generate tab home
        if isSingleView {
            navigationItem.hidesBackButton = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Disable generate button on load
        setGenerateButton()
        myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateOpenTemplates)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setCursorInFirstTextfield()
    }
        
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // number of parameters + generate button
        return selectedTemplate.parameters.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // every section has only a button or input field
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < selectedTemplate.parameters.count {
            // use a parameter cell
            if selectedTemplate.parameterType[indexPath.section] == .Selector {
                // current cell is selector cell
                let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedControlTableViewCell.Identifier, for: indexPath) as! SegmentedControlTableViewCell
                if !isSetup {
                    cell.options = selectedTemplate.options[indexPath.section]
                }
                // cell.selectedIndex = 1
                isSetup = true
                return cell
            }
            
            // current cell is textview cell
            let textFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.Identifier, for: indexPath) as! TextFieldTableViewCell
            
            if let selectedTemplate = selectedTemplate, selectedTemplate.modified {
                textFieldTableViewCell.textField.text = selectedTemplate.parameterValues[indexPath.section]
            }
            
            if let placeholder = selectedTemplate?.placeholders[indexPath.section] {
                textFieldTableViewCell.textField.placeholder = placeholder
            }
            
            textFieldTableViewCell.textField.autocorrectionType = .no
            textFieldTableViewCell.textField.delegate = self
            textFieldTableViewCell.textField.addTarget(self, action: #selector(setGenerateButton), for: UIControl.Event.editingChanged)

            return textFieldTableViewCell
        } else {
            // Generate button cell
            return tableView.dequeueReusableCell(withIdentifier: Cells.GenerateCell, for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedTemplate.parameters.count > section ? selectedTemplate.parameters[section] : nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == tableView.numberOfSections - 1 {
            generateButtonTapped()
        }
    }
    
    func generateButtonTapped() {
        var parameterValues: [String] = []
        let numberOfButtons = tableView.numberOfSections - 1
        for i in 0..<numberOfButtons {
            let indexPath = IndexPath(row: 0, section: i)
            let cell = tableView.cellForRow(at: indexPath)
            if let segmentedCell = cell as? SegmentedControlTableViewCell, let options = segmentedCell.options {
                parameterValues.append(options[segmentedCell.segmentedControl.selectedSegmentIndex])
            } else if let textFieldCell = cell as? TextFieldTableViewCell, let parameter = textFieldCell.textField.text {
                parameterValues.append(parameter)
            }
        }
        let usedTemplate = selectedTemplate.copy() as! Template
        usedTemplate.parameterValues = parameterValues
        usedTemplate.setModifiedTemplate()
        
        dismiss(animated: true) {
            if let resultString = usedTemplate.resultString, let generateVC = self.generateVC {
                generateVC.usedTemplate = usedTemplate
                generateVC.tableView.reloadData()
                generateVC.enterCode(content: resultString, resetToDefaultCodeType: false)
            }
        }
    }

    private func checkIfGenerationIsPossible() -> Bool {
        // by default generation is possible
        var generationPossible = true
        
        for i in 0..<tableView.numberOfSections {
            // get cell for section (under the assumption every section only has one row)
            let indexPath = IndexPath(row: 0, section: i)
            let cell = tableView.cellForRow(at: indexPath)
            // only sections below indexOfLastImportant field are interesting to check
            // check if cell is text field cell and check if the text field is empty
            // if it empty, disable generation
            if i <= selectedTemplate.indexOflastImportantField,
               let tfCell = cell as? TextFieldTableViewCell,
               tfCell.textField.text?.isEmpty ?? true {
                generationPossible = false
            }
        }

        return generationPossible
    }

    @objc func setGenerateButton() {
        // last section is always generate button
        let sectionOfGenerateButton = tableView.numberOfSections - 1
        let generateCell = tableView.cellForRow(at: IndexPath(row: 0, section: sectionOfGenerateButton)) as! ButtonTableViewCell
        generateCell.accessibilityIdentifier = "generateQRCodeFromTemplateCell"
        generateCell.isEnabled = checkIfGenerationIsPossible()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        generateButtonTapped()
        return false
    }
    
    func setCursorInFirstTextfield() {
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if let cell = tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell {
                    cell.textField.becomeFirstResponder()
                    return // Stop once the first textfield is found and becomes the first responder
                }
            }
        }
    }
}
