//
//  ScanViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 28.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var isReadyToScan = false
    var codeResult: String?
    var isSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAccess()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetScanner), name:NSNotification.Name(rawValue: "resetView"), object: nil)
    }
    
    func requestAccess() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                   setupScanner()
                   resetScanner()
       } else {
           AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
               if granted {
                   self.setupScanner()
                   self.resetScanner()
               } else {
                   print("restricted usage")
                DispatchQueue.main.async {
                    self.setRequestView()
                }
               }
           })
       }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isSetup {
            requestAccess()
        }
        resetScanner()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
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
                    codeResult = contentOfCode
                    incrementCodeValue(of: localStoreKeys.codeScanned)
                    performSegue(withIdentifier: "resultSegue", sender: self)
                    return
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultSegue" {
            guard let resultVC = segue.destination as? ScanResultViewController else { return }
            resultVC.codeResult = codeResult
            captureSession.stopRunning()
            isReadyToScan = false;
        }
    }
}
