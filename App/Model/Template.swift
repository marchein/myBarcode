//
//  Template.swift
//  myBarcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation

class Template: TemplateItem, CustomStringConvertible, NSCopying, Equatable {
    static func == (lhs: Template, rhs: Template) -> Bool {
        return lhs.name == rhs.name &&
            lhs.parameters == rhs.parameters &&
            lhs.parameterType == rhs.parameterType &&
            lhs.placeholders == rhs.placeholders &&
            lhs.templateString == rhs.templateString &&
            lhs.options == rhs.options &&
            lhs.indexOflastImportantField == rhs.indexOflastImportantField
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Template(name: name, templateString: templateString, parameters: parameters, parameterType: parameterType, placeholders: placeholders, options: options, indexOflastImportantField: indexOflastImportantField)
    }
    
    var parameters: [String]
    var parameterType: [TemplateParameterType]
    var parameterValues: [String]
    var placeholders: [String?]
    var templateString: String
    var options: [[String]?]
    var indexOflastImportantField: Int
    var modified: Bool = false
    
    init(name: String,
         templateString: String,
         parameters: [String],
         parameterType: [TemplateParameterType],
         placeholders: [String?],
         options: [[String]?],
         indexOflastImportantField: Int? = nil)
    {
        if parameters.count != parameterType.count {
            fatalError("Number of parameters must be equal to number of descriptions")
        }
        
        if parameters.count != placeholders.count {
            fatalError("Every parameter needs a placeholder text")
        }
        
        if options.count != parameters.count {
            fatalError("Options must always be given!")
        }

        self.templateString = templateString
        self.parameters = parameters
        self.parameterType = parameterType
        self.placeholders = placeholders
        self.options = options
        self.parameterValues = parameters
        self.indexOflastImportantField = indexOflastImportantField ?? parameters.count - 1
        super.init(name: name)
    }
    
    lazy var resultString: String? = String(format: templateString, arguments: parameterValues)
    
    var description: String {
        return "Name: \(name), Template String: \(templateString), Parameters: \(parameters), Parameter Type: \(parameterType), Parameter Values: \(parameterValues), Placeholders: \(placeholders), Options: \(options), IndexOfLastImportantField: \(indexOflastImportantField)"
    }
    
    func setModifiedTemplate() {
        modified = true
    }
}

enum TemplateParameterType {
    case Text
    case Selector
}

class TemplateSeperator: TemplateItem {}

class TemplateItem {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
