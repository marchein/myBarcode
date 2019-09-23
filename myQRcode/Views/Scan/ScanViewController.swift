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
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScanner()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetQrCodeFrame()
        isReadyToScan = true
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    func setupScanner() {
        let deviceDiscoverySession = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)

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
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            view.bringSubviewToFront(notificationView)
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
            captureSession.startRunning()
        } catch {
            print(error)
            return
        }
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
                    resultLabel.text = contentOfCode
                    //performSegue(withIdentifier: "resultSegue", sender: self)
                    return
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultSegue" {
            guard let resultVC = segue.destination as? ScanResultViewController else { return }
            resultVC.codeResult = codeResult
        }
    }
}
