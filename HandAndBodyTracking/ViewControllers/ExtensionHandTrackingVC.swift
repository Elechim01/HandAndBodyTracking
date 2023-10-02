//
//  ExtensionHandTrackingVC.swift
//  HandAndBodyTracking
//
//  Created by Michele Manniello on 02/09/23.
//

import Foundation
import Vision
import AVFoundation

extension HandTrackingVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       
        defer {
//            Call function to draw
            Task {
                self.loadingView.isHidden = true
                self.cameraView.drawPath(points: self.points, move: self.moves, color: .orange)
            }
        }
        
        do {
            let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
            points.removeAll()
            moves.removeAll()
            try handler.perform([handRequest])
           
            guard let observation = handRequest.results?.first else {
                self.cameraView.drawPath(points: [], move: [], color: .clear)
                return
            }
//     MARK: logic to draw
            
//       pollice
            let thump = try observation.recognizedPoints(.thumb)
            let thumpPositions = generatePosition(arrayInput: thump, keys: [.thumbTip,.thumbIP,.thumbMP,.thumbCMC])
            
            for position in thumpPositions {
                guard position.confidence > 0.3 else { return }
                points.append(convertPoints(inputPotin: position))
                moves.append(false)
            }
        
//          centro della mano
            let center = try observation.recognizedPoint(.wrist)
            points.append(convertPoints(inputPotin: center))
            moves.append(false)
            
//            Indice
            let index = try observation.recognizedPoints(.indexFinger)
            addPosition(indexPositions: generatePosition(arrayInput: index, keys: [.indexTip,.indexDIP,.indexPIP, .indexMCP]))
            
            points.append(convertPoints(inputPotin: center))
            moves.append(false)
            
//             Medio
            let medium = try observation.recognizedPoints(.middleFinger)
            addPosition(indexPositions: generatePosition(arrayInput: medium,
                                                         keys: [.middleTip,.middleDIP,.middlePIP,.middleMCP])
            )
            points.append(convertPoints(inputPotin: center))
            moves.append(false)
            
//            anulare
            let ring = try observation.recognizedPoints(.ringFinger)
            addPosition(indexPositions: generatePosition(arrayInput: ring,
                                                         keys: [.ringTip,.ringDIP,.ringPIP,.ringMCP]))
            points.append(convertPoints(inputPotin: center))
            moves.append(false)
            
//            mignolo
            let little = try observation.recognizedPoints(.littleFinger)
            addPosition(indexPositions: generatePosition(arrayInput: little,
                                                         keys: [.littleTip,.littleDIP,.littlePIP,.littleMCP]))
            points.append(convertPoints(inputPotin: center))
            moves.append(false)
            
            
            if let pointThump = thump[.thumbTip], let pointIndex = index[.indexTip], let pointMedium = medium[.middleTip], let pointRing = ring[.ringTip], let pointLittle = little[.littleTip] {
    
                self.checkContactTwoFinger(pointNear: pointThump, pointAway: pointIndex, typeFinger: .thumIndex, noContact: { [weak self] in
                    guard let self = self else { return }
                    self.checkContactTwoFinger(pointNear: pointThump, pointAway: pointMedium ,typeFinger: .thumbMiddle,noContact: { [weak self] in
                        guard let self = self else { return }
                        self.checkContactTwoFinger(pointNear: pointThump, pointAway: pointRing, typeFinger: .thumbRing, noContact: { [weak self] in
                            guard let self = self else { return }
                                self.checkContactTwoFinger(pointNear: pointThump, pointAway: pointLittle, typeFinger: .thumbLittle, noContact: nil)
                        })
                    })
                })
            }
            
            print("end")
        
            
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    private func checkContactTwoFinger(pointNear: VNRecognizedPoint, pointAway: VNRecognizedPoint, typeFinger: FingerCombination, noContact: (() -> ())?) {
        
        guard pointNear.confidence > 0.3 && pointAway.confidence > 0.3  else { return }
        
        let cgPointNear = convertPoints(inputPotin: pointNear)
        let cgPointAway = convertPoints(inputPotin: pointAway)
        
        print("cgPoint.x \(cgPointNear.x), cgPoint1.x \(cgPointAway.x)")
        
        let distance = hypot(cgPointNear.x - cgPointAway.x, cgPointNear.y - cgPointAway.y)
        
        if distance < 40 {
            print("🤖 Contatto!!!!!! \(typeFinger.rowValue)")
            contatto = true
            Task{
                self.contattoLabel.text = typeFinger.rowValue
                self.contattoLabel.isHidden = false
            }
        } else {
            if noContact == nil {
                Task {
                    if contattoLabel.isHidden == false{
                        self.contattoLabel.isHidden = true
                    }
                }
            } else {
                noContact!()
            }
        }
    }
    
    private func addPosition(indexPositions: [VNRecognizedPoint]) {
         for  (index, indexPosition) in indexPositions.enumerated() {
             guard indexPosition.confidence > 0.3 else { return }
             if index == 0 {
                 moves.append(true)
             } else {
                 moves.append(false)
             }
             points.append(convertPoints(inputPotin: indexPosition))
         }
     }
     
    private func generatePosition(arrayInput: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint], keys:[VNHumanHandPoseObservation.JointName]) -> [VNRecognizedPoint] {
         
         var resut: [VNRecognizedPoint] = []
         
         keys.forEach { searchKey in
             arrayInput.forEach { key,value in
                 if key == searchKey {
                     resut.append(value)
                 }
             }
         }
         return resut
     }
     
    private func convertPoints(inputPotin: VNRecognizedPoint ) -> CGPoint {
         
         let point = CGPoint(x: inputPotin.location.x, y: 1 - inputPotin.location.y)
        return self.cameraView.preivewLayer.layerPointConverted(fromCaptureDevicePoint: point)
     }
}
