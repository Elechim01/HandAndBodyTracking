//
//  HandTrackingVC.swift
//  HandAndBodyTracking
//
//  Created by Michele Manniello on 01/09/23.
//

import UIKit
import SwiftUI
import Vision
import AVFoundation
import PreviewUIKit

class HandTrackingVC: UIViewController {
    
    var cameraSession: AVCaptureSession? = nil
    let handRequest = VNDetectHumanHandPoseRequest()
    let video = DispatchQueue(label: "Video",qos: .userInteractive)
    
    var points: [CGPoint] = []
    var moves: [Bool] = []
    
     lazy var cameraView: CameraView = {
      let camera = CameraView()
         camera.translatesAutoresizingMaskIntoConstraints = false
        return camera
    }()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .large
        indicator.color = .red
        indicator.startAnimating()
        indicator.autoresizingMask = [
                .flexibleLeftMargin, .flexibleRightMargin,
                .flexibleTopMargin, .flexibleBottomMargin
            ]
        return indicator
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tocca lo schermo per uscire"
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setUptConstraint()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapOnView))
        gesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(gesture)
    }
    
    func addSubViews() {
        self.view.addSubview(cameraView)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(loadingView)
    }
    
    func setUptConstraint() {
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: 60),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task(priority: .high) {
            
            do{
                if cameraSession == nil {
//                    reqeustPersion()
                    try createAVSession()
                    cameraView.preivewLayer.videoGravity = .resizeAspectFill
                    cameraView.preivewLayer.session = cameraSession
                }
                cameraSession?.startRunning()
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func createAVSession() throws {
        guard let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) else {  throw customError.impossibleToCreateDevice }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            throw customError.impossibleToCreateDevice }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high
        guard session.canAddInput(input) else { throw customError.impossibleToCreateDevice }
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        guard session.canAddOutput(output) else { throw customError.impossibleToCreateDevice}
        session.addOutput(output)
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        output.setSampleBufferDelegate(self, queue: video)
        
        session.commitConfiguration()
        cameraSession = session
    }
    
    func reqeustPersion() {
       let result = AVCaptureDevice.authorizationStatus(for: .video)
        switch result {
        case .notDetermined:
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            print("Denied")
        case .authorized:
            print("Success")
        @unknown default:
            print("Error")
        }
        
    }
    
    
    
    @objc
    func onTapOnView() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

struct HandTrackingVCPreview_Provider: PreviewProvider {
    static var previews: some View {
        PreviewViewController<HandTrackingVC>()
            .ignoresSafeArea()
    }
}

enum customError: Error {
    case impossibleToCreateDevice
    case impossibleDetectHand
}
