//
//  AutoSpeedViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/28/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class AutoSpeedViewController: TargetViewController {
    @IBOutlet weak var renderingDurationSlider: UISlider!
    @IBOutlet weak var iterationPerFrameLabel: UILabel!
    @IBOutlet weak var iterationPerFrameStaticLabel: UILabel!
    @IBOutlet weak var renderingDurationLabel: UILabel!
    @IBOutlet weak var iterationsPerFrameSlider: UISlider!
    @IBOutlet weak var autoSpeedSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up autoSpeedSwitch
        self.autoSpeedSwitch.isOn = UniverseSimulator.sharedInstance.autoSpeed

        //set up iteration per frame slider
        iterationsPerFrameSlider.value = Float(UniverseSimulator.sharedInstance.stepPerFrame)

        //set up rendering duration slider
        updateControlsVisibility()
        renderingDurationSlider.value = Float(target.maxAllowedRenderingduration)

        updateLabels()
        // Do any additional setup after loading the view.
    }
    
    private func updateControlsVisibility() {
        iterationsPerFrameSlider.isEnabled = !autoSpeedSwitch.isOn
        iterationPerFrameStaticLabel.isEnabled = !autoSpeedSwitch.isOn
        iterationPerFrameLabel.isEnabled = !autoSpeedSwitch.isOn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateLabels() {
        self.renderingDurationLabel.text = String(Int(renderingDurationSlider.value))
        self.iterationPerFrameLabel.text = String(Int(iterationsPerFrameSlider.value))
    }
    
    @IBAction func autoSpeedSwitchToggled(_ sender: UISwitch) {
        UniverseSimulator.sharedInstance.autoSpeed = sender.isOn
        self.updateControlsVisibility()
    }
    
    @IBAction func renderingDurationSliderChanged(_ sender: UISlider) {
        self.target.maxAllowedRenderingduration = Int(sender.value)
        self.updateLabels()
    }
    
    @IBAction func iterationPerFrameSliderChanged(_ sender: UISlider) {
        UniverseSimulator.sharedInstance.stepPerFrame = Int(sender.value)
        self.updateLabels()
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
