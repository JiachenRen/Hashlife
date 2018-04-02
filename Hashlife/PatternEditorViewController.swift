//
//  PatternEditorViewController.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/27/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class PatternEditorViewController: UniverseViewController {

    //this property is initialized by the sender of the segue (PatternViewerViewController)
    var editor: UniverseSimulator?

    //the target universe view that is used to reconstruct the new one.
    var targetView: UniverseView?

    var coordinateMgr: CoordinateManager?

    //overrides so that the superclass would be manipulating a different simulator.
    override var simulator: UniverseSimulator {
        return editor!
    }

    override func viewDidLoad() {
        if let view = targetView {
            self.alignUniverseViewContstraints(with: view)
        }
        super.viewDidLoad()
        self.updateDimensionLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func setupGestureRecognizers() {
        self.oneFingerPanGestureRecognizer.maximumNumberOfTouches = 1
    }

    override func updateOverlayStatsLabels() {
        return
    }

    override func setupOverlayStatsLabels() {
        return
    }

    override func simulatorDidUpdate() {
        super.simulatorDidUpdate()

    }

    @IBAction func transformSegmentedControlTapped(_ sender: UISegmentedControl) {
        var action: CoordinateManager.Action?
        switch sender.titleForSegment(at: sender.selectedSegmentIndex)! {
        case "Rotate": action = .rotate
        case "V Flip": action = .verticalFlip
        case "H Flip": action = .horizontalFlip
        default: break
        }
        coordinateMgr!.transform(by: action!)
        self.simulator.clear()
        self.simulator.load(coordinates: coordinateMgr!.coordinates)
        self.updateDimensionLabel()
    }


    public override func updateDimensionLabel() {
        dimensionLabel.text = "\(coordinateMgr!.cols) x \(coordinateMgr!.rows)"
    }

    public override func didTouch(at loc: Coordinate) {
        super.didTouch(at: loc)
        coordinateMgr?.toggle(loc)
    }

    public override func setNodes(at loc: Coordinate, to alive: Bool, range: Int) {
        super.setNodes(at: loc, to: alive, range: range)
        for r in -range...range {
            for c in -range...range {
                self.coordinateMgr!.set((x: loc.x + c, y: loc.y + r), to: alive)
            }
        }
    }

    public override func handlePinch(_ sender: UIPinchGestureRecognizer) {
        super.handlePinch(sender)
        self.dimensionLabel.isHidden = false
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        self.coordinateMgr?.updateCoordinates()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController {
            if let saveCopyViewController = nav.viewControllers.first as? SaveCopyViewController {
                saveCopyViewController.saveCompletionClosure = {[unowned self] (title, author, rule, description, shouldSave) in
                    if !shouldSave {
                        self.dismiss(animated: true)
                        return
                    }
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let pattern = Pattern(context: context) // Link Task & Context
                    pattern.xCoordinates = self.coordinateMgr!.coordinates.map{$0.x} as NSObject
                    pattern.yCoordinates = self.coordinateMgr!.coordinates.map{$0.y} as NSObject
                    pattern.title = title
                    pattern.author = author
                    pattern.rule = rule
                    pattern.overview = description
                    (UIApplication.shared.delegate as! AppDelegate).saveContext() //how to re-order?
                    self.dismiss(animated: true)
                    
                    //apply changes to the table view controller... doesn't look like good practice...
                    ((self.navigationController?.viewControllers[0] as! PatternsRootViewController)
                        .childViewControllers[0] as! PatternsTableViewController).add(pattern, at: IndexPath(row: 0, section: 0))
                    
                    //if changes saved, pop the editor.
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    

}

public class CoordinateManager {
    var coordinates: [Coordinate]
    var rows: Int = 0
    var cols: Int = 0

    public enum Action {
        case rotate
        case verticalFlip
        case horizontalFlip
    }

    required public init(_ coordinates: [Coordinate]) {
        self.coordinates = coordinates
        if coordinates.count > 1 {
            let extrapolated = extrapolateDimension()
            self.rows = extrapolated.rows
            self.cols = extrapolated.cols
        }
    }

    //faster version of updateCoordinates()
    private func extrapolateDimension() -> (rows: Int, cols: Int) {
        let maxColRow = coordinates.reduce((x: Int.min, y: Int.min)) { (old, cur) in
            return (x: cur.x > old.x ? cur.x : old.x, y: cur.y > old.y ? cur.y : old.y)
        }
        return (rows: maxColRow.y, cols: maxColRow.x)
    }


    public func transform(by action: Action) {
        self.updateCoordinates()
        switch action {
        case .rotate:
            self.flipDimension()
            self.coordinates = coordinates.map {
                ($0.y, $0.x)
            }
        case .horizontalFlip:
            self.coordinates = coordinates.map {
                (self.cols - $0.x - 1, $0.y)
            }
            break
        case .verticalFlip:
            self.coordinates = coordinates.map {
                ($0.x, self.rows - $0.y - 1)
            }
            break
        }
    }

    public func toggle(_ coordinate: Coordinate) {
        var removed = false
        self.coordinates = self.coordinates.filter {
            if $0.x == coordinate.x && $0.y == coordinate.y {
                removed = true
                return false
            }
            return true
        }
        if !removed {
            coordinates.append(coordinate)
        }
    }

    public func set(_ coordinate: Coordinate, to alive: Bool) {
        if alive {
            if !self.contains(coordinate) {
                self.coordinates.append(coordinate)
            }
        } else {
            self.coordinates = coordinates.filter {
                $0.x != coordinate.x || $0.y != coordinate.y
            }
        }
    }

    public func contains(_ coordinate: Coordinate) -> Bool {
        return coordinates.reduce(false) {
            $0 || ($1.x == coordinate.x && $1.y == coordinate.y)
        }
    }

    //updates the coordinate system so it starts from (0, 0)
    public func updateCoordinates() {
        if coordinates.count == 0 {return}
        var max: Coordinate = coordinates[0]
        let min: Coordinate = coordinates.reduce(coordinates[0]) {
            max = (x: $1.x > max.x ? $1.x : max.x, y: $1.y > max.y ? $1.y : max.y)
            return (x: $1.x < $0.x ? $1.x : $0.x, y: $1.y < $0.y ? $1.y : $0.y)
        }
        self.rows = max.y - min.y + 1
        self.cols = max.x - min.x + 1
        self.coordinates = self.coordinates.map{(x: $0.x - min.x, y: $0.y - min.y)}
    }

    private func flipDimension() {
        let tmp = self.rows
        self.rows = self.cols
        self.cols = tmp
    }
}
