//
//  GenerateViewController+TableView.swift
//  myQRcode
//
//  Created by Marc Hein on 19.03.23.
//  Copyright © 2023 Marc Hein Webdesign. All rights reserved.
//

import UIKit

extension GenerateViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resignTextViewFirstResponder()
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 ||  section == 1 || (section == 2 && usedTemplate != nil) {
            return 2
        }
        return 1
    }
}
