//
//  InstrumentationTableViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/28/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class InstrumentationTableViewController: UITableViewController {
    
    var universeViewController: UniverseViewController {
        return self.tabBarController!.viewControllers![0] as! UniverseViewController
    }
    
    let headers = [
        "", "Appearance", "Control", "Overlay", "Others"
    ]
    
    let data = [
        ["Action"],
        ["Gradient Fill", "Grid", "Cell", "Background"],
        ["Mode", "Auto Speed", "Custom Rules"],
        ["Overlay Statistics", "Overlay Controls"],
        ["Update Stats","Brush Size"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return headers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data[section].count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = data[indexPath.section][indexPath.row]
        var identifier = ""
        switch name {
        case "Custom Rules", "Auto Speed", "Gradient Fill": identifier = "segueCell"
        case "Grid", "Cell", "Background": identifier = "colorSegueCell"
        case "Brush Size", "Mode", "Action" : identifier = "segementedControlCell"
        default: identifier = "toggleItemCell"
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        if let namedCell = cell as? NamedTableViewCell {
            namedCell.nameLabel.text = name
        }

        if let toggleCell = cell as? ToggleTableViewCell, let uvc = tabBarController!.viewControllers![0] as? UniverseViewController {
            switch name {
            case "Overlay Statistics":
                toggleCell.switch.isOn = !uvc.generationLabel.isHidden
                toggleCell.switchToggled = {
                    uvc.generationLabel.isHidden = !$0
                    uvc.generationStaticLabel.isHidden = !$0
                    uvc.populationLabel.isHidden = !$0
                    uvc.populationStaticLabel.isHidden = !$0
                }
            case "Overlay Controls":
                toggleCell.switch.isOn = !uvc.actionSegmentedControl.isHidden
                toggleCell.switchToggled = {
                    uvc.modeSegmentedControl.isHidden = !$0
                    uvc.actionSegmentedControl.isHidden = !$0
                }
            case "Update Stats":
                toggleCell.switch.isOn = StatisticsViewController.shouldUpdateStatistics
                toggleCell.switchToggled = {
                    StatisticsViewController.shouldUpdateStatistics = $0
                }
            default: break
            }
        } else if let segueCell = cell as? SegueTableViewCell {
            switch name {
            case "Custom Rules": segueCell.stateLabel.text = Universe.ruleSet.isDefault() ? "Disabled" : "Enabled"
            case "Auto Speed": segueCell.stateLabel.text = UniverseSimulator.sharedInstance.autoSpeed ? "Enabled" : "Disabled"
            case "Gradient Fill": segueCell.stateLabel.text = UniverseView.gradientFill ? "On" : "Off"
            default: break
            }
        } else if let colorSegueCell = cell as? ColorSegueTableViewCell {
            switch name {
            case "Grid", "Cell", "Background": colorSegueCell.colorView.backgroundColor = (self.extractProperty(name))
            default: break
            }
        } else if let segmentedControlCell = cell as? SegmentedControlTableViewCell {
            switch name {
            case "Brush Size":
                segmentedControlCell.segmentedControl.selectedSegmentIndex = UniverseViewController.brushScale
                segmentedControlCell.segmentedControlChanged = {(i, _) in
                    UniverseViewController.brushScale = i
                }
            case "Mode":
                let control = segmentedControlCell.segmentedControl!
                control.setTitle("Pan", forSegmentAt: 0)
                control.setTitle("Draw", forSegmentAt: 1)
                control.setTitle("Erase", forSegmentAt: 2)
                switch universeViewController.mode {
                case .draw: control.selectedSegmentIndex = 1
                case .pan: control.selectedSegmentIndex = 0
                case .erase: control.selectedSegmentIndex = 2
                }
                segmentedControlCell.segmentedControlChanged = {[unowned self] (_, title) in
                    self.universeViewController.setMode(title)
                }
            case "Action":
                let control = segmentedControlCell.segmentedControl!
                control.isMomentary = true
                control.selectedSegmentIndex = -1
                control.setTitle("Clear", forSegmentAt: 1)
                control.setTitle("Random", forSegmentAt: 0)
                let simulatorIsRunning = UniverseSimulator.sharedInstance.stepTimer != nil
                let titleForSegment = simulatorIsRunning ? "Stop" : "Start"
                control.setTitle(titleForSegment, forSegmentAt: 2)
                segmentedControlCell.segmentedControlChanged = {[unowned control, unowned self] (i, title) in
                    if i == 2 {
                        control.setTitle(title == "Start" ? "Stop" : "Start", forSegmentAt: i)
                    }
                    self.universeViewController.performAction(title)
                }
            default: break
            }
            
        }

        return cell
    }

    public override func performSegue(withIdentifier identifier: String, sender: Any?) {
        super.performSegue(withIdentifier: identifier, sender: sender)
    }

    private func extractProperty(_ identifier: String) -> UIColor? {
        if let vc = self.tabBarController {
            if let uvc = vc.viewControllers![0] as? UniverseViewController {
                switch identifier {
                case "Grid": return uvc.universeView.gridColor
                case "Cell": return uvc.universeView.aliveColor
                case "Background": return uvc.universeView.backgroundColor
                default: return nil
                }
            }
        }
        return nil
    }


    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch data[indexPath.section][indexPath.row] {
        case "Custom Rules": performSegue(withIdentifier: "customRulesSegue", sender: self)
        case "Auto Speed": performSegue(withIdentifier: "autoSpeedSegue", sender: self)
        case "Grid": performSegue(withIdentifier: "gridSegue", sender: self)
        case "Cell": performSegue(withIdentifier: "cellSegue", sender: self)
        case "Background": performSegue(withIdentifier: "backgroundSegue", sender: self)
        case "Auto Speed": performSegue(withIdentifier: "autoSpeedSegue", sender: self)
        case "Gradient Fill": performSegue(withIdentifier: "gradientFillSegue", sender: self)
        default: break
        }
//        super.didSet
    }

    private func extractUniverseView() -> UniverseView {
        return universeViewController.universeView
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let targetViewController = segue.destination as? TargetViewController {
            targetViewController.target = self.extractUniverseView()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
}
