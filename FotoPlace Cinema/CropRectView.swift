//
//  CropRectView.swift
//  FotoPlace Cinema
//
//  Created by Sihao Lu on 3/22/15.
//  Copyright (c) 2015 DJ.Ben. All rights reserved.
//

import UIKit
import Cartography

var CropRectControlRadius: CGFloat = 16

@IBDesignable class CropRectView: UIView {
    
    @IBInspectable var image: UIImage? {
        willSet {
            setNeedsDisplay()
        }
    }
    
    var selected: Bool = false {
        willSet {
            setNeedsDisplay()
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    private func configureView() {
        backgroundColor = UIColor.clearColor()
        addSubview(imageView)
        layout(imageView) { v in
            v.edges == inset(v.superview!.edges, CropRectControlRadius)
            return
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }

    override func drawRect(rect: CGRect) {
        // Drawing code
        let context = UIGraphicsGetCurrentContext()
        let insets = UIEdgeInsetsMake(CropRectControlRadius, CropRectControlRadius, CropRectControlRadius, CropRectControlRadius)
        if image != nil {
            CGContextDrawImage(context, UIEdgeInsetsInsetRect(bounds, insets), image!.CGImage)
        }
        if selected {
            CGContextSetStrokeColorWithColor(context, Style.SelectedRed.CGColor)
            CGContextSetFillColorWithColor(context, Style.SelectedRed.CGColor)
        } else {
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
            CGContextSetFillColorWithColor(context, Style.ForegroundBlue.CGColor)
        }
        CGContextStrokeRectWithWidth(context, UIEdgeInsetsInsetRect(bounds, insets), 3)
        CGContextSetLineWidth(context, 0)
        CGContextAddEllipseInRect(context, ellipseRectWithPoint(CGPointMake(insets.left, insets.top)))
        CGContextAddEllipseInRect(context, ellipseRectWithPoint(CGPointMake(insets.left, frame.height - insets.top)))
        CGContextAddEllipseInRect(context, ellipseRectWithPoint(CGPointMake(frame.width - insets.left, insets.top)))
        CGContextAddEllipseInRect(context, ellipseRectWithPoint(CGPointMake(frame.width - insets.left, frame.height - insets.top)))
        CGContextDrawPath(context, kCGPathFillStroke)
    }
    
    private func ellipseRectWithPoint(point: CGPoint, radius: CGFloat = CropRectControlRadius) -> CGRect {
        return CGRectMake(point.x - radius, point.y - radius, 2 * radius, 2 * radius)
    }
    
    override func prepareForInterfaceBuilder() {
        backgroundColor = UIColor.clearColor()
    }

}
