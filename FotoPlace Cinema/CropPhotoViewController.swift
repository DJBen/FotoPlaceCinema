//
//  CropPhotoViewController.swift
//  FotoPlace Cinema
//
//  Created by Sihao Lu on 3/22/15.
//  Copyright (c) 2015 DJ.Ben. All rights reserved.
//

import UIKit
import Cartography
import AVFoundation

let MovieEffectSegueIdentifier = "movieEffect"

let CropAspectRatio: CGFloat = 9 / 16.0

class CropPhotoViewController: BottomOverlayViewController, UIGestureRecognizerDelegate {
    
    var sourceImage: UIImage! {
        willSet {
            imageView.image = newValue
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        return imageView
    }()
    
    lazy var backgroundView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor.darkGrayColor()
        return view
    }()
    
    lazy var dragGR: UIPanGestureRecognizer = {
        let GR: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "dragGestureDetected:")
        GR.delegate = self
        return GR
    }()
    
    lazy var cropView: CropRectView = {
        let cropView: CropRectView = CropRectView(frame: CGRectMake(0, 0, 100, 100))
        return cropView
    }()
    
    lazy var nextStepButton: UIButton = {
        let button: UIButton = UIButton.buttonWithType(.Custom) as UIButton
        button.setTitle("下一步", forState: .Normal)
        button.setTitleColor(Style.ForegroundBlue, forState: .Normal)
        button.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 18)
        button.addTarget(self, action: "nextStepButtonTapped:", forControlEvents: .TouchUpInside)
        return button
    }()
    
    private var lastTranslation: CGPoint = CGPointZero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func configureViews() {
        view.addSubview(backgroundView)
        view.addSubview(imageView)
        view.addSubview(cropView)
        view.bringSubviewToFront(bottomOverlayView)

        bottomOverlayView.addSubview(nextStepButton)
        bottomOverlayView.backgroundColor = UIColor.blackColor()
        
        navigationItem.title = "裁切"
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.setBackgroundImage(UIImage.imageFromColor(bottomOverlayView.backgroundColor!), forBarMetrics: .Default)
        
        layout(backgroundView, bottomOverlayView) { v, b in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.top == v.superview!.top + self.topLayoutGuide.length
            v.bottom == b.top
        }
        
//        println("Top layout guide = \(topLayoutGuide.length)")
        
        let imageViewRect = CGRectMake(0, self.topLayoutGuide.length + 50, self.view.bounds.width, self.view.bounds.height - self.topLayoutGuide.length - 200)
        let rect = AVMakeRectWithAspectRatioInsideRect(self.sourceImage.size, imageViewRect)
        
        layout(imageView) { v in
            v.left == v.superview!.left + rect.origin.x
            v.width == rect.width
            v.height == rect.height
            v.top == v.superview!.top + rect.origin.y
        }
        
        cropView.frame = CGRectMake(imageView.frame.origin.x - CropRectControlRadius, imageView.frame.origin.y - CropRectControlRadius, imageView.frame.width + 2 * CropRectControlRadius, imageView.frame.width * CropAspectRatio + 2 * CropRectControlRadius)

        layout(nextStepButton) { v in
            v.centerY == v.superview!.centerY
            v.bottom == v.superview!.bottom - 16
            v.right == v.superview!.right - 20
        }
        
        // Add gesture recognizer
        view.addGestureRecognizer(self.dragGR)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func croppedImageRect() -> CGRect {
        let ratio = sourceImage.size.width / imageView.frame.width
        let x: CGFloat = cropView.frame.origin.x + CropRectControlRadius - imageView.frame.origin.x
        let y: CGFloat = cropView.frame.origin.y + CropRectControlRadius - imageView.frame.origin.y
        let width: CGFloat = cropView.frame.width - 2 * CropRectControlRadius
        let height: CGFloat = cropView.frame.height - 2 * CropRectControlRadius
        return CGRectMake(x * ratio, y * ratio, width * ratio, height * ratio)
    }
    
    // MARK: - Button Events
    func nextStepButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier(MovieEffectSegueIdentifier, sender: self)
    }
    
    // MARK: - Gesture Recognizers
    func dragGestureDetected(sender: UIPanGestureRecognizer!) {
        if sender.state == UIGestureRecognizerState.Ended {
            lastTranslation = CGPointZero
        } else {
            let translation = sender.translationInView(sender.view!)
            
            if (cropView.frame.origin.x + CropRectControlRadius + translation.x - lastTranslation.x) < imageView.frame.origin.x {
                cropView.frame.origin.x = imageView.frame.origin.x - CropRectControlRadius
            } else if (cropView.frame.origin.x + cropView.frame.width - CropRectControlRadius + translation.x - lastTranslation.x) > imageView.frame.origin.x + imageView.frame.width {
                cropView.frame.origin.x = imageView.frame.origin.x + imageView.frame.width - cropView.frame.width + CropRectControlRadius
            } else {
                cropView.frame.origin.x += translation.x - lastTranslation.x
            }
            if (cropView.frame.origin.y + CropRectControlRadius + translation.y - lastTranslation.y) < imageView.frame.origin.y {
                cropView.frame.origin.y = imageView.frame.origin.y - CropRectControlRadius

            } else if (cropView.frame.origin.y + cropView.frame.height - CropRectControlRadius + translation.y - lastTranslation.y) > imageView.frame.origin.y + imageView.frame.height {
                cropView.frame.origin.y = imageView.frame.origin.y + imageView.frame.height - cropView.frame.height + CropRectControlRadius
            } else {
                cropView.frame.origin.y += translation.y - lastTranslation.y
            }
            lastTranslation = translation
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer.self) {
            let location = touch.locationInView(gestureRecognizer.view)
            let isInCropView = CGRectContainsPoint(cropView.frame, location)
//            println("\(location), \(isInCropView), \(cropView.frame)")
            return isInCropView
        }
        return false
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MovieEffectSegueIdentifier {
            let vc = segue.destinationViewController as MovieEffectViewController
            vc.sourceImage = sourceImage
            vc.cropRect = croppedImageRect()
//            println("Source image size = \(sourceImage.size), crop rect = \(vc.cropRect)")
        }
    }


}
