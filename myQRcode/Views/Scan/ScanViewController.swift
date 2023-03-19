//
//  ScanViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 28.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import AVFoundation
import UIKit
import HeinHelpers

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, HistoryItemDelegate {
    @IBOutlet var pickerButton: UIBarButtonItem!
    @IBOutlet var historyButton: UIBarButtonItem!
    @IBOutlet var errorIcon: UIImageView!
    @IBOutlet var missingPermissionsView: UIView!
    
    let hapticsGenerator = UINotificationFeedbackGenerator()
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
        
        if #available(iOS 13.0,*) {
            self.pickerButton.image = UIImage(systemName: "photo.on.rectangle")
            self.historyButton.image = UIImage(systemName: "clock")
            self.errorIcon.image = UIImage(systemName: "exclamationmark.circle")
        }
        
        if isSimulator() {
            setupDemoScanner()
        } else {
            AVCaptureDevice.authorizationStatus(for: .video) == .authorized  ? setupScanner() : requestAccess()
        }
        
        fixNavTabBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetScanner), name: NSNotification.Name(rawValue: "resetView"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isSetup {
            resetScanner()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            DispatchQueue.main.async {
                granted ? self.setupScanner() : self.setRequestView()
            }
        })
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        if let videoPreviewLayer = videoPreviewLayer {
            videoPreviewLayer.frame = view.bounds
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection = videoPreviewLayer?.connection {
            let currentDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection: AVCaptureConnection = connection
            if previewLayerConnection.isVideoOrientationSupported {
                switch orientation {
                    case .portrait:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    case .landscapeRight:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    case .landscapeLeft:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    case .portraitUpsideDown:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    default:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                }
            }
        }
    }
    
    @objc func resetScanner() {
        resetQrCodeFrame()
        isReadyToScan = true
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func setupScanner() {
        #if targetEnvironment(macCatalyst)
        let deviceDiscoverySession = AVCaptureDevice.default(for: .video)
        #else
        let deviceDiscoverySession = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        #endif
            
        guard let captureDevice = deviceDiscoverySession else {
            HeinHelpers.logMessage("Failed to get the camera device")
            return
        }
            
        if !isSetup {
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
                    
            do {
                if captureSession.inputs.isEmpty {
                    let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
                    captureSession.addInput(deviceInput)
                }
                    
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutput)
                    
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                    
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer?.frame = view.bounds
                view.layer.addSublayer(videoPreviewLayer!)
                        
            } catch {
                HeinHelpers.logMessage(error.localizedDescription)
                return
            }
                    
            qrCodeFrameView = UIView()
                    
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            isSetup = true
            resetScanner()
        }
    }
    
    func setRequestView() {
        originalView = view
        view = missingPermissionsView
    }
    
    func resetToOriginalView() {
        view = originalView
    }
    
    fileprivate func resetQrCodeFrame() {
        qrCodeFrameView?.frame = CGRect.zero
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            resetQrCodeFrame()
            hapticsGenerator.prepare()
            hapticsGenerator.notificationOccurred(.error)
            HeinHelpers.logMessage("No QR-code is detected")
            return
        }
        
        if isReadyToScan {
            isReadyToScan = false
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObject.ObjectType.qr {
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                
                if let contentOfCode = metadataObj.stringValue {
                    finishedScanning(content: contentOfCode)
                }
            }
        }
    }
    
    func finishedScanning(content: String, performSegueValue: Bool = true) {
        hapticsGenerator.prepare()
        hapticsGenerator.notificationOccurred(.success)

        codeResult = content
        let qrCode = QRCode(content: content, category: .scan)
        let historyItem = qrCode.addToCoreData()
        
        incrementCodeValue(of: localStoreKeys.codeScanned)
        
        if performSegueValue {
            performSegue(withIdentifier: myQRcodeSegues.ResultSegue, sender: historyItem)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == myQRcodeSegues.ResultSegue {
            guard let resultNavVC = segue.destination as? UINavigationController, let resultVC = resultNavVC.children[0] as? ScanResultTableViewController else {
                return
            }
            resultVC.historyItem = sender as? HistoryItem
            resultVC.scanVC = self
            
            prepareResultScreen()
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
        isReadyToScan = false
    }
    
    func userSelectedHistoryItem(item: HistoryItem) {
        prepareResultScreen()
        performSegue(withIdentifier: myQRcodeSegues.ResultSegue, sender: item)
    }
    
    @IBAction func gallerySelectionButtonTapped() {
        if #available(iOS 14.0, *) {
            pickPhotoUsingPHPicker()
        } else {
            pickImageUsingUIImagePicker()
        }
    }
    
    func processSelectedImage(_ image: UIImage) -> String {
        guard
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
            let ciImage = CIImage(image: image),
            let features = detector.features(in: ciImage) as? [CIQRCodeFeature]
        else {
            hapticsGenerator.prepare()
            hapticsGenerator.notificationOccurred(.error)
            fatalError("Something went wrong in the image picker code")
        }
        
        var qrCodeResult = ""
        for feature in features {
            if let message = feature.messageString {
                qrCodeResult += message
            }
        }
        
        return qrCodeResult
    }
    
    func processingImageComplete(_ qrCodeContent: String) {
        if qrCodeContent.isEmpty {
            hapticsGenerator.prepare()
            hapticsGenerator.notificationOccurred(.error)
            showMessage(title: "no_qr_code_error".localized, message: "no_qr_code_error_description".localized, on: navigationController!)
        } else {
            finishedScanning(content: qrCodeContent)
        }
    }
    
    func fixNavTabBar() {
        // This is needed so the navbar and tabbar stay over the contents of scan view
        if #available(iOS 15, macCatalyst 15.0, *) {
            let navbarAppearance = UINavigationBarAppearance()
            navbarAppearance.configureWithDefaultBackground()
            navigationController?.navigationBar.standardAppearance = navbarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
                
            let tabbarAppearance = UITabBarAppearance()
            tabbarAppearance.configureWithDefaultBackground()
            tabBarController?.tabBar.standardAppearance = tabbarAppearance
            tabBarController?.tabBar.scrollEdgeAppearance = tabbarAppearance
        }
    }
}
