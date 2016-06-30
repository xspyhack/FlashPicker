//
//  PhotoCell.swift
//  ImagePicker
//
//  Created by k on 6/28/16.
//  Copyright © 2016 egg. All rights reserved.
//

import UIKit
import Photos

class PhotoCell: UICollectionViewCell {

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()

    var targetSize: CGSize = CGSize.zero

    var imageManager: PHImageManager?

    var imageAsset: PHAsset? {
        willSet {
            guard let imageAsset = newValue else {
                return
            }

            let options = PHImageRequestOptions.sharedOptions

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.imageManager?.requestImageForAsset(imageAsset, targetSize: self.targetSize, contentMode: .AspectFill, options: options, resultHandler: { (image, info) in
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.imageView.image = image
                    })
                })
            }
        }
    }

    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        configure()
    }
    
    private func configure() {
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let h = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: [], metrics: nil, views: ["imageView": imageView])
        let v = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: [], metrics: nil, views: ["imageView": imageView])
        NSLayoutConstraint.activateConstraints(h)
        NSLayoutConstraint.activateConstraints(v)
    }

}

extension PHImageRequestOptions {

    static var sharedOptions: PHImageRequestOptions {

        let options = PHImageRequestOptions()
        options.synchronous = true
        options.version = .Current
        options.deliveryMode = .HighQualityFormat
        options.resizeMode = .Exact
        options.networkAccessAllowed = true

        return options
    }
}
