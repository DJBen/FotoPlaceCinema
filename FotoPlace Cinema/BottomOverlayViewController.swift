//
//  BottomOverlayViewController.swift
//  FotoPlace Cinema
//
//  Created by Sihao Lu on 3/23/15.
//  Copyright (c) 2015 DJ.Ben. All rights reserved.
//

import UIKit
import Cartography

class Style {
    class var OverlayGray: UIColor {
        return UIColor(red: 30 / 255.0, green: 37 / 255.0, blue: 45 / 255.0, alpha: 1)
    }
    class var ForegroundBlue: UIColor {
        return UIColor(red: 67 / 255.0, green: 168 / 255.0, blue: 238 / 255.0, alpha: 1)
    }
    class var SelectedRed: UIColor {
        return UIColor(red: 229 / 255.0, green: 161 / 255.0, blue: 162 / 255.0, alpha: 1)
    }
}

class BottomOverlayViewController: UIViewController {
    
    lazy var bottomOverlayView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = Style.OverlayGray
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(bottomOverlayView)
        layout(bottomOverlayView) { b in
            b.height == 100
            b.bottom == b.superview!.bottom
            b.left == b.superview!.left
            b.right == b.superview!.right
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
