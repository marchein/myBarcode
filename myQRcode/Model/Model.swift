//
//  Model.swift
//  myQRcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation

struct Model {
    static let Templates: [[TemplateItem]] = [
        [TemplateSeperator(name: "TEMPLATE_CATEGORY_SOCIAL".localized),
         // Instagram Template
         Template(
             name: "Instagram",
             templateString: "https://instagram.com/%@",
             parameters: ["TEMPLATE_INSTAGRAM_USERNAME".localized],
             parameterType: [.Text],
             placeholders: ["TEMPLATE_INSTAGRAM_USERNAME_PLACEHOLDER".localized],
             options: [nil]
         ),
         // Twitter Template
         Template(
             name: "Twitter",
             templateString: "https://twitter.com/%@",
             parameters: ["TEMPLATE_TWITTER_USERNAME".localized],
             parameterType: [.Text],
             placeholders: ["TEMPLATE_TWITTER_USERNAME_PLACEHOLDER".localized],
             options: [nil]
         )],
        [TemplateSeperator(name: "TEMPLATE_CATEGORY_PHONE".localized),
         // Phone Template
         Template(
             name: "phone_template".localized,
             templateString: "tel:%@",
             parameters: ["phone_number".localized],
             parameterType: [.Text],
             placeholders: ["+12 4567 89101112"],
             options: [nil]
         ),
         // Message Template
         Template(
             name: "message_template".localized,
             templateString: "sms:%@",
             parameters: ["message_number".localized],
             parameterType: [.Text],
             placeholders: ["+12 4567 89101112"],
             options: [nil]
         )],
        [TemplateSeperator(name: "TEMPLATE_CATEGORY_MAIL".localized),
         // Mail Template
         Template(
             name: "email_template".localized,
             templateString: "mailto:%@",
             parameters: ["email_address".localized],
             parameterType: [.Text],
             placeholders: ["hello@placeholder.com"],
             options: [nil]
         ),
         // Complete Mail Template
         Template(
             name: "TEMPLATE_EMAIL_WITH_CONTENT".localized,
             templateString: "MATMSG:TO:%@;SUB:%@;BODY:%@;;",
             parameters: [
                 "TEMPLATE_EMAIL_WITH_CONTENT_RECEIPIENT".localized,
                 "TEMPLATE_EMAIL_WITH_CONTENT_SUBJECT".localized,
                 "TEMPLATE_EMAIL_WITH_CONTENT_BODY".localized
             ],
             parameterType: [.Text, .Text, .Text],
             placeholders: [
                 "TEMPLATE_EMAIL_WITH_CONTENT_RECEIPIENT_PLACEHOLDER".localized,
                 "TEMPLATE_EMAIL_WITH_CONTENT_SUBJECT_PLACEHOLDER".localized,
                 "TEMPLATE_EMAIL_WITH_CONTENT_BODY_PLACEHOLDER".localized
             ],
             options: [nil, nil, nil],
             indexOflastImportantField: 0
         )],
        [TemplateSeperator(name: "TEMPLATE_CATEGORY_MISCELLANEOUS".localized),
         // WIFI Template
         Template(
             name: "wifi_template".localized,
             templateString: "WIFI:T:%@;S:%@;P:%@;;",
             parameters: ["wifi_security".localized, "wifi_name".localized, "wifi_password".localized],
             parameterType: [.Selector, .Text, .Text],
             placeholders: [nil, "TEMPLATES_PLACEHOLDER_WIFI_NAME".localized, "123password!?$%"],
             options: [["nopass", "WEP", "WPA"], nil, nil],
             indexOflastImportantField: 1
         )]
    ]
}
