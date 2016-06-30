//
//  ViewController.swift
//  TheFlash
//
//  Created by bl4ckra1sond3tre on 6/29/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import MobileCoreServices.UTType
import FlashPicker

class ViewController: UIViewController {

    @IBOutlet weak var flashPicker: FlashPicker!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var barBottomConstraint: NSLayoutConstraint!
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String]
        return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        flashPicker.pickImageAction = { [weak self] image in
            self?.imageView.image = image
        }
        
        flashPicker.takePhotoAction = { [weak self] in
            guard UIImagePickerController.isSourceTypeAvailable(.Camera) else { return }
            
            if let sSelf = self {
                sSelf.imagePicker.sourceType = .Camera
                sSelf.presentViewController(sSelf.imagePicker, animated: true, completion: nil)
            }
        }
        
        flashPicker.choosePhotoAction = { [weak self] in
            guard UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) else { return }
            
            if let sSelf = self {
                sSelf.imagePicker.sourceType = .PhotoLibrary
                sSelf.presentViewController(sSelf.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        flashPicker.startRunningCamera()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        flashPicker.stopRunningCamera()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        barBottomConstraint.constant = 0.0
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.flashPicker.startRunningCamera()
        }
    }

    @IBAction private func pickAction(sender: UIButton) {
        
        barBottomConstraint.constant = 253.0
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: { 
            self.view.layoutIfNeeded()
        }) { (finished) in
                self.flashPicker.startRunningCamera()
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            switch mediaType {
            case String(kUTTypeImage):
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    imageView.image = image
                }
            default:
                break
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

