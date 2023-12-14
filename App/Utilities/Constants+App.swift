//
//  Constants+App.swift
//  myBarcode
//
//  Created by Marc Hein on 14.12.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

extension myBarcode {
    static func getGenerateVC() -> GenerateViewController? {
        if let tabVC = UIApplication.shared.windows.first!.rootViewController as? UITabBarController,
           let navVC = tabVC.children.first as? UINavigationController,
           let mainVC = navVC.children.first as? GenerateViewController {
            return mainVC
        }
        return nil
    }
}
