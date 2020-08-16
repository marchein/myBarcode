//
//  ActivityIndicatorOverlay.swift
//  myQRcode
//
//  Created by Marc Hein on 16.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//
// https://gist.github.com/edc0der/e4bed05b4c6653ffcd36c0609f27c7c6

import UIKit

fileprivate let overlayViewTag: Int = 999
fileprivate let activityIndicatorViewTag: Int = 1000

// Public interface
extension UIView {
    func displayAnimatedActivityIndicatorView() {
        setActivityIndicatorView()
    }
    
    func hideAnimatedActivityIndicatorView() {
        removeActivityIndicatorView()
    }
}

extension UIViewController {
    private var overlayContainerView: UIView {
        if let navigationView: UIView = navigationController?.view {
            return navigationView
        }
        return view
    }
    
    func displayAnimatedActivityIndicatorView() {
        overlayContainerView.displayAnimatedActivityIndicatorView()
    }
    
    func hideAnimatedActivityIndicatorView() {
        overlayContainerView.hideAnimatedActivityIndicatorView()
    }
}

// Private interface
extension UIView {
    private var activityIndicatorView: UIActivityIndicatorView {
        if #available(iOS 13.0, *) {
            let view: UIActivityIndicatorView =  UIActivityIndicatorView(style: .large)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.tag = activityIndicatorViewTag
            view.alpha = 1.0
            view.color = UIColor.systemBackground
            return view
        } else {
            let view: UIActivityIndicatorView =  UIActivityIndicatorView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.tag = activityIndicatorViewTag
            view.color = UIColor.white
            return view
        }
    }
    
    private var overlayView: UIView {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0.6
        view.tag = overlayViewTag
        return view
    }
    
    private func setActivityIndicatorView() {
        guard !isDisplayingActivityIndicatorOverlay() else { return }
        let overlayView: UIView = self.overlayView
        let activityIndicatorView: UIActivityIndicatorView = self.activityIndicatorView
        
        //add subviews
        overlayView.addSubview(activityIndicatorView)
        addSubview(overlayView)
        
        //add overlay constraints
        overlayView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        overlayView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        //add indicator constraints
        activityIndicatorView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
        
        //animate indicator
        activityIndicatorView.startAnimating()
    }
    
    private func removeActivityIndicatorView() {
        guard let overlayView: UIView = getOverlayView(), let activityIndicator: UIActivityIndicatorView = getActivityIndicatorView() else {
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            overlayView.alpha = 0.0
            activityIndicator.stopAnimating()
        }) { _ in
            activityIndicator.removeFromSuperview()
            overlayView.removeFromSuperview()
        }
    }
    
    private func isDisplayingActivityIndicatorOverlay() -> Bool {
        getActivityIndicatorView() != nil && getOverlayView() != nil
    }
    
    private func getActivityIndicatorView() -> UIActivityIndicatorView? {
        viewWithTag(activityIndicatorViewTag) as? UIActivityIndicatorView
    }
    
    private func getOverlayView() -> UIView? {
        viewWithTag(overlayViewTag)
    }
}
