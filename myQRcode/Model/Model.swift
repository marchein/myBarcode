//
//  Model.swift
//  myQRcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//

import Foundation

struct Model {
    static let Templates = [
        Template(name: NSLocalizedString("wifi_template", comment: ""), templateString: "WIFI:T:%@;S:%@;P:%@;;", parameters: [NSLocalizedString("wifi_security", comment: ""), NSLocalizedString("wifi_name", comment: ""), NSLocalizedString("wifi_password", comment: "")], parameterType: [.Selector, .Text, .Text], placeholders: [nil, NSLocalizedString("TEMPLATES_PLACEHOLDER_WIFI_NAME", comment: ""), "123password!?$%"], options: [["nopass", "WEP", "WPA"], nil, nil]),
        Template(name: NSLocalizedString("email_template", comment: ""), templateString: "mailto:%@", parameters: [NSLocalizedString("email_address", comment: "")], parameterType: [.Text], placeholders: ["hello@placeholder.com"], options: [nil]),
        Template(name: NSLocalizedString("phone_template", comment: ""), templateString: "tel:%@", parameters: [NSLocalizedString("phone_number", comment: "")], parameterType: [.Text], placeholders: ["+12 4567 89101112"], options: [nil]),
        Template(name: NSLocalizedString("message_template", comment: ""), templateString: "sms:%@", parameters: [NSLocalizedString("message_number", comment: "")], parameterType: [.Text], placeholders: ["+12 4567 89101112"], options: [nil])
    ]
}
