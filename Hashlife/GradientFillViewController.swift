//
//  GradientFillViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 8/22/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class GradientFillViewController: AppearanceViewController {

    @IBOutlet weak var cascadingGradientSwitch: UISwitch!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var startSlider: UISlider!
    @IBOutlet weak var endSlider: UISlider!
    
    @IBOutlet weak var brightnessLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var saturationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.universeView.inheritAppearance(from: target)
        cascadingGradientSwitch.isOn = UniverseView.gradientFill
        brightnessSlider.value = Float(UniverseView.gradientFillBrightness)
        saturationSlider.value = Float(UniverseView.gradientFillSaturation)
        startSlider.value = Float(UniverseView.gradientFillStart)
        endSlider.value = Float(UniverseView.gradientFillEnd)
        update()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func brightnessSliderChanged(_ sender: UISlider) {
        UniverseView.gradientFillBrightness = CGFloat(sender.value)
        update()
    }

    @IBAction func saturationSliderChanged(_ sender: UISlider) {
        UniverseView.gradientFillSaturation = CGFloat(sender.value)
        update()
    }
    
    @IBAction func startSliderChanged(_ sender: UISlider) {
        UniverseView.gradientFillStart = CGFloat(sender.value)
        update()
    }
    
    @IBAction func endSliderChanged(_ sender: UISlider) {
        UniverseView.gradientFillEnd = CGFloat(sender.value)
        update()
    }
    
    @IBAction func cascadingGradientSwitchToggled(_ sender: UISwitch) {
        UniverseView.gradientFill = sender.isOn
        update()
    }
    
    private func update() {
        brightnessLabel.text = ColorViewController.nf.string(for: brightnessSlider.value)
        saturationLabel.text = ColorViewController.nf.string(for: saturationSlider.value)
        startLabel.text = ColorViewController.nf.string(for: startSlider.value)
        endLabel.text = ColorViewController.nf.string(for: endSlider.value)
        universeView.setNeedsDisplay()
        target.setNeedsDisplay()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
