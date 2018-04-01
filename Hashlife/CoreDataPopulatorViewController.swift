//
//  CoreDataPopulatorViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 8/1/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class CoreDataPopulatorViewController: UIViewController, CoreDataPopulatorDelegate {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var numFilesProcessedLabel: UILabel!
    var refreshTimer: Timer?
    var delegate: CDPControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this only happens once after the app is installed.
        
        if let index = retrieveFromUserDefualt(key: "ConstructedIntex") as? Int   {
            //if did not finish constructing the first time, resume.
            CoreDataPopulator.delegate = self
            DispatchQueue.global().async {
                CoreDataPopulator.populate(startIndex: index + 1)
            }
        } else {
            CoreDataPopulator.delegate = self
            DispatchQueue.global().async {
                CoreDataPopulator.populate(startIndex: 0)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func didFinishDataBaseConstruction() {
        saveToUserDefault(obj: true, key: "Database Constructed")
        self.refreshTimer?.invalidate()
        delegate?.didFinish()
    }
    
    func didUpdate(currentFile: Int, numberOfFiles: Int) {
        DispatchQueue.main.async {
            self.progressView.progress = Float(currentFile) / Float(numberOfFiles)
            self.numFilesProcessedLabel.text = "\(currentFile) of \(numberOfFiles)"
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

protocol CDPControllerDelegate {
    func didFinish() -> Void
}
