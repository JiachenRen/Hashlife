//
//  Universe.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/21/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation
let ruleSetUpdatedNotification = Notification.Name("ruleSetUpdatedNotification")

public class Universe: UniverseProtocol {
    var root: HashedTreeNode
    var numGen: Decimal = 0
    var visualizationBaseLevel: Int?
    var needsExpansion: Bool {
        return root.lev < 3 || root.nw.pop != root.nw.se.se.pop
                || root.ne.pop != root.ne.sw.sw.pop
                || root.sw.pop != root.sw.ne.ne.pop
                || root.se.pop != root.se.nw.nw.pop
    }

    public enum RuleSet: CustomStringConvertible {
        case `default`
        case custom(livingRule: [Int], bornRule: [Int])
        
        public var description: String {
            switch self {
            case .default: return "23/3 (Default)"
            case .custom(livingRule: let lr, bornRule: let br):
                let lrStr = lr.reduce("") {$0 + String($1)}
                return lrStr + "/" + br.reduce("") {
                    $0 + String($1)
                }
            }
        }
        
        public func isDefault() -> Bool {
            switch self {
            case .default: return true
            case .custom(livingRule: let lr, bornRule: let br):
                return RuleSet.matchesAll(lr, [2,3]) && RuleSet.matchesAll(br, [3])
            }
        }
        
        public static func ==(lhs: RuleSet, rhs: RuleSet) -> Bool {
            if lhs.isDefault() && rhs.isDefault() {
                return true
            } else {
                switch lhs {
                case .custom(livingRule: let lr, bornRule: let br):
                    switch rhs {
                    case .custom(livingRule: let olr, bornRule: let obr):
                        return matchesAll(lr, olr) && matchesAll(br, obr)
                    default: return false
                    }
                default: return false
                }
            }
        }
        
        private static func matchesAll(_ lhs: [Int], _ rhs: [Int]) -> Bool {
            return lhs.count == rhs.count && lhs.reduce(true){$0 && rhs.contains($1)}
        }
        
        
    }

    //WARNING: changing the ruleSet would result in losing all the data stored in hashMap, since the same rule no longer applies.
    public static var ruleSet: RuleSet = .default {
        didSet {
            if !(oldValue == ruleSet) {
                HashedTreeNode.hashMap = Dictionary<HashedTreeNode, HashedTreeNode>()
                NotificationCenter.default.post(Notification(name: ruleSetUpdatedNotification))
            }
            //could be improved. Should have multiple hash maps for different rule sets.
        }
    }

    public var stepSize: Decimal {
        return UniverseSimulator.hashLifeEnabled ? pow(2, root.lev - 2) * 2 : 1
    }

    public var description: String {
        return "Generation <\(numGen)> population <\(root.pop)> level <\(root.lev)> leaf nodes <\(pow(2, root.lev * 2))> step <\(stepSize)>"
    }

    public required init() {
        root = HashedTreeNode.createMacrocell()
    }

    func setNodeAt(x: Int, y: Int, to isAlive: Bool) {
        expandIfNeeded(x: x, y: y)
        root = root.setNodeAt(x: x, y: y, to: isAlive) //finally found the bug!
    }

    private func expandIfNeeded(x: Int, y: Int) {
        while (true) {
            let maxCoordinate = 1 << (root.lev - 1)
            if -maxCoordinate <= x &&
                       x <= maxCoordinate - 1 &&
                       -maxCoordinate <= y &&
                       y <= maxCoordinate - 1 {
                break
            }
            root = root.expand()
        }
    }

    public func extractRoot(from viewPort: UniverseViewPort) -> HashedTreeNode {
        //expand the universe if the current view port is larger than self.
        self.expandIfNeeded(x: viewPort.upperLeft.x, y: viewPort.upperLeft.y)
        self.expandIfNeeded(x: viewPort.lowerLeft.x, y: viewPort.lowerLeft.y)
        self.expandIfNeeded(x: viewPort.upperRight.x, y: viewPort.upperRight.y)
        self.expandIfNeeded(x: viewPort.lowerRight.x, y: viewPort.lowerRight.y)
        self.visualizationBaseLevel = viewPort.baseLevel
//        var livingNodes = [(Int, Int)]() //Old algorithm, slows down as grid expands exponentially
        //TODO: ACCELERATE This is the only thing that is slowing the app down now!!!!
//        (viewPort.upperLeft.0...viewPort.lowerRight.0).forEach {x in
//            (viewPort.upperLeft.1...viewPort.lowerRight.1).forEach {y in
//                if root.getNodeAt(x: x, y: y) == 1 {
//                    livingNodes.append(x,y)
//                }
//            }
//        }
        return self.root
    }

    public func step() {
        while (needsExpansion) {
            root = root.expand()
        }
        root = root.evalNextState()
        numGen += stepSize
    }
}

protocol UniverseProtocol: CustomStringConvertible {
    var root: HashedTreeNode { get set }
    var visualizationBaseLevel: Int? { get }
    var numGen: Decimal { get set }
    func extractRoot(from: UniverseViewPort) -> HashedTreeNode
    func setNodeAt(x: Int, y: Int, to: Bool)
    func step()
}
