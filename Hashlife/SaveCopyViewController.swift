//
//  SaveCopyViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 8/1/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class SaveCopyViewController: UIViewController {

    @IBOutlet weak var patternStatusLabel: UILabel!
    @IBOutlet weak var authorStatusLabel: UILabel!
    @IBOutlet weak var ruleSetStatusLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //name, author, rule, description, shouldSave
    var saveCompletionClosure: (( String, String, String, String, Bool) -> Void)?
    
    //default rule is good. Thus this property should be initialized to true.
    var isValidRule = true {
        willSet {
            saveButton.isEnabled = newValue
            ruleSetStatusLabel.textColor = newValue ? UIColor.black : UIColor.red
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func patternNameTextFieldEdited(_ sender: UITextField) {
        patternStatusLabel.text = sender.text
    }
    
    
    @IBAction func authorTextFieldEdited(_ sender: UITextField) {
        authorStatusLabel.text = sender.text
    }
    
    @IBAction func ruleSetTextFieldEdited(_ sender: UITextField) {
        if sender.text!.contains("~") {
            ruleSetStatusLabel.text = "23/3"
            isValidRule = true
        } else if !sender.text!.contains("/") {
            isValidRule = false
        } else {
            let filtered = sender.text!
                .map{$0 == "/" ? -1 : Int(String(describing: $0))}
                .filter{$0 != nil} //cannot combine because compiler too stupid to infer
            sender.text = filtered.map{$0! == -1 ? "/" : String($0!)}
                .reduce(""){$0 + $1}
            ruleSetStatusLabel.text = sender.text
            isValidRule = true
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        saveCompletionClosure?("","","","",false)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveCompletionClosure?(self.patternStatusLabel.text!, self.authorStatusLabel.text!, ruleSetStatusLabel.text!, descriptionTextView.text!, true)
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
