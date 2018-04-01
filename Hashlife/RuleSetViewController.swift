//
//  RuleSetViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/29/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class RuleSetViewController: UIViewController, RuleSetTableViewControllerDelegate {

    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var useCustomRuleSetSwitch: UISwitch!
    @IBOutlet weak var customRuleTableContainer: UIView!

    var tableViewController: RuleSetTableViewController {
        return self.childViewControllers[0] as! RuleSetTableViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateRuleSetControls()
        // Do any additional setup after loading the view.
    }
    
    private func updateRuleSetControls() {
        switch Universe.ruleSet {
        case .default: useCustomRuleSetSwitch.isOn  = false
        default: useCustomRuleSetSwitch.isOn = true
        }
        
        self.ruleLabel.text = Universe.ruleSet.description
        customRuleTableContainer.isUserInteractionEnabled = useCustomRuleSetSwitch.isOn
        tableViewController.shouldApplyChanges = useCustomRuleSetSwitch.isOn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func useCustomRuleSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            let rule = tableViewController.ruleSet
            Universe.ruleSet = .custom(livingRule: rule.living, bornRule: rule.born)
        } else {
            Universe.ruleSet = .default
        }
        self.updateRuleSetControls()
    }
    
    func ruleSetDidUpdate(living: [Int], born: [Int]) {
        Universe.ruleSet = .custom(livingRule: living, bornRule: born)
        self.updateRuleSetControls()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.updateRuleSetControls()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tvc = segue.destination as? RuleSetTableViewController {
            tvc.delegate = self
        }
    }


}
