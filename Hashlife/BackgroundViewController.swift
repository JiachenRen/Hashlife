//
//  BackgroundViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/28/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class BackgroundViewController: AppearanceViewController, ColorViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.universeView.inheritAppearance(from: target)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let colorViewController = segue.destination as? ColorViewController {
            colorViewController.delegate = self
        }
    }

    func currentColor() -> UIColor {
        return self.target.backgroundColor!
    }

    func receiveUpdatedColor(color: UIColor) {
        self.universeView.backgroundColor = color
        self.target.backgroundColor = color
        self.universeView.setNeedsDisplay()
        self.target.setNeedsDisplay()
    }
    

}
