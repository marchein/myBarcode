//
//  MatomoTracker+Shared.swift
//  myQRcode
//
//  Created by Marc Hein on 01.06.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
import MatomoTracker

extension MatomoTracker {
    static let shared: MatomoTracker = MatomoTracker(siteId: "2", baseURL: URL(string: "https://matomo.marc-hein.de/matomo.php")!)
}

