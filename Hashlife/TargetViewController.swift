//
//  TargetViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/28/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class TargetViewController: UIViewController {
    var target: UniverseView!
}

class AppearanceViewController: TargetViewController {
    weak var universeView: UniverseView!
    override func viewDidLayoutSubviews() {
        let vp = universeView.getUniverseViewPort()
        for _ in 0..<200 {
            let x = Int(CGFloat.random(min: 0, max: CGFloat(vp.cols + 1))) //x
            let y = Int(CGFloat.random(min: 0, max: CGFloat(vp.rows + 1)))
            universeView.root = universeView.root.setNodeAt(x: x, y: y, to: true)
        }
    }
}
