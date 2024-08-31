//
//  AppTracking.swift
//  myBarcode
//
//  Created by Marc Hein on 31.08.24.
//  Copyright © 2024 Marc Hein. All rights reserved.
//

import AppTrackingTransparency
import MatomoTracker

/// The `AppTracking` class handles the tracking authorization status for the app
/// and integrates with the Matomo analytics tracker to manage user tracking preferences.
class AppTracking {
    /// Indicates whether the user has granted permission to be tracked.
    private(set) var canTrackUser: Bool?
    
    /// Indicates whether the tracking authorization status is undetermined.
    private(set) var statusUndetermined: Bool = false
    
    /// Initializes the `AppTracking` instance and updates the tracking status.
    init() {
        updateTrackingStatus()
    }
    
    /// Updates the tracking status by fetching the current authorization status.
    /// This method sets the `canTrackUser` and `isStatusUndetermined` properties based on the status.
    func updateTrackingStatus() {
        let trackingStatus = ATTrackingManager.trackingAuthorizationStatus
        canTrackUser = handleTrackingStatus(status: trackingStatus)
    }
    
    // MARK: - Tracking

    /// Handles the tracking authorization status and updates the relevant properties.
    ///
    /// - Parameter status: The current tracking authorization status.
    /// - Returns: A `Bool` indicating if the user allows tracking, or `nil` if the status is undetermined.
    private func handleTrackingStatus(status: ATTrackingManager.AuthorizationStatus) -> Bool? {
        switch status {
        case .authorized:
            // The user authorizes tracking.
            return true
        case .denied:
            // The user denies tracking.
            return false
        case .restricted:
            // Tracking is restricted (e.g., parental controls).
            return false
        case .notDetermined:
            // The user has not yet made a choice regarding tracking.
            statusUndetermined = true
            return nil
        @unknown default:
            // Handle any future cases that may be added to the API.
            print("Unknown status: \(status)")
            return nil
        }
    }
    
    /// Requests tracking authorization from the user and updates the tracking preferences in Matomo.
    func requestTracking() {
        DispatchQueue.main.async {
            ATTrackingManager.requestTrackingAuthorization { status in
                let canTrackUser = self.handleTrackingStatus(status: status)
                self.canTrackUser = canTrackUser
                MatomoTracker.shared.isOptedOut = !(canTrackUser ?? false)
                MatomoTracker.shared.dispatch()
            }
        }
    }
    
    /// Checks if the user can be tracked.
    ///
    /// - Returns: `true` if the user can be tracked, `false` otherwise.
    func userCanBeTracked() -> Bool {
        return canTrackUser ?? false
    }

    /// Checks if the tracking status is undetermined.
    ///
    /// - Returns: `true` if the status is undetermined, `false` otherwise.
    func isStatusUndetermined() -> Bool {
        return statusUndetermined
    }
}
