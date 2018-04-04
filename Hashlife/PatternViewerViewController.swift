//
//  PatternEditorViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/26/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class PatternViewerViewController: UIViewController, SimulatorDelegate {
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var universeView: UniverseView!
    var simulator: UniverseSimulator!
    var mgr: CoordinateManager!
    var pattern: Pattern?
    
    // for the network fetcher.
    var patternTitle: String?
    var patternDescription: String?
    var author: String?
    
    var shouldReloadSimulator = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let pattern = self.pattern {
            applyBasicPatternInfo(title: pattern.title, author: pattern.author, rule: pattern.rule, overview: pattern.overview)
            self.mgr = CoordinateManager(zip(pattern.xCoordinates as! [Int], pattern.yCoordinates as! [Int]).map{(x: $0.0, y: $0.1)}) //setup coordinate manager
        } else {
            applyBasicPatternInfo(title: patternTitle, author: author, rule: "23/3(Default)", overview: patternDescription)
        }
    }
    
    private func applyBasicPatternInfo(title: String?, author: String?, rule: String?, overview: String?) {
        self.authorLabel.text = "Author:\t\(author ?? "Unknown")"
        self.descriptionTextView.text = overview
        self.nameLabel.text = "Name:\t\(title ?? "Anonymous")"
        self.ruleLabel.text = rule == "~" ? "" : rule
    }

    private func reloadSimulator() {
        //set up the simulator for viewing.
        self.simulator = UniverseSimulator()
        simulator.delegate = self
        simulator.load(coordinates: mgr.coordinates)
    }

    private func setupUniverseViewPort() {
        //detect the maximum row and col. Set the translation for ctr so that the pattern is centered.
        let h = universeView.frame.height, w = universeView.frame.width
        let cw = w / CGFloat(mgr.cols + 3) //cell width from width TODO: debug
        let ch = h / CGFloat(mgr.rows + 3) //cell width from height
        universeView.initialCellSize = cw < ch ? cw : ch
        let vp = self.universeView.getUniverseViewPort()
        let translated = CGPoint(x: (w - CGFloat(mgr.cols) / CGFloat(vp.cols - 1) * w) / 2, y: (h - CGFloat(mgr.rows) / CGFloat(vp.rows - 1) * h) / 2)
        universeView.ctr = translated

        universeView.respondTo(scale: 1.0, at: CGPoint(x: 0, y: 0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PatternEditorViewController {
            vc.editor = self.simulator
            vc.coordinateMgr = self.mgr
            vc.targetView = self.universeView
            self.shouldReloadSimulator = true //should reload the simulator after user edits the grid.
        }
    }

    //Took me about two hours to find this bug!!! I originally placed the following code in view will appear.
    override func viewDidLayoutSubviews() {
        self.reloadSimulator()
        self.setupUniverseViewPort()
        self.simulatorDidUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !shouldReloadSimulator {return} //only reload when changed.
        self.reloadSimulator()
        self.setupUniverseViewPort()
        self.simulatorDidUpdate()
        self.shouldReloadSimulator = false
    }


    public func simulatorDidUpdate() {
        let univViewPort = self.universeView.getUniverseViewPort()
        let root = self.simulator.universe.extractRoot(from: univViewPort)
        self.universeView.receiveUpdatedRoot(root)
    }

    @IBAction func loadButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.modalPresentationStyle = .popover
        let insertAction = UIAlertAction(title: "Insert Into Existing Universe", style: .default, handler: { (alert: UIAlertAction!) in
            print("Insert action requested")
            if let controller = self.tabBarController {
                controller.selectedIndex = 0
                
                if let uvc = controller.viewControllers![0] as? UniverseViewController {
                    uvc.pendingCoordinates = self.mgr.coordinates
                    uvc.tapToDropLabel.isHidden = false
                    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
                        uvc.tapToDropLabel.isHidden = true
                        timer.invalidate()
                    }
                }
            }
        })
        alertController.addAction(insertAction)

        //when overriding with a different rule set, the default rule set will be overridden
        let overrideAction = UIAlertAction(title: "Override Existing Universe", style: .default, handler: { (alert: UIAlertAction!) in
            print("Override action requested")
            //self.dismiss(animated: true) //fixed!

            //updates the UniverseViewController's view with the designated one.
            if let controller = self.tabBarController {
                UniverseSimulator.sharedInstance.universe = self.simulator.universe

                //prevent changes in the universe simulator to be applied to pattern.
                //self.reloadSimulator()
                
                controller.selectedIndex = 0
                
                //apply the current universe view port
                if let universeViewController = controller.viewControllers?[0] as? UniverseViewController {
                    universeViewController.alignUniverseViewContstraints(with: self.universeView)
                }
                
            }

            //updates global game of life rule set
            if let rule = self.pattern?.rule {
                switch Universe.ruleSet {
                case .default where rule == "~":
                    break
                default:
                    if rule == "~" {
                        Universe.ruleSet = .default
                        break
                    }
                    let ruleSet = UniverseSimulator.interpret(rule: rule)
                    print(ruleSet)
                    let wrapped: Universe.RuleSet = .custom(livingRule: ruleSet.living, bornRule: ruleSet.born)
                    if !(Universe.ruleSet == wrapped) {
                        Universe.ruleSet = wrapped
                    }
                }
            }
        })
        
        alertController.addAction(overrideAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) in
            print("Action canceled")
            //TODO: implement
        })
        alertController.addAction(cancelAction)

        //iPad crash fixed August 18th 9:10:31 PM.
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = universeView
            presenter.sourceRect = universeView.bounds
        }
        present(alertController, animated: true, completion: nil)
        
    }


    @IBAction func touchOnUniverseView(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "editSegue", sender: self)
    }
}
