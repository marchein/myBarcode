//
//  ScanViewController+Demo.swift
//  myQRcode
//
//  Created by Marc Hein on 03.02.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

extension ScanViewController {
    func setupDemoScanner() {
        let lang = Bundle.main.preferredLocalizations.first?.prefix(2) ?? "en"
        let imageView = UIImageView(image: lang == "en" ? imageEN : imageDE)
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        imageView.contentMode = .scaleAspectFill
        view.sendSubviewToBack(imageView)
        view.addSubview(imageView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupDemoHistory() {
        let demoStrings = ["https://marc-hein.de", "myQRcode", "BLÅHAJ", "Whatever", "0000 is the best pin"]
        for string in demoStrings {
            self.finishedScanning(content: string, performSegueValue: false)
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImageView = tapGestureRecognizer.view as! UIImageView
        let tappedImage = tappedImageView.image!
        
        finishedScanning(content: tappedImage == imageDE ?"Hallo und herzlich willkommen zu myQRcode" : "Hello and welcome to myQRcode")
    }
}
