//
//  File.swift
//  myQRcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation

class Template: CustomStringConvertible, NSCopying, Equatable {
    static func == (lhs: Template, rhs: Template) -> Bool {
        return lhs.name == rhs.name && lhs.parameters == rhs.parameters && lhs.parameterType == rhs.parameterType && lhs.placeholders == rhs.placeholders && lhs.templateString == rhs.templateString && lhs.options == rhs.options
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Template(name: name, templateString: templateString, parameters: parameters, parameterType: parameterType, placeholders: placeholders, options: options)
    }
    
    var name: String
    var parameters: [String]
    var parameterType: [TemplateParameterType]
    var parameterValues: [String]
    var placeholders: [String?]
    var templateString: String
    var options: [[String]?]
    var modified: Bool = false
    
    
    init(name: String, templateString: String, parameters: [String], parameterType: [TemplateParameterType], placeholders: [String?], options: [[String]?]) {
        if parameters.count != parameterType.count {
            fatalError("Number of parameters must be equal to number of descriptions")
        }
        
        if parameters.count != placeholders.count {
            fatalError("Every parameter needs a placeholder text")
        }
        
        if options.count != parameters.count {
            fatalError("Options must always be given!")
        }

        self.name = name
        self.templateString = templateString
        self.parameters = parameters
        self.parameterType = parameterType
        self.placeholders = placeholders
        self.options = options
        self.parameterValues = parameters
    }
    
    lazy var resultString: String? = {
        return String(format: templateString, arguments: parameterValues)
    }()
    
    var description: String {
        return "Name: \(name), Template String: \(templateString), Parameters: \(parameters), Parameter Type: \(parameterType), Placeholders: \(placeholders), Options: \(options)"
    }
    
    func setModifiedTemplate() {
        modified = true
    }
}

enum TemplateParameterType {
    case Text
    case Selector
}
