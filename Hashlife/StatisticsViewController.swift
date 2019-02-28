//
//  StatisticsViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/30/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController{

    @IBOutlet weak var populationGraphView: GraphView!
    @IBOutlet weak var calcDurationGraphView: GraphView!
    @IBOutlet weak var emptyNodesGraphView: GraphView!
    
    @IBOutlet weak var populationLabel: UILabel!
    @IBOutlet weak var generationLabel: UILabel!
    @IBOutlet weak var ruleSetLabel: UILabel!
    @IBOutlet weak var calcDurationLabel: UILabel!
    @IBOutlet weak var rootLevelLabel: UILabel!
    @IBOutlet weak var emptyNodesLabel: UILabel!
    @IBOutlet weak var cachedResultsLabel: UILabel!
    @IBOutlet weak var windowLabel: UILabel!
    
    static var shouldUpdateStatistics = false //this should default to false
    var appearedForTheFirstTime = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNotificationListener()
        emptyNodesGraphView.dataSet.maxNumData = 50
        populationGraphView.dataSet.maxNumData = 150
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func setupNotificationListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatistics(notification:)), name: simulatorUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateRuleSetLabel), name: ruleSetUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWindowLabel(notification:)), name: viewPortUpdatedNotification, object: nil)
    }
    
    //TODO: add stepSize!
    @objc func updateStatistics(notification: Notification) {
        let simulator = notification.object as! UniverseSimulator
        
        let pop = CGFloat(simulator.universe.root.pop) //I am using float to prevent overflow of integer.
        self.populationGraphView.dataSet.add(CGFloat(pop))
        self.populationLabel.text = String(format: "%g", pop)
        
        let gen = CGFloat(simulator.universe.numGen.intValue)
        self.generationLabel.text = String(Int(gen))
        
        let rootLevel = simulator.universe.root.lev
        self.rootLevelLabel.text = String(rootLevel)
        
        let emptyNodes = pow(2, rootLevel * 2).intValue - Int(pop)
        self.emptyNodesLabel.text = String(describing: emptyNodes)
        emptyNodesGraphView.dataSet.add(CGFloat(emptyNodes))
//        emptyNodesGraphView.dataSet.min = {_ in 0}
        
        // let hashMapCount = HashedTreeNode.hashMap.count
        self.cachedResultsLabel.text = String("???")
        
        if let calcDuration = simulator.millisPerIteration {
            self.calcDurationLabel.text = String("\(calcDuration) ms")
            self.calcDurationGraphView.dataSet.add(CGFloat(calcDuration))
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if appearedForTheFirstTime == false {
            StatisticsViewController.shouldUpdateStatistics = true
            UniverseSimulator.sharedInstance.start()
            appearedForTheFirstTime = true
        }
    }
    
    @objc func updateRuleSetLabel() {
        self.ruleSetLabel.text = Universe.ruleSet.description
    }

    @objc func updateWindowLabel(notification: Notification) {
        let viewPort = notification.object as! UniverseViewPort
        self.windowLabel.text = "\(viewPort.cols) x \(viewPort.rows)"
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
