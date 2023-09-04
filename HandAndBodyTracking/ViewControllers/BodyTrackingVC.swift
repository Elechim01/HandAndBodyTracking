//
//  BodyTrackingVC.swift
//  HandAndBodyTracking
//
//  Created by Michele Manniello on 02/09/23.
//

import UIKit
import SwiftUI
import Vision
import PreviewUIKit

class BodyTrackingVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    private var selectedImage: UIImage?
    
    private lazy var imagePicker: UIImagePickerController = {
       let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        return imagePicker
    }()
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Body Tracking"
        title.textColor = .white
        title.font = .systemFont(ofSize: 25)
        return title
    }()
    
    private lazy var selectedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Seleziona immagine", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(onTapSelectPhoto), for: .touchUpInside)
        return button
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = selectedImage
        return imageView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubView()
        addConstraints()
    }
    
    private func addSubView() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(selectedButton)
        self.view.addSubview(imageView)
    }
    
    private func addConstraints() {
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            selectedButton.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor,constant: 10),
            selectedButton.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 400),
            imageView.heightAnchor.constraint(equalToConstant: 400),
            
        ])
    }
    
    @objc
    func onTapSelectPhoto() {
        let alert = UIAlertController(title: "SelezionaImmagine", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {  [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Album", style: .default, handler: { [weak self]  _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Annulla", style: .cancel))
        
        present(alert,animated: true,completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        imageView.image = image
        selectedImage = image
        detectBody(image: image)
        dismiss(animated: true)
     
    }
    
   private func detectBody(image: UIImage) {
//        get CGImage on Witch to perform requsts
        guard let cgImage = image.cgImage else { return }
        
//        Create a new image-request
        let requestHandle = VNImageRequestHandler(cgImage: cgImage)
        
//        create a new request to recognize a human body pose
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
        
        do {
            try requestHandle.perform([request])
        } catch  {
            print("Unable to perform the request \(error)")
        }
    }
    
    
   private  func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observation = request.results as? [VNHumanBodyPoseObservation] else { return }
        
//        Process each observation to find the recognized body pose point
        observation.forEach { processObservation($0) }
        
    }
    
    private func processObservation(_ observation: VNHumanBodyPoseObservation) {
        guard let recognizedPoints = try? observation.recognizedPoints(.torso) else { return }
        
//        Torso Joint names in a clockwise ordering
        let tosoJointsNames: [VNHumanBodyPoseObservation.JointName] = [
            .neck,
            .rightShoulder,
            .rightHip,
            .root,
            .leftHip,
            .leftShoulder
        ]
        
//        Retruce the CGPoints containing the normalized X and Y cordinates
        let imagePoints: [CGPoint] = tosoJointsNames.compactMap {
            guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
            return VNImagePointForNormalizedPoint(point.location,
                                                  400,
                                                  400)
        }
        
        guard let selectedImage  else { return }
     
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        imagePoints.forEach {
            path.move(to: $0)
            path.addArc(withCenter: $0, radius: 4, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        
        layer.fillColor = UIColor.green.cgColor
        
        CATransaction.begin()
        layer.path = path.cgPath
        CATransaction.setDisableActions(false)
        CATransaction.commit()
        
        
        imageView.image = selectedImage
        imageView.layer.addSublayer(layer)
       
    }
    
}

struct BodyTrackingVCProvider_Preview: PreviewProvider  {
    static var previews: some View {
        PreviewViewController<BodyTrackingVC>()
            .ignoresSafeArea()
    }
}
