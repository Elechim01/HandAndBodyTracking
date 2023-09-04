//
//  ViewController.swift
//  HandAndBodyTracking
//
//  Created by Michele Manniello on 01/09/23.
//

import UIKit
import PreviewUIKit
import SwiftUI

class ViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tracking"
        label.textColor = .white
        return label
    }()
    
    private lazy var bodyImage: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "body"), for: .normal)
        button.imageView?.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(onTapBodyTracking), for: .touchUpInside)
        return button
    }()
    
    private lazy var bodyTitle: UILabel = {
        let descriptionBody = UILabel()
        descriptionBody.translatesAutoresizingMaskIntoConstraints = false
        descriptionBody.text = "Body tracking"
        descriptionBody.textColor = .white
        descriptionBody.font = .boldSystemFont(ofSize: 20)
       return descriptionBody
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var handImage: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "hand"), for: .normal)
        button.imageView?.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        button.layer.borderColor = UIColor.green.cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(onTapHandTracking), for: .touchUpInside)
        return button
    }()
    
    private lazy var handTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Hand Tracking"
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.clipsToBounds = false
        
        // Do any additional setup after loading the view.
        addSubView()
        addContraints()
    }
    
    func addSubView() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(bodyImage)
        scrollView.addSubview(bodyTitle)
        scrollView.addSubview(handImage)
        scrollView.addSubview(handTitle)
    }
    
    func addContraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            bodyImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 23),
            bodyImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            bodyImage.widthAnchor.constraint(equalToConstant: 300),
            bodyImage.heightAnchor.constraint(equalToConstant: 300),
            bodyTitle.topAnchor.constraint(equalTo: bodyImage.bottomAnchor,constant: 20),
            bodyTitle.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            handImage.topAnchor.constraint(equalTo: bodyTitle.bottomAnchor,constant: 20),
            handImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            handImage.widthAnchor.constraint(equalToConstant: 300),
            handImage.heightAnchor.constraint(equalToConstant: 300),
            handTitle.topAnchor.constraint(equalTo: handImage.bottomAnchor,constant: 20),
            handTitle.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        ])
    }
    
    
    @objc
    func onTapBodyTracking() {
        let bodyTracking = BodyTrackingVC()
        self.navigationController?.pushViewController(bodyTracking, animated: true)
    }
    
    
    @objc
    func onTapHandTracking() {
        let handViewController = HandTrackingVC()
        self.navigationController?.pushViewController(handViewController, animated: false)
    }
    
    
    
}

struct VCProvider_Previews: PreviewProvider {
    static var previews: some View {
        PreviewViewController<ViewController>()
            .ignoresSafeArea()
    }
}
