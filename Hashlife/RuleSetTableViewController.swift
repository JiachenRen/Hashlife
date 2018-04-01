//
//  RuleSetTableViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/29/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class RuleSetTableViewController: UITableViewController {
    var delegate: RuleSetTableViewControllerDelegate?
    
    var shouldApplyChanges: Bool = false {
        didSet {
            self.tableView.reloadData()
        }
    }
    var ruleSet: (living: [Int], born: [Int]) = (living: [2,3], born: [3]) {
        didSet {
            delegate?.ruleSetDidUpdate(living: ruleSet.living, born: ruleSet.born)
        }
    }

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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 9
    }

    //July 30th: made it a trillion times more concise.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toggleItemCell", for: indexPath) as! ToggleTableViewCell
        let num = indexPath.row + 1
        cell.nameLabel.text = String(num)
        cell.switch.isEnabled = self.shouldApplyChanges
        cell.nameLabel.isEnabled = self.shouldApplyChanges
        let isLivingRule = indexPath.section == 0
        cell.switch.isOn = (isLivingRule ? ruleSet.living : ruleSet.born).contains(num)
        cell.switchToggled = {[unowned self] in
            self.processRuleSet(num, isOn: $0, livingRule: isLivingRule)
        }
        return cell
    }
    
    private func processRuleSet(_ digit: Int, isOn: Bool, livingRule: Bool) {
        var src = livingRule ? self.ruleSet.living : self.ruleSet.born
        if isOn {if !src.reduce(false){$0 || $1 == digit} {src.append(digit)}}
        else {src = src.filter{$0 != digit}}
        self.ruleSet = livingRule ? (living: src.sorted(by: <), born: ruleSet.born)
            : (living: ruleSet.living, born: src.sorted(by: <))
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Living Rule" : "Born Rule"
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol RuleSetTableViewControllerDelegate {
    func ruleSetDidUpdate(living: [Int], born: [Int])
}

