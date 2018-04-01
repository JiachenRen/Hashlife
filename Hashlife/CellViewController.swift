//
//  CellViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/28/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class CellViewController: AppearanceViewController, ColorViewControllerDelegate {

    @IBOutlet weak var cellStyleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var renderingModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var cascadingGradientSwitch: UISwitch!
    @IBOutlet weak var cellRadiusScaleSlider: UISlider!
    @IBOutlet weak var cellRadiusScaleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.universeView.inheritAppearance(from: target)
        self.cascadingGradientSwitch.isOn = UniverseView.gradientFill

        //update cell radius scale slider
        self.cellRadiusScaleSlider.value = Float(self.target.nodeRadiusScale)
        self.updateCellRadiusScaleLabel()

        //update rendering scale segmented control
        var index = 0
        switch target.baseLevelExponent {
            case .faster: index = 0
            case .balanced: index = 1
            case .better: index = 2
        }
        renderingModeSegmentedControl.selectedSegmentIndex = index
        
        //setup cell style segmented control
        let isRect = target.cellStyle == .rect
        self.cellStyleSegmentedControl.selectedSegmentIndex = isRect ? 0 : 1
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cascadingGradientSwitchToggled(_ sender: UISwitch) {
        UniverseView.gradientFill = sender.isOn
        self.universeView.setNeedsDisplay()
        self.target.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let colorViewController = segue.destination as? ColorViewController {
            colorViewController.delegate = self
        }
    }

    func currentColor() -> UIColor {
        return self.target.aliveColor
    }

    func receiveUpdatedColor(color: UIColor) {
        self.universeView.aliveColor = color
        self.target.aliveColor = color
        self.universeView.setNeedsDisplay()
        self.target.setNeedsDisplay()
    }
    
    @IBAction func cellStyleSegmentedControlChanged(_ sender: UISegmentedControl) {
        var selectedStyle: UniverseView.CellStyle = .ellipse
        switch sender.titleForSegment(at: sender.selectedSegmentIndex)! {
            case "Rectangle": selectedStyle = .rect
            case "Ellipse": selectedStyle = .ellipse
            default: break
        }
        self.universeView.cellStyle = selectedStyle
        self.target.cellStyle = selectedStyle
        self.universeView.setNeedsDisplay()
        self.target.setNeedsDisplay()
    }
    
    public func updateCellRadiusScaleLabel() {
        let val = self.cellRadiusScaleSlider.value
        self.cellRadiusScaleLabel.text = ColorViewController.nf.string(for: val)
    }
    
    @IBAction func cellRadiusScaleSliderChanged(_ sender: UISlider) {
        self.updateCellRadiusScaleLabel()
        self.target.nodeRadiusScale = CGFloat(sender.value)
        self.universeView.nodeRadiusScale = CGFloat(sender.value)
        self.universeView.setNeedsDisplay()
        self.target.setNeedsDisplay()
    }
    
    @IBAction func renderingModeSegmentedControlChanged(_ sender: UISegmentedControl) {
        var selected: UniverseView.RenderingMode = .balanced
        switch sender.selectedSegmentIndex {
        case 0: selected = .faster
        case 1: selected = .balanced
        case 2: selected = .better
        default: break
        }
        self.universeView.baseLevelExponent = selected
        self.target.baseLevelExponent = selected
        self.universeView.setNeedsDisplay()
        self.target.setNeedsDisplay()
    }
}
