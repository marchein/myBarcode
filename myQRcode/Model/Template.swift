//
//  File.swift
//  myQRcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//

import Foundation

class Template: CustomStringConvertible, NSCopying, Equatable {
    static func == (lhs: Template, rhs: Template) -> Bool {
        return lhs.name == rhs.name && lhs.parameters == rhs.parameters && lhs.parameterType == rhs.parameterType && lhs.templateString == rhs.templateString && lhs.options == rhs.options
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Template(name: name, templateString: templateString, parameters: parameters, parameterType: parameterType, options: options)
    }
    
    var name: String
    var parameters: [String]
    var parameterType: [TemplateParameterType]
    var templateString: String
    var options: [[String]?]
    
    
    init(name: String, templateString: String, parameters: [String], parameterType: [TemplateParameterType], options: [[String]?]) {
        if parameters.count != parameterType.count {
            fatalError("Number of parameters must be equal to number of descriptions")
        }
        if options.count != parameters.count {
            fatalError("Options must always be given!")
        }

        self.name = name
        self.templateString = templateString
        self.parameters = parameters
        self.parameterType = parameterType
        self.options = options
    }
    
    lazy var resultString: String? = {
        return String(format: templateString, arguments: parameters)
    }()
    
    var description: String {
        return "Name: \(name), Parameters: \(parameters), Parameter Type: \(parameterType), Template String: \(templateString), Options: \(options)"
    }
}

enum TemplateParameterType {
    case Text
    case Selector
}
