//
//  Universe.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/21/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation

public class Universe: UniverseProtocol {
    var root: HashedTreeNode
    var numGen: IntMax = 0
    var needsExpansion: Bool {
        return root.lev < 3 || root.nw.pop != root.nw.se.se.pop
            || root.ne.pop != root.ne.sw.sw.pop
            || root.sw.pop != root.sw.ne.ne.pop
            || root.se.pop != root.se.nw.nw.pop
    }
    
    public var description: String {
        return "Generation <\(numGen)> population <\(Int(root.pop))> level <\(root.lev)> leaf nodes <\(pow(2,root.lev * 2))> "
    }
    
    public required init() {
        root = HashedTreeNode.createMacrocell()
    }
    
    func setNodeAt(x: Int, y: Int, to isAlive: Bool) {
        while (true) {
            let maxCoordinate = 1 << (root.lev - 1) ;
            if -maxCoordinate <= x && x <= maxCoordinate - 1 && -maxCoordinate <= y && y <= maxCoordinate - 1{
//                print("root level: \(root.lev)") //debug
                break
            }
            root = root.expand()
        }
        root = root.setNodeAt(x: x, y: y, to: isAlive) //finally found the bug!
    }
    
    public func step() {
        while (needsExpansion) {
            root = root.expand()
        }
        root = root.evalNextState()
        numGen += 1
    }
}

public class HashlifeUniverse: Universe {
    public override var description: String {
        return super.description + "step <\(stepSize)>"
    }
    public var stepSize: IntMax {
       return IntMax(pow(2, root.lev-2).intValue * 2)
    }
    
    public required init() {
        super.init()
        HashedTreeNode.useHashlife = true
        root = HashedTreeNode.createMacrocell()
    }
    
    public override func step() {
        super.step()
        numGen += (stepSize - 1)
    }
}

protocol UniverseProtocol: CustomStringConvertible {
    var root: HashedTreeNode {get}
    func setNodeAt(x: Int, y: Int, to: Bool)
    func step()
}

extension Decimal {
    var intValue: Int {
        return NSDecimalNumber(decimal:self).intValue
    }
}
