//
//  CameraViewController.swift
//  ass1
//
//  Created by Inito on 19/08/23.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    //var captureDevice: AVCaptureDevice?
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    var capturedImage:UIImage?
    
    
    let exposureDurations: [CMTime] = [CMTimeMake(value: 1, timescale: 800),
                                       CMTimeMake(value: 1, timescale: 400),
                                       CMTimeMake(value: 1, timescale: 200),
                                       CMTimeMake(value: 1, timescale: 100),
                                       CMTimeMake(value: 1, timescale: 60),
                                       CMTimeMake(value: 1, timescale: 15),
                                       CMTimeMake(value: 1, timescale: 10)
                                       ]
    
    
    var responseData = [AuthResponse]()
    
    @IBOutlet weak var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func CameraButtonPressed(_ sender: UIButton) {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = session.devices.first else {
            print("Failed to get the camera device")
            return
        }

        configureCaptureSession()
        
        clickPhoto {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
                print("Image Saved")
                
            }
           
        }
        Timer(for: 4,captureDevice)
    }
    
    
    func Timer(for timer: Int,_ captureDevice : AVCaptureDevice){
        var remainingSeconds = timer
        Foundation.Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            remainingSeconds -= 1
            self.timerLabel.text = "\(remainingSeconds) seconds"
            
            if remainingSeconds <= 0 {
                timer.invalidate()
                self.timerLabel.text = "Timer done!"
                self.captureImagesForExposureDurations(captureDevice){
                let serialQueue = DispatchQueue(label: "APICAlls")
                    serialQueue.async {
                        let ApiCall = APICapturedPhoto()
                        ApiCall.postMethod { result in
                            switch result {
                            case .success(let authResponse):
                                
                                ApiCall.postImage(self.capturedImage!){
                                    result in
                                    switch result{
                                    case .success:
                                        DispatchQueue.main.async {
                                            self.timerLabel.text  = "Test Done"
                                        }
                                    case .failure:
                                        print("Unable to upload image")
                                    }
                                }
                                print("Authentication successful. Response:", authResponse)
                                
                                
                            case .failure(let error):
                               
                                print("Authentication failed. Error:", error)
                            }
                        }
                            
                        
                        
                      
                        
                    }
                       
                        
                    
                       
                    
                    
                }
            }
        }
        
    }

        
        func captureImagesForExposureDurations(_ captureDevice: AVCaptureDevice, completion: @escaping () -> Void) {
            let serialQueue = DispatchQueue(label: "com.example.captureQueue")
            
            func captureNextImage(_ index: Int) {
                guard index < exposureDurations.count else {
                    completion() // All exposures are done, call the completion handler
                    return
                }
                
                let currentCapture = exposureDurations[index]
                
                serialQueue.sync {
                    do {
                        try captureDevice.lockForConfiguration()
                        captureDevice.setExposureModeCustom(duration: currentCapture, iso: 800) { _ in
                            DispatchQueue.main.async {
                                self.timerLabel.text = "Capturing Image on Exposure: \(currentCapture.value)/\(currentCapture.timescale)"
                            }
                            captureDevice.unlockForConfiguration()
                            self.clickPhoto { (image, error) in
                                guard let image = image else {
                                    print(error ?? "Image capture error")
                                    return
                                }
                                
                                PHPhotoLibrary.shared().performChanges {
                                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                                    if index == self.exposureDurations.count/2{
                                        print("image Saved")
                                        self.capturedImage = image
                                    }
                                    print("Image Saved")
                                } completionHandler: { success, error in
                                    if success {
                                        captureNextImage(index + 1) // Move to the next iteration
                                    } else {
                                        print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            
            // Start the process by capturing the first image
            captureNextImage(0)
        }


    
    
    func configureCaptureSession(){
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = session.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        self.captureSession = AVCaptureSession()
        guard let captureSession = self.captureSession else {  print("Capture Session is missing")
            return
        }
        
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            
            try captureDevice.lockForConfiguration()
            captureDevice.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: 400, completionHandler: nil)
            
            captureDevice.unlockForConfiguration()
            
            
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            
            captureSession.startRunning()
            
            
            
        }catch{
            print("Error configuring capture Session\(error)")
        }
        
    }
    
    func clickPhoto(completion: @escaping (UIImage?, Error?) -> Void){
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, nil); return }
        
        let settings = AVCapturePhotoSettings()
        
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
        
    }
}


extension CameraViewController:AVCapturePhotoCaptureDelegate{
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                        resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
            
        else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
            let image = UIImage(data: data) {
            
            self.photoCaptureCompletionBlock?(image, nil)
        }
            
        else {
            self.photoCaptureCompletionBlock?(nil, error)
        }
    }
}

