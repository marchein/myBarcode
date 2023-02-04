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
    @IBOutlet weak var pickerButton: UIBarButtonItem!
    @IBOutlet weak var historyButton: UIBarButtonItem!
    @IBOutlet weak var errorIcon: UIImageView!
    @IBOutlet weak var missingPermissionsView: UIView!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var isReadyToScan = false
    var codeResult: String?
    var isSetup = false
    
    let imageEN = #imageLiteral(resourceName: "myQRcode_EN")
    let imageDE = #imageLiteral(resourceName: "myQRcode_DE")
    var imagePicker = UIImagePickerController()
    var originalView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0,*)  {
            self.pickerButton.image = UIImage(systemName: "photo.on.rectangle")
            self.historyButton.image = UIImage(systemName: "clock")
            self.errorIcon.image = UIImage(systemName: "exclamationmark.circle")
        }
        
        if !isSimulator() && AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            self.setupScanner()
            // self.setupDemoHistory()
        } else {
            self.requestAccess()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetScanner), name:NSNotification.Name(rawValue: "resetView"), object: nil)
    }
    
    func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            DispatchQueue.main.async {
                granted ? self.setupScanner() : self.setRequestView()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isSetup {
            self.resetScanner()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.captureSession.stopRunning()
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
        self.resetQrCodeFrame()
        self.isReadyToScan = true
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func setupScanner() {
        if !isSimulator() {
            #if targetEnvironment(macCatalyst)
            let deviceDiscoverySession = AVCaptureDevice.default(for: .video)
            #else
            let deviceDiscoverySession = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            #endif
            
            
            guard let captureDevice = deviceDiscoverySession else {
                print("Failed to get the camera device")
                return
            }
            
            do {
                if !isSetup {
                    if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                        for input in inputs {
                            captureSession.removeInput(input)
                        }
                    }
                    
                    if captureSession.inputs.isEmpty {
                        let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
                        self.captureSession.addInput(deviceInput)
                    }
                    
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
                }
            } catch {
                print(error)
                return
            }
        } else {
            self.setupDemoScanner()
        }
    }
    
    func setRequestView() {
        self.originalView = self.view
        self.view = self.missingPermissionsView
    }
    
    func resetToOriginalView() {
        self.view = self.originalView
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
            performSegue(withIdentifier: myQRcodeSegues.ResultSegue, sender: qrCode.coreDataObject)
        } else {
            _ = qrCode.coreDataObject
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == myQRcodeSegues.ResultSegue {
            guard let resultNavVC = segue.destination as? UINavigationController, let resultVC = resultNavVC.children[0] as? ScanResultTableViewController else {
                return
            }
            resultVC.historyItem = sender as? HistoryItem
            resultVC.scanVC = self
            
            self.prepareResultScreen()
        } else if segue.identifier == myQRcodeSegues.ShowHistorySegue {
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
        self.performSegue(withIdentifier: myQRcodeSegues.ResultSegue, sender: item)
    }
}
