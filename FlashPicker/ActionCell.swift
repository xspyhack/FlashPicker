//
//  ActionCell.swift
//  ImagePicker
//
//  Created by k on 6/29/16.
//  Copyright © 2016 egg. All rights reserved.
//

import UIKit

class ActionCell: UICollectionViewCell {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(14.0)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()

    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        configure()
    }
    
    private func configure() {
        
        layer.cornerRadius = 8.0
        backgroundColor = UIColor.whiteColor()
        
        addSubview(titleLabel)
        addSubview(imageView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabelHeight = NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.5, constant: 0.0)
        let titleLabelY = NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.5, constant: 0.0)
        let titleLabelH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-12-[titleLabel]-12-|", options: [], metrics: nil, views: ["titleLabel": titleLabel])
        
        let imageViewX = NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let imageViewY = NSLayoutConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
//        let imageViewWidth = NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView(==40)]", options: [], metrics: nil, views: ["imageView": imageView])
//        let imageViewHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(==40)]", options: [], metrics: nil, views: ["imageView": imageView])
        
        NSLayoutConstraint.activateConstraints([titleLabelHeight, titleLabelY, imageViewX, imageViewY])
        NSLayoutConstraint.activateConstraints(titleLabelH)
//        NSLayoutConstraint.activateConstraints(imageViewWidth)
//        NSLayoutConstraint.activateConstraints(imageViewHeight)
    }

}
