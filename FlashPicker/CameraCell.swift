//
//  CameraCell.swift
//  ImagePicker
//
//  Created by k on 6/28/16.
//  Copyright © 2016 egg. All rights reserved.
//

import UIKit

class CameraCell: UICollectionViewCell {

    private lazy var camera = Camera()
    private lazy var containerView: UIView = UIView()
    private lazy var flipButton: UIButton = {
        let button = UIButton(type: .Custom)
        let image = UIImage(named: "icon_camera", inBundle: NSBundle(forClass: FlashPicker.self), compatibleWithTraitCollection: nil)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(CameraCell.flipAction(_:)), forControlEvents: .TouchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }()
    
    private lazy var shotButton: UIButton = {
        let button = UIButton(type: .Custom)
        let image = UIImage(named: "icon_shot", inBundle: NSBundle(forClass: FlashPicker.self), compatibleWithTraitCollection: nil)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(CameraCell.shotAction(_:)), forControlEvents: .TouchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }()

    var shotAction: ((NSData) -> Void)?
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        camera.previewLayer.frame = bounds
    }
    
    private func configure() {
        
        backgroundColor = UIColor.blackColor()
        
        camera.previewLayer.frame = containerView.bounds
        containerView.layer.addSublayer(camera.previewLayer)
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(flipButton)
        flipButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shotButton)
        shotButton.translatesAutoresizingMaskIntoConstraints = false
        
        let containerH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[containerView]|", options: [], metrics: nil, views: ["containerView": containerView])
        let containerV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[containerView]|", options: [], metrics: nil, views: ["containerView": containerView])
        NSLayoutConstraint.activateConstraints(containerH)
        NSLayoutConstraint.activateConstraints(containerV)
        
        let shotH = NSLayoutConstraint.constraintsWithVisualFormat("H:[shotButton(==46)]", options: [.AlignAllCenterX], metrics: nil, views: ["shotButton": shotButton])
        let shotV = NSLayoutConstraint.constraintsWithVisualFormat("V:[shotButton(==46)]-4-|", options: [], metrics: nil, views: ["shotButton": shotButton])
        let shotCenterX = NSLayoutConstraint(item: shotButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activateConstraints([shotCenterX])
        NSLayoutConstraint.activateConstraints(shotH)
        NSLayoutConstraint.activateConstraints(shotV)
        
        let flipH = NSLayoutConstraint.constraintsWithVisualFormat("H:[flipButton(==30)]-8-|", options: [], metrics: nil, views: ["flipButton": flipButton])
        let flipV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[flipButton(==25)]", options: [], metrics: nil, views: ["flipButton": flipButton])
        
        NSLayoutConstraint.activateConstraints(flipH)
        NSLayoutConstraint.activateConstraints(flipV)
    }

    @objc private func shotAction(sender: UIButton) {
        camera.capture { [weak self] (imageData) in
            self?.shotAction?(imageData)
        }
    }
    
    @objc private func flipAction(sender: UIButton) {
        camera.flip()
    }

    func startRunning() {
        camera.startRunning()
    }

    func stopRunning() {
        camera.stopRunning()
    }

}
