//
//  ViewController.swift
//  PQAdjustViewTest
//
//  Created by 盘国权 on 2018/11/13.
//  Copyright © 2018 pgq. All rights reserved.
//

import UIKit
import PQAdjustView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
     
        view.backgroundColor = UIColor.gray
        
        let y = PQAdjustView(frame: CGRect(x: 0, y: 200, width: 80, height: 170))
        y.showType = .white
        
        let yw = PQAdjustView(frame: CGRect(x: 90, y: 200, width: 80, height: 170))
        yw.showType = .hueWhite
        
        let rgb = PQAdjustView(frame: CGRect(x: 180, y: 200, width: 120, height: 170))
        rgb.showType = .rgb
        rgb.dueTime = 0
        
        rgb.changColor { (progress, color) in
            self.view.backgroundColor = color
        }
        
        view.addSubview(y)
        view.addSubview(yw)
        view.addSubview(rgb)
        
    }
}

