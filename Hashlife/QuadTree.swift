//
//  File.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/21/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation

public typealias Coordinate = (x: Int, y: Int)

public class QuadTree {
    final let nw: HashedTreeNode!     //IMMUTABLE.
    final let ne: HashedTreeNode!     //IMMUTABLE. unsafePointer(to:) requires the parameter to be mutable.
    final let sw: HashedTreeNode!     //IMMUTABLE.
    final let se: HashedTreeNode!     //IMMUTABLE.
    final let lev: Int //level
    final let alive: Bool //alive or not (if at level 0)
    final let pop: Double //population

    enum Quadrant {
        case nw, ne, sw, se

        static func extrapolate(x: Int, y: Int) -> Quadrant {
            return x < 0 ? y < 0 ? .nw : .sw : y < 0 ? .ne : se
        }

        func node(_ node: HashedTreeNode) -> HashedTreeNode {
            switch self {
            case .nw: return node.nw
            case .ne: return node.ne
            case .sw: return node.sw
            case .se: return node.se
            }
        }
    }

    public init(isAlive: Bool) {
        self.nw = nil
        self.ne = nil
        self.sw = nil
        self.se = nil
        self.lev = 0
        self.alive = isAlive
        self.pop = alive ? 1 : 0
    }

    public init(nw: HashedTreeNode, ne: HashedTreeNode, sw: HashedTreeNode, se: HashedTreeNode) {
        self.nw = nw
        self.ne = ne
        self.sw = sw
        self.se = se
        self.lev = nw.lev + 1
        self.pop = nw.pop + ne.pop + sw.pop + se.pop
        self.alive = pop > 0
    }

    func getNodeAt(x: Int, y: Int) -> Int {
        if lev == 0 {
            return alive ? 1 : 0
        }
        if self.pop == 0 {
            return 0
        } //imediately returns false if the area is empty. Slightly slows down algorithm but faster for drawing.
        let offset = self.offsetToSubnode()
        switch Quadrant.extrapolate(x: x, y: y) {
        case .nw: return nw.getNodeAt(x: x + offset, y: y + offset)
        case .sw: return sw.getNodeAt(x: x + offset, y: y - offset)
        case .ne: return ne.getNodeAt(x: x - offset, y: y + offset)
        case .se: return se.getNodeAt(x: x - offset, y: y - offset)
        }
    }

    public func offsetToSubnode() -> Int {
        let tmp = lev - 2
        return 1 << (tmp < 0 ? 0 : tmp) //preventing overflow
    }
}

public extension HashedTreeNode {

    //returns the string representation of this node.
    var str: String {
        if lev == 0 {
            return pop > 0 ? "+" : "-"
        }
        return nw.str + ne.str + "\n" + sw.str + se.str + "\n"
    }

    func setNodeAt(x: Int, y: Int, to isAlive: Bool) -> HashedTreeNode {
        if self.lev == 0 {
            return self.initGhost(isAlive: isAlive)
        }
        
        let offset = self.offsetToSubnode()
        switch Quadrant.extrapolate(x: x, y: y) {
        case .nw: return self.initGhost(nw: nw.setNodeAt(x: x + offset, y: y + offset, to: isAlive), ne: ne, sw: sw, se: se)
        case .sw: return self.initGhost(nw: nw, ne: ne, sw: sw.setNodeAt(x: x + offset, y: y - offset, to: isAlive), se: se)
        case .ne: return self.initGhost(nw: nw, ne: ne.setNodeAt(x: x - offset, y: y + offset, to: isAlive), sw: sw, se: se)
        case .se: return self.initGhost(nw: nw, ne: ne, sw: sw, se: se.setNodeAt(x: x - offset, y: y - offset, to: isAlive))
        }
    }

    func expand() -> HashedTreeNode {
        let border = self.initEmptyTree(lev: self.lev - 1)
        return self.initGhost(
                nw: self.initGhost(nw: border, ne: border, sw: border, se: nw),
                ne: self.initGhost(nw: border, ne: border, sw: ne, se: border),
                sw: self.initGhost(nw: border, ne: sw, sw: border, se: border),
                se: self.initGhost(nw: se, ne: border, sw: border, se: border)
        )
    }
}

public func +(lhs: Coordinate, rhs: Coordinate) -> Coordinate {
    return (x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: Coordinate, rhs: Coordinate) -> Coordinate {
    return (x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public protocol NodeProtocol: class {
    func initGhost(isAlive: Bool) -> HashedTreeNode
    func initGhost(nw: HashedTreeNode, ne: HashedTreeNode, sw: HashedTreeNode, se: HashedTreeNode) -> HashedTreeNode
    func initEmptyTree(lev: Int) -> HashedTreeNode
    static func createMacrocell() -> HashedTreeNode
}
