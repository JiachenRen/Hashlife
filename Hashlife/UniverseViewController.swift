//
//  ViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/22/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit
import AVFoundation

let simulatorUpdateNotification = Notification.Name("simulatorUpdateNotification")
let viewPortUpdatedNotification = Notification.Name("viewPortUpdatedNotification")

@IBDesignable class UniverseViewController: UIViewController, SimulatorDelegate {

    @IBInspectable var pinchSmoothFactor: CGFloat = 0.85
    @IBInspectable var panSmoothFactor: CGFloat = 0.8
    @IBInspectable var animationTimeout: CGFloat = 1
    @IBInspectable var animationInterval: Double = 0.015

    @IBOutlet weak var populationStaticLabel: UILabel!
    @IBOutlet weak var mpfLabel: UILabel!
    @IBOutlet weak var dimensionLabel: UILabel!
    @IBOutlet weak var populationLabel: UILabel!
    
    @IBOutlet weak var generationStaticLabel: UILabel!
    @IBOutlet weak var generationLabel: UILabel!
    @IBOutlet weak var universeView: UniverseView!

    @IBOutlet weak var tapToDropLabel: UILabel!
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var actionSegmentedControl: UISegmentedControl!
    
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet var oneFingerPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var twoFingerPanGestureRecognizer: UIPanGestureRecognizer!
    
    var timeRecognized: Millis?
    var timeForTakingEffect: Millis = 500
    var pendingCoordinates: [Coordinate]?

    let minSimulatorTimerInterval = 0.001
    let maxSimulatorTimerInterval: Double = 1

    var simulator: UniverseSimulator {
        return UniverseSimulator.sharedInstance
    }

    static var brushScale: Int = 0
    var mode: Mode = .pan

    public enum Mode {
        case pan
        case draw
        case erase
    }

    private func spawnRandomCells(num: Int, rangeX: Int, rangeY: Int) {
        for _ in 0..<num {
            let pos = randomCoordinate(rangeX: rangeX, rangeY: rangeY)
            simulator.universe.setNodeAt(x: pos.x, y: pos.y, to: true)
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
        // Dispose of any resources that can be recreated.
    }

    //should automatically adjust speed.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
        simulator.delegate = self
        universeView.delegate = self
        universeView.backgroundColor = .white
        tapToDropLabel?.isHidden = true
        
        simulator.stepPerFrame = 1
        simulator.autoSpeed = true

        //loadFrom(url: "http://www.jiachenren.com/index.html")
        self.simulatorDidUpdate()

        //additional setup for hidden labels.
        setupOverlayStatsLabels()
    }

    public func setupOverlayStatsLabels() {
        mpfLabel.isHidden = true
        dimensionLabel.isHidden = true
    }

    public func updateOverlayStatsLabels() {
        self.generationLabel.text = String(describing: simulator.universe.numGen)
        self.populationLabel.text = String(format:"%g", simulator.universe.root.pop)
    }

    public func updateDimensionLabel() {
        let vp = universeView.getUniverseViewPort()
        dimensionLabel.isHidden = false
        dimensionLabel.text = "\(vp.cols) x \(vp.rows)"
        NotificationCenter.default.post(name: viewPortUpdatedNotification, object: vp)
    }

    public func setupGestureRecognizers() {
        self.longPressGestureRecognizer.minimumPressDuration = 0.4
        self.oneFingerPanGestureRecognizer.maximumNumberOfTouches = 1
        self.twoFingerPanGestureRecognizer.minimumNumberOfTouches = 2
        self.twoFingerPanGestureRecognizer.maximumNumberOfTouches = 2
    }

    //zooming in and out the universe view
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        let center = sender.location(in: self.universeView)
        self.updateDimensionLabel()
        if let view = sender.view as? UniverseView {
            view.respondTo(scale: sender.scale, at: center)
            if sender.state == .ended {
                dimensionLabel.isHidden = true
                view.zoomVelocity = sender.velocity * CGFloat(animationInterval) //since velocity is scale factor per 1s, we need to map it to the timer which executes <#animationInterval#> per second.
                let timer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { [unowned self] _ in
                    let _ = view.zoomVelocity *= self.pinchSmoothFactor //smoothing factor.
                    view.respondTo(scale: 1 + view.zoomVelocity, at: center)
                }
                let _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(animationTimeout), repeats: false) { _ in
                    timer.invalidate()
                }
            }
        }

        sender.scale = 1 //continuously resets the scale.
    }


    var lastPanTranslation = CGPoint(x: 0, y: 0)

    //dragging and moving in the universe view. Smooth animation made easy with my Vec2D library!
    @IBAction func handleOneFingerPan(_ sender: UIPanGestureRecognizer) {
        let posInView = universeView.posInUniverse(from: sender.location(in: self.universeView))
        let coordinate = universeView.convertToNodePos(from: posInView)
        switch self.mode {
        case .pan: self.pan(sender)
        case .draw: self.setNodes(at: coordinate, to: true, range: UniverseViewController.brushScale)
        case .erase: self.setNodes(at: coordinate, to: false, range: UniverseViewController.brushScale)
        }
    }

    public func setNodes(at loc: Coordinate, to alive: Bool, range: Int) {
        for r in -range...range {
            for c in -range...range {
                self.simulator.setNode(at: (x: loc.x + c, y: loc.y + r), to: alive)
            }
        }
    }

    private func pan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.universeView)
        if !translation.equalTo(CGPoint(x: 0, y: 0)) {
            lastPanTranslation = translation
        }

        if let view = sender.view as? UniverseView {
            view.respondTo(translation: translation)
            if sender.state == .ended {
                view.panAcc = Vec2D(point: lastPanTranslation).mult(0.95) //adjust inital speed
                let timer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { [unowned self] _ in
                    let _ = view.panAcc.mult(self.panSmoothFactor) //slow it down gradually
                    view.respondTo(translation: view.panAcc.cgPoint)
                } //will this produce memory leak?
                let _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(animationTimeout), repeats: false) { _ in
                    timer.invalidate()
                }
            }
        }
        //resetting the translation
        sender.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
    }

    var twoFingerPanCanceled: Bool = false

    @IBAction func handleTwoFinderPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            if abs(sender.location(ofTouch: 0, in: universeView).y - sender.location(ofTouch: 1, in: universeView).y) > 100 {
                twoFingerPanCanceled = true
                return
            } else {
                mpfLabel.isHidden = false
                Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [unowned self, weak sender] timer in
                    self.universeView.setNeedsDisplay()
                    if sender == nil || sender!.state.rawValue == 0 || self.twoFingerPanCanceled {
                        self.mpfLabel.isHidden = true
                        timer.invalidate()
                    }
                }
                twoFingerPanCanceled = false
            }
        }
        if twoFingerPanCanceled {
            return
        }
        let offset = -sender.translation(in: self.universeView).y / universeView.bounds.height
        var interval = simulator.stepTimerInterval - Double(offset)
        interval = interval < minSimulatorTimerInterval ? minSimulatorTimerInterval : interval > maxSimulatorTimerInterval ? maxSimulatorTimerInterval : interval
        simulator.setStepInterval(s: interval)
        let speedPercentage = self.simulatorSpeedPercentage()
        mpfLabel.text = "\(Int(1 / simulator.stepTimerInterval)) fps, \(Int(speedPercentage * 100))%"
        sender.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
    }


    public func simulatorDidUpdate() {
        //asks the universe view for the nodes that are currently on screen.
        let univViewPort = self.universeView.getUniverseViewPort()

        //ask the universe to get living cells only in the finite view port, since the universe itself is infinite.
        //NOTE: the universe uses a highly optimized recursive method to skip blank areas. (which is supposed to work)
        let root = self.simulator.universe.extractRoot(from: univViewPort)

        //notify the universe view of the change, which further optimizes the information for drawing.
        self.universeView.receiveUpdatedRoot(root)

        //update UI labels
        self.updateOverlayStatsLabels()
        
        //update statistics tab if enabled
        if StatisticsViewController.shouldUpdateStatistics {
            NotificationCenter.default.post(name: simulatorUpdateNotification, object: self.simulator)
        }
    }

    //toggle timed refresh
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            universeView.longPressCanceled = false
            timeRecognized = Date().millisecondsSince1970
            Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [unowned self] timer in
                self.universeView.setNeedsDisplay()
                if self.timeRecognized == nil || Date().millisecondsSince1970 - self.timeRecognized! > self.timeForTakingEffect {
                    timer.invalidate()
                }
            }

        } else if sender.state == .ended {
            universeView.longPressCanceled = true
        }
    }

    /// This is for communication between different VCs that are holders of UV.
    public func alignUniverseViewContstraints(with view: UniverseView) {
        self.universeView.ctr = view.ctr
        self.universeView.initialCellSize = view.initialCellSize
        self.universeView.respondTo(scale: 1, at: CGPoint(x: 0, y: 0))
    }

    ///Communicate back the user interaction to the simulator.
    ///- Note: Should be in extension, but method needs to be overriden by subclass.
    public func didTouch(at loc: Coordinate) {
        tapToDropLabel?.isHidden = true
        if let coordinates = pendingCoordinates {
            coordinates.forEach {
                self.simulator.setNode(at: (x: loc.x + $0.x, y: loc.y + $0.y), to: true)
            }
        } else {
            simulator.toggleNode(at: loc)
        }
    }
    

    @IBAction func modeSegmentControlTapped(_ sender: UISegmentedControl) {
        self.setMode(sender.titleForSegment(at: sender.selectedSegmentIndex)!)
    }
    
    @IBAction func actionSegmentedControlChanged(_ sender: UISegmentedControl) {
        self.performAction(sender.titleForSegment(at: sender.selectedSegmentIndex)!)
    }
    
    public func performAction(_ action: String) {
        switch action {
        case "Clear": self.simulator.clear()
        case "Step": self.simulator.step()
        case "Discard": self.pendingCoordinates = nil
        case "Start": self.simulator.start()
        case "Stop": self.simulator.stop()
        case "Random":
            let vp = self.universeView.getUniverseViewPort()
            self.spawnRandomCells(num: Int(vp.numCells()) / 3, rangeX: vp.cols, rangeY: vp.rows)
            self.universeView.ctr = CGPoint(x: universeView.bounds.midX, y: universeView.bounds.midY)
            self.simulatorDidUpdate() //I know it shouldn't be done this way, but simple fix...
        default: break
        }
    }
    
    public func setMode(_ mode: String) {
        switch mode {
        case "Pan": self.mode = .pan
        case "Draw": self.mode = .draw
        case "Erase": self.mode = .erase
        default: break
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        UniverseSimulator.sharedInstance.stop()
    }
}


extension UniverseViewController: UniverseViewDelegate {

    ///Tell the simulator to step when user touches with two fingers.
    public func didTouchWithTwoFingers() {
        simulator.step()
    }

    public func hasRecognizedLongPress() -> Bool {
        return timeRecognized != nil
    }

    public func longPressCompletionInfo() -> (percentage: CGFloat, center: CGPoint) {
        return (percentage: CGFloat(Date().millisecondsSince1970 - timeRecognized!) / CGFloat(timeForTakingEffect), center: longPressGestureRecognizer.location(in: universeView))
    }

    public func longPressCompleted() {
        timeRecognized = nil
        self.simulator.stepTimer == nil ? simulator.start() : simulator.stop()
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    public func twoFingerPanIsInProgress() -> Bool {
        if twoFingerPanGestureRecognizer == nil {return false}
        return twoFingerPanGestureRecognizer.state == .changed && !twoFingerPanCanceled
    }

    public func simulatorSpeedPercentage() -> CGFloat {
        return 1 - CGFloat((simulator.stepTimerInterval - minSimulatorTimerInterval) / (maxSimulatorTimerInterval - minSimulatorTimerInterval))
    }
    
    //Thanks god that I know something about color scheme!
    public func backgroundColorDidChange(color: UIColor) {
        let rgb = color.rgb()
        let reversedColor = UIColor(red: 1 - rgb.r, green: 1 - rgb.g, blue: 1 - rgb.b, alpha: 1)
        self.generationStaticLabel?.textColor = reversedColor
        self.populationStaticLabel?.textColor = reversedColor
        self.mpfLabel?.textColor = reversedColor
        self.dimensionLabel?.textColor = reversedColor
        self.tapToDropLabel?.textColor = reversedColor
        modeSegmentedControl?.backgroundColor = color.withAlphaComponent(0.75)
        actionSegmentedControl?.backgroundColor = color.withAlphaComponent(0.75)
        modeSegmentedControl?.tintColor = reversedColor.withAlphaComponent(0.85)
        actionSegmentedControl?.tintColor = reversedColor.withAlphaComponent(0.85)
        
        if UniverseView.gradientFill {
            self.universeView.symbolUniversalTint = reversedColor.withAlphaComponent(0.85)
        }
        
        let scrambledColor = UIColor(red: 1 - rgb.g, green: 1 - rgb.b, blue: 1 - rgb.r, alpha: 1)
        self.populationLabel?.textColor = scrambledColor
        self.generationLabel?.textColor = scrambledColor
    }

    public func cellColorDidChange(color: UIColor) {
//        let rgb = color.rgb()
        
    }
}
