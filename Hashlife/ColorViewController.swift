//
//  ColorViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/28/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class ColorViewController: UIViewController {

    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var alphaSlider: UISlider!

    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var alphaLabel: UILabel!

    static var nf: NumberFormatter = {
        var tmp = NumberFormatter()
        tmp.numberStyle = .decimal
        tmp.maximumFractionDigits = 1
        return tmp
    }()

    var delegate: ColorViewControllerDelegate?
    var color: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.color = delegate?.currentColor()
        let rgb = color.rgb()
        self.redSlider.value = Float(rgb.r)
        self.greenSlider.value = Float(rgb.g)
        self.blueSlider.value = Float(rgb.b)
        self.alphaSlider.value = Float(rgb.a)
        updateColorLabels()
        // Do any additional setup after loading the view.
    }

    private func updateColorLabels() {
        redLabel.text = ColorViewController.nf.string(for: redSlider.value)
        greenLabel.text = ColorViewController.nf.string(for: greenSlider.value)
        blueLabel.text = ColorViewController.nf.string(for: blueSlider.value)
        alphaLabel.text = ColorViewController.nf.string(for: alphaSlider.value)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func colorSliderChanged(_ sender: UISlider) {
        let orgRgb = color.rgb()
        var newColor: UIColor = color
        switch sender {
        case redSlider: newColor = UIColor(red: CGFloat(redSlider.value), green: orgRgb.g, blue: orgRgb.b, alpha: orgRgb.a)
        case greenSlider: newColor = UIColor(red: orgRgb.r, green: CGFloat(greenSlider.value), blue: orgRgb.b, alpha: orgRgb.a)
        case blueSlider: newColor = UIColor(red: orgRgb.r, green: orgRgb.g, blue: CGFloat(blueSlider.value), alpha: orgRgb.a)
        case alphaSlider: newColor = UIColor(red: orgRgb.r, green: orgRgb.g, blue: orgRgb.b, alpha: CGFloat(alphaSlider.value))
        default: break
        }
        self.color = newColor
        delegate?.receiveUpdatedColor(color: newColor)
        self.updateColorLabels()
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

public protocol ColorViewControllerDelegate {
    func currentColor() -> UIColor
    func receiveUpdatedColor(color: UIColor)
}
