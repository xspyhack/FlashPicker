//
//  Camera.swift
//  ImagePicker
//
//  Created by k on 6/28/16.
//  Copyright © 2016 egg. All rights reserved.
//

import Foundation
import AVFoundation

class Camera {

    private var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        return session
    }()
    private var cameraDevice: AVCaptureDevice?
    private lazy var imageOutput: AVCaptureStillImageOutput = AVCaptureStillImageOutput()

    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        return previewLayer
    }()
    
    private var bePrepareForCapture = false

    private func configure() {

        if !addCamera(atPosition: position, toCaptureSession: captureSession) {
            print("Failed to add camera input to capture session")
            bePrepareForCapture = false
            return
        }
        if !addOupt(imageOutput, toCaptureSession: captureSession) {
            print("Failed to add image output to capture session")
            bePrepareForCapture = false
            return
        }
        
        bePrepareForCapture = true
    }

    private var position: AVCaptureDevicePosition = .Back

    init() {
        configure()
    }

    func startRunning() {
        if captureSession.running {
            return
        }
        captureSession.startRunning()
    }

    func stopRunning() {
        if captureSession.running {
            captureSession.stopRunning()
        }
    }

    func flip() {
        if position == .Back {
            position = .Front
        } else {
            position = .Back
        }

        removeAllInput(fromCaptureSession: captureSession)

        if addCamera(atPosition: position, toCaptureSession: captureSession) {
            bePrepareForCapture = true
        }
    }

    func capture(completionHandler: (NSData) -> Void) {

        if !captureSession.running || !bePrepareForCapture {
            return
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

            let connection = self.imageOutput.connectionWithMediaType(AVMediaTypeVideo)

            self.imageOutput.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (sampleBuffer, error) in

                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                completionHandler(imageData)
            })
        }
    }

    private func addCamera(atPosition position: AVCaptureDevicePosition, toCaptureSession session: AVCaptureSession) -> Bool {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        var captureDeviceInput: AVCaptureDeviceInput?

        do {
            for device in devices {
                if device.position == position {
                    try captureDeviceInput = AVCaptureDeviceInput(device: device)
                }
            }

            if let captureDeviceInput = captureDeviceInput {
                let success = addInput(captureDeviceInput, toCaptureSession: session)
                cameraDevice = captureDeviceInput.device
                return success
            }
        } catch let error as NSError {
            debugPrint("error configuring camera input: \(error.localizedDescription)")
        }

        return false
    }

    private func addInput(input: AVCaptureInput, toCaptureSession session: AVCaptureSession) -> Bool {
        if session.canAddInput(input) {
            session.addInput(input)
            return true
        } else {
            debugPrint("can't add input: \(input.description)")
            return false
        }
    }

    private func removeInput(input: AVCaptureInput, fromCaptureSession session: AVCaptureSession) {
        session.removeInput(input)
    }

    private func removeAllInput(fromCaptureSession session: AVCaptureSession) {

        for input in session.inputs {
            removeInput(input as! AVCaptureInput, fromCaptureSession: session)
        }
    }

    private func addOupt(output: AVCaptureOutput, toCaptureSession session: AVCaptureSession) -> Bool {

        if session.canAddOutput(output) {
            session.addOutput(output)
            return true
        } else {
            debugPrint("can't add output: \(output.description)")
            return false
        }
    }

}