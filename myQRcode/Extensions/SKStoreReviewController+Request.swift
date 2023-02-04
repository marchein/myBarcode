//
//  SKStoreReviewController+Request.swift
//  myQRcode
//
//  Created by Marc Hein on 03.02.23.
//  Copyright © 2023 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import StoreKit

@available(iOS 14.0, *)
extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                requestReview(in: scene)
            }
        }
    }
}
