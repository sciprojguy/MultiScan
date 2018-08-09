//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import Toast_Swift

public extension Int {
    
    public var seconds: DispatchTimeInterval {
        return DispatchTimeInterval.seconds(self)
    }
    
    public var second: DispatchTimeInterval {
        return seconds
    }
    
    public var milliseconds: DispatchTimeInterval {
        return DispatchTimeInterval.milliseconds(self)
    }
    
    public var millisecond: DispatchTimeInterval {
        return milliseconds
    }
    
}

public extension DispatchTimeInterval {
    public var fromNow: DispatchTime {
        return DispatchTime.now() + self
    }
}

class BarcodeScannerController: UIViewController {

    @IBOutlet weak var roiView: BarCodeFocusView!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var helpOverlay: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    var scanDelegate:ScanValueDelegate? = nil

    var captureSession = AVCaptureSession()
    var ignoreObjects:Bool = false
    var scannedValue:String = ""
    var barCodeType:String = ""
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

    @IBAction func showHelpOverlay(_ sender: Any) {
        self.view.bringSubview(toFront: self.helpOverlay)
        self.helpOverlay.isHidden = false
    }

    func rearFacingCamera() -> AVCaptureDevice? {
    
        var rearCamera : AVCaptureDevice?

        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                rearCamera = device
            }
        }
        
        return rearCamera
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func dontRotate() {
    }
    
    func convertRectOfInterest(rect: CGRect) -> CGRect {
        let screenRect = self.view.frame
        let screenWidth = screenRect.width
        let screenHeight = screenRect.height
        let newX = 1 / (screenWidth / rect.minX)
        let newY = 1 / (screenHeight / rect.minY)
        let newWidth = 1 / (screenWidth / rect.width)
        let newHeight = 1 / (screenHeight / rect.height)
        return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
    }
    
    override func viewDidLoad() {
    
        super.viewDidLoad()

        self.helpOverlay.isHidden = true
        let gestureRecog = UITapGestureRecognizer(target: self, action: #selector(helpOverlayTapped(sender:)))
        self.helpOverlay.addGestureRecognizer(gestureRecog)

        guard let captureDevice = self.rearFacingCamera()
        else {
            return
        }

 
        captureSession = AVCaptureSession()
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.connection?.videoOrientation = .portrait
            
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)

            // Start video capture.
            captureSession.startRunning()
            captureMetadataOutput.rectOfInterest = videoPreviewLayer!.metadataOutputRectConverted(fromLayerRect: self.roiView.frame)

            self.roiView.isScanning = true
            
            // Move the message label and top bar to the front
            view.addSubview(roiView)
            view.bringSubview(toFront: roiView)
            
            view.bringSubview(toFront: self.resultView)
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(togglePause))
            self.roiView.addGestureRecognizer(tapRecognizer)
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            //actually, display a
            return
        }
    }

    @objc func togglePause() {
        let currentlyScanning = self.roiView.isScanning
        if currentlyScanning {
            self.stopScanning()
        }
        else {
            self.startScanning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func helpOverlayTapped(sender:Any?) {
        self.helpOverlay.isHidden = true
    }

    func startScanning() {
        self.ignoreObjects = false
        self.roiView.isScanning = true
    }
    
    func stopScanning() {
        self.ignoreObjects = true
        self.roiView.isScanning = false
    }

    @IBAction func acceptValue(_ sender: Any) {
        
        _ = self.scanDelegate?.setValueToScannedBarcode(value: self.scannedValue, type: self.barCodeType)
        self.scannedValue = ""
        self.barCodeType = ""
        resultLabel.text = self.scannedValue
        self.hideButtons()
        self.view.makeToast("Scanned value accepted", duration: 2.0, position: .center)
        DispatchQueue.main.asyncAfter(deadline: 2.seconds.fromNow) {
            self.startScanning()
        }
    }
    
    @IBAction func rejectValue(_ sender: Any) {
        self.scannedValue = ""
        resultLabel.text = self.scannedValue
        self.hideButtons()
        self.view.makeToast("Scanned value rejected", duration: 2.0, position: .center)
        DispatchQueue.main.asyncAfter(deadline: 2.seconds.fromNow) {
            self.startScanning()
        }
    }
    
    @IBAction func done(_ sender: Any) {
        self.stopScanning()
        self.dismiss(animated: true, completion: nil)
    }
    
    func hideButtons() {
        UIView.animate(withDuration: 0.15) {
            self.acceptButton.isHidden = true
            self.rejectButton.isHidden = true
        }
    }
    
    func showButtons() {
        UIView.animate(withDuration: 0.15) {
            self.acceptButton.isHidden = false
            self.rejectButton.isHidden = false
        }
    }
}

extension BarcodeScannerController:  AVCaptureMetadataOutputObjectsDelegate {
    // MARK: - Helper methods

    func confirmValue(value: String, type: String) {
        if presentedViewController != nil {
            return
        }
        
        self.scannedValue = value
        self.barCodeType = type.components(separatedBy: ".").last ?? ""
        self.stopScanning()
        self.showButtons()
        self.resultLabel.text = self.scannedValue
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    
        if ignoreObjects {
            return
        }
        
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        stopScanning()
        
        // Get the metadata object.
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
        else {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
        qrCodeFrameView?.frame = barCodeObject!.bounds
        
        if metadataObj.stringValue != nil {
            let typeNodes = metadataObj.type.rawValue.split(separator: ".")
            let type = String(typeNodes.last!)
            
            //todo: remove action sheet and assign value to confirm view
            //self.
            
            confirmValue(value: metadataObj.stringValue!, type: metadataObj.type.rawValue)
        }
    }    
}

