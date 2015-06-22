//
//  PhotoCaptureViewController.swift
//  FotoPlace Cinema
//
//  Created by Sihao Lu on 3/21/15.
//  Copyright (c) 2015 DJ.Ben. All rights reserved.
//

import UIKit
import AVFoundation
import Cartography
import JGProgressHUD
import CoreMotion

class PhotoCaptureViewController: BottomOverlayViewController {
    
    lazy var previewView: UIView = {
        return UIView()
    }()
    
    lazy var capturedImage: UIImageView = UIImageView()
    
    lazy var takePhotoButton: UIButton = {
        let button: UIButton = UIButton.buttonWithType(.Custom) as! UIButton
        button.setImage(UIImage(named: "take_photo"), forState: .Normal)
        button.setImage(UIImage(named: "take_photo_down"), forState: .Highlighted)
        button.addTarget(self, action: "didTakePhoto:", forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var chooseFromGalleryButton: UIButton = {
        let button: UIButton = UIButton.buttonWithType(.Custom) as! UIButton
        button.setTitle("去相册选", forState: .Normal)
        button.setTitleColor(Style.ForegroundBlue, forState: .Normal)
        button.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 16)
        button.addTarget(self, action: "didChoosePhotoFromGallery:", forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var portraitNoticeOverlayView: UIView = {
        let view: UIView = UIView(frame: CGRectMake(0, 0, 100, 100))
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        let rotateLabel = UILabel()
        rotateLabel.font = UIFont.systemFontOfSize(17)
        rotateLabel.text = "亲，把相机横过来拍摄更有大片感哟！"
        rotateLabel.textColor = UIColor.whiteColor()
        view.addSubview(rotateLabel)
        let remindLabel = UILabel()
        remindLabel.font = UIFont.systemFontOfSize(16)
        remindLabel.text = "这图标我自己照着它画的"
        remindLabel.textColor = UIColor.whiteColor()
        view.addSubview(remindLabel)
        layout(rotateLabel, remindLabel) { v, r in
            v.center == v.superview!.center
            r.bottom == r.superview!.bottom - 4
            r.centerX == r.superview!.centerX
        }
        return view
    }()
    
    lazy var motionManager: CMMotionManager = CMMotionManager()
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var accelerationLandscape: Bool = false
    var photoOrientation: UIImageOrientation = .Left
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureViews()
        
        // Start orientation detection
        motionManager.gyroUpdateInterval = 1 / 10.0
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data: CMAccelerometerData!, error: NSError!) -> Void in
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            if self.accelerationLandscape {
                if abs(y) > sin(M_PI * (50 / 180.0)) {
                    self.accelerationLandscape = false
                    self.orientationChanged(self.motionManager)
                }
            } else {
                if abs(x) > sin(M_PI * (50 / 180.0)) {
                    self.accelerationLandscape = true
                    self.photoOrientation = x > 0 ? .Right : .Left
                    self.orientationChanged(self.motionManager)
                }
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if motionManager.gyroActive {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        layout(previewView, bottomOverlayView) { v, b in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.bottom == b.top
            v.top == v.superview!.top + self.topLayoutGuide.length
        }
        
        layout(takePhotoButton, chooseFromGalleryButton) { v, c in
            v.center == v.superview!.center
            v.height == v.width
            v.bottom == v.superview!.bottom - 16
            
            c.bottom == v.bottom
            c.top == v.top
            c.right == c.superview!.right - 20
        }
        
        layout(portraitNoticeOverlayView, previewView) { v, p in
            v.edges == inset(p.edges, 0)
            return
        }
        
        previewLayer!.frame = previewView.bounds
    }
    
    private func configureViews() {
        view.addSubview(previewView)
        view.addSubview(portraitNoticeOverlayView)
        view.bringSubviewToFront(bottomOverlayView)

        bottomOverlayView.addSubview(takePhotoButton)
        bottomOverlayView.addSubview(chooseFromGalleryButton)

        navigationItem.title = "大片"
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.setBackgroundImage(UIImage.imageFromColor(bottomOverlayView.backgroundColor!), forBarMetrics: .Default)
    }
    
    override func viewWillAppear(animated: Bool) {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError?
        var input = AVCaptureDeviceInput(device: backCamera, error: &error)
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer)
                
                captureSession!.startRunning()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Stop the capture session
        captureSession!.stopRunning()
        previewLayer!.removeFromSuperlayer()
        
        if segue.identifier == "cropImage" {
            let vc = segue.destinationViewController as! CropPhotoViewController
            vc.sourceImage = self.capturedImage.image
        }
    }
    
    func orientationChanged(sender: AnyObject) {
        if accelerationLandscape {
            // Landscape
            UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                self.portraitNoticeOverlayView.alpha = 0
                let rotation: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(self.photoOrientation == .Left ? M_PI_2 : -M_PI_2))
                self.takePhotoButton.transform = rotation
                self.chooseFromGalleryButton.transform = rotation
            }, completion: nil)
        } else {
            // Portrait
            UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                self.portraitNoticeOverlayView.alpha = 1
                self.takePhotoButton.transform = CGAffineTransformIdentity
                self.chooseFromGalleryButton.transform = CGAffineTransformIdentity
            }, completion: nil)
        }
    }
    
    // MARK: - Event handling
    
    func didTakePhoto(sender: AnyObject) {
        if !accelerationLandscape {
            return
        }
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            if videoConnection.supportsVideoOrientation {
                videoConnection.videoOrientation = self.photoOrientation == .Left ? .LandscapeRight : .LandscapeLeft
            }
            let progressHUD = JGProgressHUD(style: .Light)
            progressHUD.textLabel.text = "处理中..."
            progressHUD.indicatorView = {
                let indicator = JGProgressHUDIndeterminateIndicatorView()
                indicator.setColor(Style.ForegroundBlue)
                return indicator
                }()
            progressHUD.showInView(self.view, animated: true)
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                progressHUD.dismiss()
                if (sampleBuffer != nil) {
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    var image = UIImage(data: imageData)!
                    self.capturedImage.image = image.imageByFixingOrientation()
                    self.performSegueWithIdentifier("cropImage", sender: self)
                }
            })
        }
    }
    
    func didChoosePhotoFromGallery(sender: AnyObject) {
        // TODO: Choose photo from gallery
    }
}

private var imageCache = [UIColor: UIImage]()

extension UIImage {
    class func imageFromColor(color: UIColor) -> UIImage {
        if let image = imageCache[color] {
            return image
        } else {
            UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
            color.set()
            let context = UIGraphicsGetCurrentContext()
            CGContextStrokeRect(context, CGRectMake(0, 0, 1, 1))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            imageCache[color] = image
            return image
        }
    }
}

