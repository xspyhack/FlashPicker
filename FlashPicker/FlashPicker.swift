//
//  FlashPicker.swift
//  ImagePicker
//
//  Created by k on 6/29/16.
//  Copyright © 2016 egg. All rights reserved.
//


import UIKit
import Photos

public class FlashPicker: UIView {

    private lazy var collectionView: UICollectionView = {
        let flowLayout =  UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    private var images: PHFetchResult?
    private var imageManager = PHCachingImageManager()

    public var pickImageAction: ((UIImage) -> Void)?
    public var takePhotoAction: (() -> Void)?
    public var choosePhotoAction: (() -> Void)?
    public var minimumSpacing: CGFloat = 1.0
    public var margin: CGFloat = 10.0

    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)

        initialize()
    }

    private func initialize() {

        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        let views = [
            "collectionView": collectionView,
        ]

        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: [], metrics: nil, views: views)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views)

        NSLayoutConstraint.activateConstraints(hConstraints)
        NSLayoutConstraint.activateConstraints(vConstraints)

        collectionView.registerClass(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.registerClass(CameraCell.self, forCellWithReuseIdentifier: "CameraCell")
        collectionView.registerClass(ActionCell.self, forCellWithReuseIdentifier: "ActionCell")
        collectionView.showsHorizontalScrollIndicator = false

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = minimumSpacing
            layout.minimumLineSpacing = minimumSpacing
            layout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: 0)

            collectionView.contentInset = UIEdgeInsets(top: minimumSpacing, left: minimumSpacing, bottom: minimumSpacing, right: minimumSpacing)
        }

        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        let images = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        self.images = images
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }

    public func startRunningCamera() {
        let cameraCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: Section.Camera.rawValue)) as? CameraCell
        cameraCell?.startRunning()
    }

    public func stopRunningCamera() {
        let cameraCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: Section.Camera.rawValue)) as? CameraCell
        cameraCell?.stopRunning()
    }
}

extension FlashPicker: PHPhotoLibraryChangeObserver {

    public func photoLibraryDidChange(changeInstance: PHChange) {
        if let images = images, changeDetails = changeInstance.changeDetailsForFetchResult(images) {
            dispatch_async(dispatch_get_main_queue(), {
                self.images = changeDetails.fetchResultAfterChanges
                self.collectionView.reloadData()
            })
        }
    }
}

extension FlashPicker: UICollectionViewDataSource {

    private enum Section: Int {
        case Action = 0
        case Camera
        case Photos
    }

    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .Action: return 2
        case .Camera: return 1
        case .Photos: return images?.count ?? 0
        }
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        guard let section = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        switch section {
        case .Action:
            return collectionView.dequeueReusableCellWithReuseIdentifier("ActionCell", forIndexPath: indexPath)
        case .Camera:
            return collectionView.dequeueReusableCellWithReuseIdentifier("CameraCell", forIndexPath: indexPath)
        case .Photos:
            return collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath)
        }
    }
}

extension FlashPicker: UICollectionViewDelegate {

    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .Action:
            guard let cell = cell as? ActionCell else { return }
            if indexPath.item == 0 {
                cell.titleLabel.text = NSLocalizedString("Camera", comment: "")
                cell.imageView.image = UIImage(named: "camera", inBundle: NSBundle(forClass: FlashPicker.self), compatibleWithTraitCollection: nil)
            } else {
                cell.titleLabel.text = NSLocalizedString("Photo Library", comment: "")
                cell.imageView.image = UIImage(named: "photos", inBundle: NSBundle(forClass: FlashPicker.self), compatibleWithTraitCollection: nil)
            }
        case .Camera:
            guard let cell = cell as? CameraCell else { return }
            cell.shotAction = { [weak self] imageData in
                guard let image = UIImage(data: imageData) else { return }

                dispatch_async(dispatch_get_main_queue(), {
                    self?.pickImageAction?(image)
                })
            }
        case .Photos:
            guard let cell = cell as? PhotoCell, imageAsset = images?[indexPath.item] as? PHAsset else { return }

            cell.imageManager = imageManager
            cell.imageAsset = imageAsset
            let height = (collectionView.bounds.height - 3 * minimumSpacing)
            cell.targetSize = CGSize(width: height, height: height)
        }
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .Action:
            if indexPath.item == 0 {
                takePhotoAction?()
            } else {
                choosePhotoAction?()
            }
        case .Photos:
            guard let pickedAsset: PHAsset = images?.objectAtIndex(indexPath.item) as? PHAsset else { return }
            let options = PHImageRequestOptions.sharedOptions
            let imageManager = PHCachingImageManager.defaultManager()

            let pixelWidth = CGFloat(pickedAsset.pixelWidth)
            let pixelHeight = CGFloat(pickedAsset.pixelHeight)

            let targetSize = CGSize(width: pixelWidth, height: pixelHeight)

            imageManager.requestImageForAsset(pickedAsset, targetSize: targetSize, contentMode: .AspectFill, options: options) { [weak self] (image, info) in

                if let image = image {
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.pickImageAction?(image)
                    })
                }
            }

        default: return
        }
    }
}

extension FlashPicker: UICollectionViewDelegateFlowLayout {

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        guard let section = Section(rawValue: indexPath.section) else { return CGSize.zero }

        let collectionViewHeight = collectionView.bounds.height
        let width = (collectionViewHeight - 3 * minimumSpacing) / 2

        switch section {
        case .Action: return CGSize(width: width * 0.7, height: width - 2 * margin)
        case .Camera:
            let height = collectionViewHeight - 2 * minimumSpacing
            return CGSize(width: height * 10 / 16, height: height)
        case .Photos: return CGSize(width: width, height: width)
        }
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {

        guard let section = Section(rawValue: section) else { return UIEdgeInsetsZero }

        switch section {
        case .Action: return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        case .Camera: return UIEdgeInsetsZero
        case .Photos: return UIEdgeInsets(top: 0, left: margin, bottom: 0, right: 0)
        }

    }
}