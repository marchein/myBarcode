//
//  GenerateViewController+Helpers.swift
//  myBarcode
//
//  Created by Marc Hein on 19.03.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit
import SwiftUI
import WhatsNewKit

extension GenerateViewController {
    func showChangelog() {
        // Verify WhatsNewViewController is available for presentation
        guard let whatsNewViewController = WhatsNewViewController(
            whatsNew: getChangelog(),
            versionStore: UserDefaultsWhatsNewVersionStore()
        ) else {
            // Version of WhatsNew has already been presented
            return
        }
        
        // Present WhatsNewViewController
        // Version will be automatically saved in the provided
        // WhatsNewVersionStore when the WhatsNewViewController gets dismissed
        #if !targetEnvironment(simulator)
        self.present(whatsNewViewController, animated: true)
        #endif
    }
    
    func getChangelog() -> WhatsNew {
        return WhatsNew(
            version: "2.0",
            title: .init(stringLiteral: "CHANGELOG_HEADLINE".localized),
            features: [
                .init(
                    image: .init(
                        systemName: "star.fill",
                        foregroundColor: .yellow
                    ),
                    title: .init("CHANGELOG_2_0_TOP1_TITLE".localized),
                    subtitle: .init("CHANGELOG_2_0_TOP1_SUBTITLE".localized)
                ),
                .init(
                    image: .init(
                        systemName: "barcode",
                        foregroundColor: Color(uiColor: .label)
                    ),
                    title: .init("CHANGELOG_2_0_TOP2_TITLE".localized),
                    subtitle: .init("CHANGELOG_2_0_TOP2_SUBTITLE".localized)
                ),
                .init(
                    image: .init(
                        systemName: "barcode.viewfinder",
                        foregroundColor: .green
                    ),
                    title: .init("CHANGELOG_2_0_TOP3_TITLE".localized),
                    subtitle: .init("CHANGELOG_2_0_TOP3_SUBTITLE".localized)
                ),
                .init(
                    image: .init(
                        systemName: "gear.circle.fill",
                        foregroundColor: .gray
                    ),
                    title: .init("CHANGELOG_2_0_TOP4_TITLE".localized),
                    subtitle: .init("CHANGELOG_2_0_TOP4_SUBTITLE".localized)
                )
            ],
            primaryAction: .init(
                title: .init("CHANGELOG_CONTINUE".localized)
            )
        )
    }
}
