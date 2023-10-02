//
//  CameraView.swift
//  HandAndBodyTracking
//
//  Created by Michele Manniello on 01/09/23.
//

import UIKit
import AVFoundation
import SwiftUI

class CameraView: UIView {
    
    private var customLayer = CAShapeLayer()
    private var pathPoint = UIBezierPath()
    
     var preivewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    
    override func layoutSublayers(of layer: CALayer) {
        if layer == preivewLayer {
            customLayer.frame = layer.bounds
        }
    }
    
    func setUp() {
        preivewLayer.addSublayer(customLayer)
    }
    
    func drawPath(points: [CGPoint], move: [Bool], color: UIColor) {
        
        pathPoint.removeAllPoints()
//        Draw path
        guard points.count == move.count else { return }
        if points.isEmpty {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            customLayer.path = pathPoint.cgPath
            CATransaction.commit()
        }
        
        guard let first = points.first else { return }
        pathPoint.move(to: first)
        
        for i in 0...points.count - 1 {
            if move[i] {
                pathPoint.move(to: points[i])
                pathPoint.addArc(withCenter: points[i], radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            } else {
                pathPoint.addLine(to: points[i])
                pathPoint.addArc(withCenter: points[i], radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
                pathPoint.move(to: points[i])
            }
           
        }
        
        
        customLayer.fillColor = color.cgColor
        customLayer.strokeColor = UIColor.red.cgColor
        CATransaction.begin()
        customLayer.path = pathPoint.cgPath
        CATransaction.setDisableActions(false)
        CATransaction.commit()
    }
    
}
