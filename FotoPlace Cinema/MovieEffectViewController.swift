//
//  MovieEffectViewController.swift
//  FotoPlace Cinema
//
//  Created by Sihao Lu on 3/22/15.
//  Copyright (c) 2015 DJ.Ben. All rights reserved.
//

import UIKit
import AVFoundation
import Cartography
import JGProgressHUD

class MovieEffectViewController: BottomOverlayViewController {
    
    var sourceImage: UIImage! {
        willSet {
            imageView.image = newValue
        }
    }
    
    var cropRect: CGRect!

    lazy var cropperView: UIView = {
        let view = UIView(frame: CGRectMake(0, 0, 100, 100))
        view.clipsToBounds = true
        return view
    }()
    
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
    
    lazy var topBlackCoverView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor.blackColor()
        return view
    }()
    
    lazy var bottomBlackCoverView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor.blackColor()
        return view
    }()
    
    lazy var topSubtitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont(name: "STHeitiSC-Medium", size: 11)
        label.textColor = UIColor.whiteColor()
        label.shadowColor = UIColor(white: 0, alpha: 0.5)
        label.shadowOffset = CGSizeMake(1, 1)
        return label
    }()
    
    lazy var bottomSubtitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 10)
        label.textColor = UIColor.whiteColor()
        label.shadowColor = UIColor(white: 0, alpha: 0.5)
        label.shadowOffset = CGSizeMake(1, 1)
        return label
    }()
    
    private var imageViewTopConstraint: NSLayoutConstraint!
    
    private var topSubtitle: String = "" {
        willSet {
            topSubtitleLabel.text = newValue
        }
    }
    
    private var bottomSubtitle: String = "" {
        willSet {
            bottomSubtitleLabel.text = newValue
        }
    }
    
    lazy private var editSubtitleButton: UIButton = {
        // TODO: Change appearance of edit button
        let button: UIButton = UIButton.buttonWithType(.Custom) as UIButton
        button.backgroundColor = UIColor.clearColor()
        button.addTarget(self, action: "editSubtitleButtonTapped:", forControlEvents: .TouchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        
        topSubtitle = "当沉睡的创意基因被唤醒，等来的却是一个又一个转录和复制的过程"
        bottomSubtitle = "The best way to make an app is to copy an app"
        view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureViews() {
        view.addSubview(backgroundView)
        view.addSubview(cropperView)
        cropperView.addSubview(self.imageView)
        
        view.addSubview(topBlackCoverView)
        view.addSubview(bottomBlackCoverView)
        
        view.addSubview(topSubtitleLabel)
        view.addSubview(bottomSubtitleLabel)
        view.addSubview(editSubtitleButton)
        
        view.bringSubviewToFront(bottomOverlayView)

        bottomOverlayView.backgroundColor = UIColor.blackColor()
        
        navigationItem.rightBarButtonItem = {
            let saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "savePhoto:")
            return saveButton
            }()
        
        navigationItem.title = ""
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.setBackgroundImage(UIImage.imageFromColor(bottomOverlayView.backgroundColor!), forBarMetrics: .Default)
        
        let imageViewRect = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - self.topLayoutGuide.length - 200)
        let rect = AVMakeRectWithAspectRatioInsideRect(sourceImage.size, imageViewRect)
        
        self.imageView.tag = 1023
        layout(self.imageView) { v in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.height == rect.height
            self.imageViewTopConstraint = (v.top == v.superview!.top - (self.view.bounds.width / self.cropRect.width * self.cropRect.origin.y))
        }
        
        layout(topBlackCoverView, bottomBlackCoverView, cropperView) { t, b, c in
            t.top == c.top
            t.left == c.left
            t.right == c.right
            t.height == self.blackCoverViewHeight()
            b.height == t.height
            b.right == c.right
            b.left == c.left
            b.bottom == c.bottom
        }
        
        layout(topSubtitleLabel, bottomSubtitleLabel, bottomBlackCoverView) { ts, bs, b in
            bs.bottom == b.top - 2
            ts.bottom == bs.top
            ts.centerX == b.centerX
            bs.centerX == b.centerX
        }
        
        layout(editSubtitleButton, topSubtitleLabel, bottomSubtitleLabel) { e, t, b in
            e.top == t.top - 4
            e.bottom == b.bottom + 4
            e.left == e.superview!.left
            e.right == e.superview!.right
        }
        
        layout(cropperView) { v in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.height == v.width * CropAspectRatio
        }
        view.addConstraint(NSLayoutConstraint(item: cropperView, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 100))
        
        layout(backgroundView, bottomOverlayView) { v, b in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.bottom == b.top
        }
        
        view.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        
        view.layoutIfNeeded()
    }
    
    private func blackCoverViewHeight() -> CGFloat {
        return blackCoverHeightWithReferenceWidth(view.frame.width)
    }
    
    private func blackCoverHeightInImage() -> CGFloat {
        return blackCoverHeightWithReferenceWidth(sourceImage.size.width)
    }
    
    private func blackCoverHeightWithReferenceWidth(width: CGFloat) -> CGFloat {
        let movieRatio: CGFloat = 2.21
        let currentRatio: CGFloat = 16 / 9.0
        return (width / currentRatio - width / movieRatio) / 2
    }
    
    func editSubtitleButtonTapped(sender: UIButton!) {
        // TODO: Change another way to input
        let alertController = UIAlertController(title: "Edit Subtitle", message: "You can edit two-line subtitles here.", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler(nil)
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.autocapitalizationType = .Sentences
            textField.autocorrectionType = .Yes
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Finish", style: .Default, handler: { (_) -> Void in
            self.topSubtitle = (alertController.textFields![0] as UITextField).text ?? ""
            self.bottomSubtitle = (alertController.textFields![1] as UITextField).text ?? ""
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }

    func savePhoto(sender: UIBarButtonItem!) {
        let progressHUD = JGProgressHUD(style: .Light)
        progressHUD.textLabel.text = "写入相册..."
        progressHUD.indicatorView = {
            let indicator = JGProgressHUDIndeterminateIndicatorView()
            indicator.setColor(Style.ForegroundBlue)
            return indicator
        }()
        progressHUD.showInView(self.view, animated: true)

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let image = self.imageRenderedAsMovieScene()
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            dispatch_async(dispatch_get_main_queue()) {
                progressHUD.dismiss()
                let successHUD = JGProgressHUD(style: .Light)
                successHUD.indicatorView = JGProgressHUDSuccessIndicatorView()
                successHUD.textLabel.text = "保存成功！"
                successHUD.showInView(self.view, animated: true)
                successHUD.dismissAfterDelay(1.5)
            }
        }
    }
    
    private func imageRenderedAsMovieScene() -> UIImage {
        UIGraphicsBeginImageContext(cropRect.size)
        sourceImage.drawAtPoint(CGPointMake(-cropRect.origin.x, -cropRect.origin.y))
        let context = UIGraphicsGetCurrentContext()
        
        // Add black covers
        UIColor.clearColor().setStroke()
        UIColor.blackColor().setFill()
        let topCoverRect = CGRectMake(0, 0, cropRect.size.width, blackCoverHeightInImage())
        CGContextFillRect(context, topCoverRect)
        let bottomCoverRect = CGRectMake(0, cropRect.size.height - blackCoverHeightInImage(), cropRect.size.width, blackCoverHeightInImage())
        CGContextFillRect(context, bottomCoverRect)
        
        // Draw text
        UIColor.whiteColor().set()
        let shadow = NSShadow()
        let ratio: CGFloat = cropRect.width / view.frame.width
        shadow.shadowColor = UIColor(white: 0, alpha: 0.5)
        shadow.shadowOffset = CGSizeMake(1 * ratio, 1 * ratio)
        let topSubtitleFont = UIFont(name: "STHeitiSC-Medium", size: 11 * ratio)!
        let topAttributes: [NSString: AnyObject] = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: topSubtitleFont, NSShadowAttributeName: shadow]
        let bottomSubtitleFont = UIFont(name: "HelveticaNeue", size: 10 * ratio)!
        let bottomAttributes: [NSString: AnyObject] = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: bottomSubtitleFont, NSShadowAttributeName: shadow]
        let topSize = (topSubtitle as NSString).sizeWithAttributes(topAttributes)
        let bottomSize = (bottomSubtitle as NSString).sizeWithAttributes(bottomAttributes)
        let bottomRect = CGRectMake((cropRect.size.width - bottomSize.width) / 2 , cropRect.size.height - bottomSize.height - blackCoverHeightInImage() - 2 * ratio, bottomSize.width, bottomSize.height)
        let topRect = CGRectMake((cropRect.size.width - topSize.width) / 2, bottomRect.origin.y - topSize.height, topSize.width, topSize.height)
        (bottomSubtitle as NSString).drawInRect(bottomRect, withAttributes: bottomAttributes)
        (topSubtitle as NSString).drawInRect(topRect, withAttributes: topAttributes)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
