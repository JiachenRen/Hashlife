//
//  Simulator.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/21/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation

public typealias Millis = Int

public class UniverseSimulator {
    var universe: UniverseProtocol! {
        didSet {
            delegate?.simulatorDidUpdate()
        }
    }
    var delegate: SimulatorDelegate?
    var stepTimerInterval: Double = 0.001
    var stepTimer: Timer?
    var stepPerFrame: Int = 1
    var autoSpeed: Bool = false
    var autoSpeedStepPerFrame: Int = 1

    //NOTE: will crash the app is about 2 seconds due to overflow. TOOOOO FAST!
    static var hashLifeEnabled: Bool = false

    //crucial vaiables for auto speed.
    //note: auto speed is calculated based on the designated stepPerFrame.
    var speedDecrementThreshold = 50 //in millis
    var didCancelInProgress = false
    var millisPerIteration: Millis?
    var startDate: Millis!
    var balance: Int = 0

    static var sharedInstance: UniverseSimulator = {
        return UniverseSimulator()
    }()

    required public init() {
        self.universe = Universe()
    }

    public func setStepInterval(s: TimeInterval) {
        self.stepTimerInterval = s
        start()
    }

    public func start() {
        self.stepTimer?.invalidate() //destroys the existing timer.
        self.stepTimer = Timer.scheduledTimer(withTimeInterval: stepTimerInterval, repeats: true) { [unowned self] _ in
            self.autoSpeed ? self.autoStep() : self.step(num: self.stepPerFrame)
            self.delegate?.simulatorDidUpdate()
        }
    }

    private func step(num: Int) {
        for _ in 0..<num {
            step()
        }
    }

    private func autoStep() {
        self.startDate = Date().millisecondsSince1970
        if let lev = universe.visualizationBaseLevel, !didCancelInProgress {
            autoSpeedStepPerFrame = stepPerFrame * pow(4, lev - 1).intValue + balance
            autoSpeedStepPerFrame = autoSpeedStepPerFrame < 1 ? 1 : autoSpeedStepPerFrame
        } else {
            autoSpeedStepPerFrame = stepPerFrame
        }
        didCancelInProgress = false
        for _ in 0..<autoSpeedStepPerFrame {
            if Date().millisecondsSince1970 - self.startDate > self.speedDecrementThreshold {
                didCancelInProgress = true
                self.balance -= 1
                break
            }
            self.universe.step()
        }
        let cur = Date().millisecondsSince1970 - self.startDate
        if millisPerIteration != nil &&
                   cur < speedDecrementThreshold &&
                   !didCancelInProgress &&
                   balance < 0 {
            balance += 1
        }
        self.millisPerIteration = cur
    }

    public func toggleNode(at loc: Coordinate) {
        //debug: setting to false does not work.
        self.setNode(at: loc, to: universe.root.getNodeAt(x: loc.x, y: loc.y) != 1)
        self.delegate?.simulatorDidUpdate()
    }

    public func setNode(at loc: Coordinate, to alive: Bool) {
        universe.setNodeAt(x: loc.x, y: loc.y, to: alive)
        self.delegate?.simulatorDidUpdate()
    }

    public func step() {
        self.universe.step()
        self.delegate?.simulatorDidUpdate()
    }

    public func stop() {
        self.stepTimer?.invalidate()
        self.stepTimer = nil
    }

    public func clear() {
        self.universe = Universe()
    }

    //interpret .rle files.
    public static func interpret(rle: String) -> [Coordinate] {
        var coordinates = [Coordinate]()
        var x = 0, y = 0, paramArg = 0
        for line in rle.components(separatedBy: "\n") {
            if line.first == "x" || line.first == "#" {
                continue
            }
            for c in line {
                var param = (paramArg == 0 ? 1 : paramArg)
                switch c {
                case "b":
                    x += param
                    paramArg = 0
                case "o":
                    (0..<param).forEach { _ in
                        coordinates.append((x: x, y: y))
                        print("(\(x),\(y))", terminator: ",")
                        x += 1
                    }
                    param = 0
                    paramArg = 0
                case "$":
                    y += param
                    x = 0
                    paramArg = 0
                case "!": break
                case let c:
                    let q = Int(String(c))
                    if q == nil || q! > 9 || q! < 0 {
                        fallthrough
                    }
                    paramArg = 10 * paramArg + q!
                default: print("unrecognized: \(c)")
                }
            }
        }
        return coordinates
    }

    public func load(coordinates: [Coordinate]) {
        coordinates.forEach { (x, y) in
            universe.setNodeAt(x: x, y: y, to: true)
        }
        delegate?.simulatorDidUpdate()
    }

    //Interpret .lif files.
    public static func interpret(life: String) -> [Coordinate] {
        var anchorRow = 0, anchorCol = 0, staringIndex = 0
        var coordinates = [Coordinate]()
        for (i, line) in life.components(separatedBy: "\n").enumerated() {
            //    if i == 0 {continue}
            if line.hasPrefix("#P") {
                let index = line.index(line.startIndex, offsetBy: 3)
                let coordinate = line[index...].components(separatedBy: " ")
                anchorRow = Int(coordinate[0])!
                anchorCol = Int(coordinate[1])!
                staringIndex = i
            } else {
                line.enumerated().forEach { (q, char) in
                    if char == "*" {
                        coordinates.append((
                                x: anchorRow + i - staringIndex - 1,
                                y: anchorCol + q)
                        )
                    }
                }
            }
        }
        return coordinates
    }

    //convert the string representation of a rule set to the readable form by the universe.
    public static func interpret(rule: String) -> (living: [Int], born: [Int]) {
        let slashIndex = rule.firstIndex(of: "/")!
        var bornRule: String, livingRule: String
        if let bIndex = rule.firstIndex(of: "b"),
           let sIndex = rule.firstIndex(of: "s") {
            bornRule = String(rule[rule.index(after: bIndex)...rule.index(before: slashIndex)])
            livingRule = String(rule[rule.index(after: sIndex)...])
        } else {
            livingRule = String(rule[rule.startIndex..<slashIndex])
            bornRule = String(rule[rule.index(after: slashIndex)...])
        }
        return (living: livingRule.map{Int(String($0))!},
                born: bornRule.map{Int(String($0))!})
    }
}

public protocol SimulatorDelegate {
    func simulatorDidUpdate()
}
