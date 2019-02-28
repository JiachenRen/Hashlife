//
//  PatternsViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/26/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class PatternsRootViewController: UIViewController, CDPControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if retrieveFromUserDefualt(key: "Database Constructed") == nil {
            self.performSegue(withIdentifier: "coreDataPopulatorSegue", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func networkButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    func didFinish() {
        let ptvc = (self.children[0] as! PatternsTableViewController)
        typealias PTVC = PatternsTableViewController
        ptvc.patterns = (try? PTVC.context.fetch(Pattern.fetchRequest()))!
        DispatchQueue.main.sync {
            ptvc.tableView.reloadData()
            ptvc.viewDidLoad()
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PatternEditorViewController {
            vc.editor = UniverseSimulator() //TODO: debug
            vc.coordinateMgr = CoordinateManager([])
            vc.targetView = nil //in this case, no target view because user is making it.
        } else if let cdp = segue.destination as? CoreDataPopulatorViewController {
            cdp.delegate = self
        }
    }
    

}
