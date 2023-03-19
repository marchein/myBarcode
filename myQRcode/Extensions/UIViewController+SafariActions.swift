//
//  UIViewController+SafariActions.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
import SafariServices
import UIKit

// MARK:- Safari Extension
extension UIViewController: SFSafariViewControllerDelegate {
    public func openSafariViewControllerWith(url: String) {
        guard let safariURL = URL(string: url) else { return }
        
        let safariVC = SFSafariViewController(url: safariURL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
