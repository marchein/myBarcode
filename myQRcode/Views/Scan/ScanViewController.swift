//
//  ScanViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 28.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, HistoryItemDelegate {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var isReadyToScan = false
    var codeResult: String?
    var isSetup = false
    @IBOutlet weak var historyButton: UIBarButtonItem!
    let imageEN = #imageLiteral(resourceName: "myQRcode_EN")
    let imageDE = #imageLiteral(resourceName: "myQRcode_DE")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAccess()
        
        if #available(iOS 13.0,*)  {
            historyButton.image = UIImage(systemName: "clock")
        }
        
        if isSimulator() {
            self.setupDemoHistory()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetScanner), name:NSNotification.Name(rawValue: "resetView"), object: nil)
    }
    
    func requestAccess() {
        if isSimulator() {
            self.setupDemoScanner()
        } else {
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                self.setupScanner()
            } else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        self.setupScanner()
                    } else {
                        print("restricted usage")
                        DispatchQueue.main.async {
                            self.setRequestView()
                        }
                    }
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isSetup {
            self.requestAccess()
        }
        self.resetScanner()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        if let videoPreviewLayer = self.videoPreviewLayer {
            videoPreviewLayer.frame = self.view.bounds
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.videoPreviewLayer?.connection  {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            if previewLayerConnection.isVideoOrientationSupported {
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
    }
    
    
    @objc func resetScanner() {
        resetQrCodeFrame()
        isReadyToScan = true
        captureSession.startRunning()
    }
    
    func setupDemoScanner() {
        let lang = Bundle.main.preferredLocalizations.first?.prefix(2) ?? "en"
        let imageView = UIImageView(image: lang == "en" ? imageEN : imageDE)
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        imageView.contentMode = .scaleAspectFill
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
        
        if tappedImage == imageDE {
            finishedScanning(content: "Hallo und herzlich willkommen zu myQRcode")
        } else {
            finishedScanning(content: "Hello and welcome to myQRcode")
        }
    }
    
    func setupScanner() {
        let deviceDiscoverySession = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            isSetup = true
            self.resetScanner()
        } catch {
            print(error)
            return
        }
    }
    
    func setRequestView() {
        performSegue(withIdentifier: "errorSegue", sender: self)
    }
    
    fileprivate func resetQrCodeFrame() {
        qrCodeFrameView?.frame = CGRect.zero
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            resetQrCodeFrame()
            print("No QR code is detected")
            return
        }
        
        if isReadyToScan {
            isReadyToScan = false
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObject.ObjectType.qr {
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                
                if let contentOfCode = metadataObj.stringValue {
                    self.finishedScanning(content: contentOfCode)
                }
            }
        }
    }
    
    func finishedScanning(content: String, performSegueValue: Bool = true) {
        codeResult = content
        let qrCode = QRCode(content: content, category: .scan)
        incrementCodeValue(of: localStoreKeys.codeScanned)
        if performSegueValue {
            performSegue(withIdentifier: "resultSegue", sender: qrCode.coreDataObject)
        } else {
            _ = qrCode.coreDataObject
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultSegue" {
            guard let resultNavVC = segue.destination as? UINavigationController, let resultVC = resultNavVC.children[0] as? ScanResultTableViewController else {
                return
            }
            resultVC.historyItem = sender as? HistoryItem
            resultVC.scanVC = self
            
            self.prepareResultScreen()
        } else if segue.identifier == "showHistory" {
            guard let historyNavVC = segue.destination as? UINavigationController, let historyVC = historyNavVC.children[0] as? HistoryTableViewController else {
                return
            }
            historyVC.delegate = self
            historyVC.category = .scan
        }
    }
    
    func prepareResultScreen() {
        captureSession.stopRunning()
        isReadyToScan = false;
    }
    
    func userSelectedHistoryItem(item: HistoryItem) {
        self.prepareResultScreen()
        self.performSegue(withIdentifier: "resultSegue", sender: item)
    }
}
