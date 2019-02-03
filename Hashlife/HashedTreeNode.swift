//
//  TreeNode.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/21/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation

public class HashedTreeNode: QuadTree, CustomStringConvertible, NodeProtocol {
    private var result: HashedTreeNode? //This is what does the trick. Every macrocell will have a RESULT computed.
    public class var prototype: HashedTreeNode {
        return HashedTreeNode(isAlive: false)//.initOrRef()// do I need this??
    }

    private func nextGen(_ bitmask: Int) -> HashedTreeNode {
        guard bitmask != 0 else {
            return self.initGhost(isAlive: false)
        }
        var bitmask = bitmask
        let selfIsAlive: Bool = (bitmask >> 5) & 1 != 0
        bitmask &= 0b11101010111
        var numNeighbors: Int = 0
        while (bitmask != 0) {
            numNeighbors += 1
            bitmask &= bitmask - 1
        }
        switch Universe.ruleSet {
        case .default: return self.initGhost(isAlive: numNeighbors == 3 || (numNeighbors == 2 && selfIsAlive))
        case .custom(livingRule:let lr, bornRule:let br):
            if br.contains(numNeighbors) {
                return self.initGhost(isAlive: true)
            } else {
                return self.initGhost(isAlive: selfIsAlive && lr.contains(numNeighbors))
            }
        }

    }

    public func nextGen() -> HashedTreeNode {
        var allbits = 0;
        for y in -2..<2 {
            for x in -2..<2 {
                allbits = (allbits << 1) + getNodeAt(x: x, y: y)
            }
        }

        return self.initGhost(
                nw: nextGen(allbits >> 5),
                ne: nextGen(allbits >> 4),
                sw: nextGen(allbits >> 1),
                se: nextGen(allbits))
    }

    private func centeredSubnode() -> HashedTreeNode {
        return self.initGhost(nw: nw.se, ne: ne.sw, sw: sw.ne, se: se.nw)
    }

    private func centeredSubSubnode() -> HashedTreeNode {
        return self.initGhost(nw: nw.se.se, ne: ne.sw.sw, sw: sw.ne.ne, se: se.nw.nw)
    }

    private func centeredHorizontal(w: HashedTreeNode, e: HashedTreeNode) -> HashedTreeNode {
        return self.initGhost(nw: w.ne.se, ne: e.nw.sw, sw: w.se.ne, se: e.sw.nw)
    }

    private func centeredVertical(n: HashedTreeNode, s: HashedTreeNode) -> HashedTreeNode {
        return self.initGhost(nw: n.sw.se, ne: n.se.sw, sw: s.nw.ne, se: s.ne.nw)
    }

    //YES!!!!! YES!!! YES I did it!
    public func evalNextState() -> HashedTreeNode {
        guard let cached = result else {
            result = self.eval()
            return result!
        }
        return cached
    }

    public func eval() -> HashedTreeNode {
        if UniverseSimulator.hashLifeEnabled {
            return hashlife()
        } //using about 100 millis extra per 20000 gen... could be better.
        if pop == 0 {
            return nw
        }
        if lev == 2 {
            return nextGen()
        }
        let n00 = nw.centeredSubnode()
        let n01 = centeredHorizontal(w: nw, e: ne)
        let n02 = ne.centeredSubnode()
        let n10 = centeredVertical(n: nw, s: sw)
        let n11 = centeredSubSubnode()
        let n12 = centeredVertical(n: ne, s: se)
        let n20 = sw.centeredSubnode()
        let n21 = centeredHorizontal(w: sw, e: se)
        let n22 = se.centeredSubnode();
        return self.initGhost(
                nw: self.initGhost(nw: n00, ne: n01, sw: n10, se: n11).evalNextState(),
                ne: self.initGhost(nw: n01, ne: n02, sw: n11, se: n12).evalNextState(),
                sw: self.initGhost(nw: n10, ne: n11, sw: n20, se: n21).evalNextState(),
                se: self.initGhost(nw: n11, ne: n12, sw: n21, se: n22).evalNextState()
        )
    }


    public class func createMacrocell() -> HashedTreeNode {
        return HashedTreeNode.prototype.initEmptyTree(lev: 3)
    }

    /*returns a newly initialized QuadTree instance or just return
     *the reference to the existing object from the hashMap if an identical
     *if one already exists. Doing it this way saves memory.
     */
    //    public func initGhost(isAlive: Bool) -> TreeNode {
    //        return TreeNode(isAlive: isAlive)
    //    }
    //
    //    public func initGhost(nw: TreeNode, ne: TreeNode, sw: TreeNode, se: TreeNode) -> TreeNode {
    //        return TreeNode(nw: nw, ne: ne, sw: sw, se: se)
    //    }

    public var description: String {
        return "HashedTreeNode population <\(pop)> lev <\(lev)>"
    }

    //init or return a reference to the identical self in the hashMap.
    public func initOrRef() -> HashedTreeNode {
        guard let ref = HashedTreeNode.hashMap[self] else {
            HashedTreeNode.hashMap[self] = self
            //print("logged:\n\(self.str)")
            return self
        }
        //print("retrieved:\n\(self.str)")
        return ref
    }

    //overriding the constructors, return a reference to an identical self if
    //the same configuration already exists in the dictionary.
    public func initGhost(isAlive: Bool) -> HashedTreeNode {
        //        debugPrint("initialized")
        return HashedTreeNode(isAlive: isAlive).initOrRef()
    }

    public func initGhost(nw: HashedTreeNode, ne: HashedTreeNode, sw: HashedTreeNode, se: HashedTreeNode) -> HashedTreeNode {
        return HashedTreeNode(nw: nw, ne: ne, sw: sw, se: se).initOrRef()
    }

    public func initEmptyTree(lev: Int) -> HashedTreeNode {
        if lev == 0 {
            return self.initGhost(isAlive: false)
        }
        let n = initEmptyTree(lev: lev - 1)
        return self.initGhost(nw: n, ne: n, sw: n, se: n)
    }

    //    //debug: foced type casting might result in an error.
    //    //just found out that static class vars cannot be overridden by subclasses...
    //    public class func createMacrocell() -> HashedTreeNode {
    //        return HashedTreeNode.initEmptyTree(lev: 3, proto: HashedTreeNode.prototype)
    //    }

    //    public class func initEmptyTree(lev: Int, proto: HashedTreeNode) -> HashedTreeNode {
    //        if lev == 0 {return proto.initGhost(isAlive: false)}
    //        let n = initEmptyTree(lev: lev - 1, proto: proto)
    //        return proto.initGhost(nw: n, ne: n, sw: n, se: n)
    //    }
}

extension HashedTreeNode: Hashable {
    static var hashMap = Dictionary<HashedTreeNode, HashedTreeNode>()

    //debug: since I changed ne, nw, se, sw to var, would the mem addr still remain the same?
    public var hashValue: Int {
        if self.lev == 0 {
            //maybe return .hashValue here for the base case?
            return Int(self.pop)
        }
        
        // Use &+ and &* to ignore numeric overflow.
        let hashVal = Unmanaged<HashedTreeNode>.passUnretained(nw).toOpaque().hashValue
                &+ 11 &* Unmanaged<HashedTreeNode>.passUnretained(ne).toOpaque().hashValue
                &+ 101 &* Unmanaged<HashedTreeNode>.passUnretained(sw).toOpaque().hashValue
                &+ 1007 &* Unmanaged<HashedTreeNode>.passUnretained(se).toOpaque().hashValue

        //it works now, but maybe it is not the fastest way to do so...
        return hashVal
        //            withUnsafeMutablePointer(to: &nw){return $0}.hashValue //get memory address in the system
        //                + 11 * withUnsafeMutablePointer(to: &ne){return $0}.hashValue
        //                + 101 * withUnsafeMutablePointer(to: &sw){return $0}.hashValue
        //                + 1007 * withUnsafeMutablePointer(to: &se){return $0}.hashValue
    }

    public static func ==(lhs: HashedTreeNode, rhs: HashedTreeNode) -> Bool {
        if lhs.lev != rhs.lev {
            return false
        }
        if lhs.lev == 0 {
            return lhs.alive == rhs.alive //debug: lhs.lev == 0 || rhs.lev == 0 ?
        }
        //        print("called") //this is very crucial.
        //        print(lhs.nw === rhs.nw
        //            && lhs.ne === rhs.ne
        //            && lhs.sw === rhs.sw
        //            && lhs.se === rhs.se)
        return lhs.nw === rhs.nw
                && lhs.ne === rhs.ne
                && lhs.sw === rhs.sw
                && lhs.se === rhs.se //checking if references are equal.
    }

    //    private static func rawPointerTo()
}
