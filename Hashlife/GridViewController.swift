//
//  GridViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/28/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class GridViewController: AppearanceViewController, ColorViewControllerDelegate {
    
    @IBOutlet weak var gridVisibleThresholdSlider: UISlider!
    @IBOutlet weak var gridVisibleThresholdLabel: UILabel!
    @IBOutlet weak var gridVisibleSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set up grid visible threshold slider.
        self.gridVisibleThresholdSlider.value = Float(target.gridVisibleThreshold)
        self.updateGridThresholdLabel()

        //set up grid visible UISwitch
        self.gridVisibleSwitch.isOn = target.gridVisible
        
        //set up the dummy universe view.
        self.universeView.inheritAppearance(from: target)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //updates grid visible threshold label
    private func updateGridThresholdLabel() {
        let txt = String(describing: gridVisibleThresholdSlider.value)
        self.gridVisibleThresholdLabel.text = String(txt[..<txt.index(txt.startIndex, offsetBy: 3)])
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let colorViewController = segue.destination as? ColorViewController {
            colorViewController.delegate = self
        }
    }
    
    @IBAction func gridVisibleThresholdSliderChanged(_ sender: UISlider) {
        self.universeView.gridVisibleThreshold = CGFloat(sender.value)
        target.gridVisibleThreshold = CGFloat(sender.value)
        self.universeView.setNeedsDisplay()
        self.target.setNeedsDisplay()
        self.updateGridThresholdLabel()
    }
    
    @IBAction func gridVisibleSwitchToggled(_ sender: UISwitch) {
        self.universeView.gridVisible = sender.isOn
        self.target.gridVisible = sender.isOn
        self.universeView.setNeedsDisplay()
        self.target.setNeedsDisplay()
    }

    func currentColor() -> UIColor {
        return self.target.gridColor
    }

    func receiveUpdatedColor(color: UIColor) {
        self.universeView.gridColor = color
        self.target.gridColor = color
        self.universeView.setNeedsDisplay()
        self.target.setNeedsDisplay()
    }
}

////view controllers that receive a target that is an instance of UniverseView and manipulates it.
//protocol TargetViewControllerProtocol {
//    var target: UniverseView! {get set}
//}
