//
//  ScanViewController.swift
//  myBarcode
//
//  Created by Marc Hein on 28.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import AVFoundation
import UIKit
import CoreData
import HeinHelpers

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, HistoryItemDelegate {
    @IBOutlet var pickerButton: UIBarButtonItem!
    @IBOutlet var historyButton: UIBarButtonItem!
    @IBOutlet var errorIcon: UIImageView!
    @IBOutlet var missingPermissionsView: UIView!
    
    let hapticsGenerator = UINotificationFeedbackGenerator()
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var codeFrameView: UIView?
    var isReadyToScan = false
    var codeResult: String?
    var isSetup = false
    var historyDisabled = false
    
    let imageEN = #imageLiteral(resourceName: "myQRcode_EN")
    let imageDE = #imageLiteral(resourceName: "myQRcode_DE")
    var imagePicker = UIImagePickerController()
    var originalView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(simulator)
            setupDemoScanner()
            checkIfDemoHistoryShouldBeCreated()
        #else
            AVCaptureDevice.authorizationStatus(for: .video) == .authorized  ? setupScanner() : requestAccess()
        #endif
        
        fixNavTabBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetScanner), name: NSNotification.Name(rawValue: "resetView"), object: nil)
        myBarcodeMatomo.track(action: myBarcodeMatomo.basicAction, name: myBarcodeMatomo.scanViewShown)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isSetup {
            resetScanner()
        }
        setHistory()
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
        resetCodeFrame()
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
            print("Failed to get the camera device")
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
                captureMetadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr, .dataMatrix, .aztec, .code128]
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer?.frame = view.bounds
                view.layer.addSublayer(videoPreviewLayer!)
                        
            } catch {
                print(error.localizedDescription)
                return
            }
                    
            codeFrameView = UIView()
                    
            if let codeFrameView = codeFrameView {
                codeFrameView.layer.borderColor = UIColor.green.cgColor
                codeFrameView.layer.borderWidth = 2
                view.addSubview(codeFrameView)
                view.bringSubviewToFront(codeFrameView)
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
    
    fileprivate func resetCodeFrame() {
        codeFrameView?.frame = CGRect.zero
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if !isReadyToScan || metadataObjects.count == 0 {
            return
        }
        
        guard let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            resetCodeFrame()
            print("No code is detected")
            return
        }
        
        isReadyToScan = false
        
        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
        codeFrameView?.frame = barCodeObject!.bounds
        
        guard let contentOfCode = metadataObject.stringValue else {
            return
        }
        var code = Code(content: contentOfCode, category: .scan)

        switch metadataObject.type {
            case .qr:
                code = QRCode(code: code)
            case .code128:
                code = Code128(code: code)
            case .pdf417:
                code = PDF417(code: code)
            case .aztec:
                code = Aztec(code: code)
            default:
                print("Error!")
                return
        }

        finishedScanning(code: code)
    }
    
    func finishedScanning(code: Code, performSegueValue: Bool = true) {
        hapticsGenerator.prepare()
        hapticsGenerator.notificationOccurred(.success)

        codeResult = code.content
        
        let historyItem = code.addToCoreData(save: !historyDisabled)
        
        incrementCodeValue(of: localStoreKeys.codeScanned)
        
        
        if performSegueValue {
            performSegue(withIdentifier: myBarcodeSegues.ResultSegue, sender: historyItem)
        }
        
        myBarcodeMatomo.track(action: myBarcodeMatomo.scanAction, name: myBarcodeMatomo.scanScannedQR, number: NSNumber(value: getCodeValue(from: localStoreKeys.codeScanned)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == myBarcodeSegues.ResultSegue {
            guard let resultNavVC = segue.destination as? UINavigationController, let resultVC = resultNavVC.children[0] as? ScanResultTableViewController else {
                return
            }
            resultVC.historyItem = sender as? HistoryItem
            resultVC.scanVC = self
            
            prepareResultScreen()
        } else if segue.identifier == myBarcodeSegues.ShowHistorySegue {
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
        performSegue(withIdentifier: myBarcodeSegues.ResultSegue, sender: item)
        myBarcodeMatomo.track(action: myBarcodeMatomo.scanAction, name: myBarcodeMatomo.scanHistorySelected)
    }
    
    @IBAction func gallerySelectionButtonTapped() {
        pickPhotoUsingPHPicker()
        myBarcodeMatomo.track(action: myBarcodeMatomo.scanAction, name: myBarcodeMatomo.scanImagePickerOpened)
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
    
    func processingImageComplete(_ codeContent: String) {
        if codeContent.isEmpty {
            hapticsGenerator.prepare()
            hapticsGenerator.notificationOccurred(.error)
            showMessage(title: "no_qr_code_error".localized, message: "no_qr_code_error_description".localized, on: navigationController!)
        } else {
            finishedScanning(code: QRCode(code: Code(content: codeContent, category: .scan)))
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
    
    func setHistory() {
        historyDisabled = UserDefaults.standard.bool(forKey: localStoreKeys.historyDisabled)

        if #available(iOS 16.0, *) {
            historyButton.isHidden = historyDisabled
        } else {
            historyButton.isEnabled = historyDisabled
        }
    }
}
