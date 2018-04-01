//
//  File.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/21/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation

public class QuadTree {
    final let nw: TreeNode!
    final let ne: TreeNode!
    final let sw: TreeNode!
    final let se: TreeNode!
    final let lev: Int //level
    final let alive: Bool //alive or not (if at level 0)
    final let pop: Double //population
    
    public init(isAlive: Bool) {
        self.nw = nil
        self.ne = nil
        self.sw = nil
        self.se = nil
        self.lev = 0
        self.alive = isAlive
        self.pop = alive ? 1 : 0
    }
    
    public init(nw: TreeNode, ne: TreeNode, sw: TreeNode, se: TreeNode) {
        self.nw = nw
        self.ne = ne
        self.sw = sw
        self.se = se
        self.lev = nw.lev + 1
        self.pop = nw.pop + ne.pop + sw.pop + se.pop
        self.alive = pop > 0
    }
    
    func getNodeAt(x: Int, y: Int) -> Int {
        if lev == 0 {return alive ? 1 : 0}
        let offset = 1 << (lev - 2)
        if x < 0 {
            if y < 0 {return nw.getNodeAt(x:x+offset, y:y+offset)} else {
                return sw.getNodeAt(x:x+offset, y:y-offset)
            }
        } else {
            if y < 0 {return ne.getNodeAt(x:x-offset, y:y+offset)} else {
                return se.getNodeAt(x:x-offset, y:y-offset)
            }
        }
    }
    
    class func initEmptyTree(lev: Int) -> TreeNode {
        if lev == 0 {return TreeNode(isAlive: false)}
        let n = initEmptyTree(lev: lev - 1)
        return TreeNode(nw: n,ne: n,sw: n,se: n)
    }
    
    class func createMacrocell() -> TreeNode {
        return TreeNode.initEmptyTree(lev: 3)
    }
    
    func expand() -> TreeNode {
        let border = QuadTree.initEmptyTree(lev: self.lev - 1)
        return TreeNode(
            nw: TreeNode(nw: border,ne: border,sw: border,se: nw),
            ne: TreeNode(nw: border,ne: border,sw: ne,se: border),
            sw: TreeNode(nw: border,ne: sw,sw: border,se: border),
            se: TreeNode(nw: se,ne: border,sw: border,se: border)
        )
    }
    
    //    /*returns a newly initialized QuadTree instance or just return
    //     *the reference to the existing object from the hashMap if an identical
    //     *if one already exists. Doing it this way saves memory.
    //     */
    //    func initOrRef(isAlive: Bool) {
    //
    //    }
}

public extension QuadTree {
    func setNodeAt(x: Int, y: Int, to isAlive: Bool) -> TreeNode {
        if self.lev == 0 {return TreeNode(isAlive: isAlive)}
        let offset = 1 << (lev - 2)
        if x < 0 {
            if y < 0 {
                return TreeNode(
                    nw: nw.setNodeAt(x:x+offset, y: y+offset, to: true),
                    ne: ne,
                    sw: sw,
                    se: se
                )
            } else {
                return TreeNode(
                    nw: nw,
                    ne: ne,
                    sw: sw.setNodeAt(x:x+offset, y: y-offset, to: true),
                    se: se
                )
            }
        } else {
            if y < 0 {
                return TreeNode(
                    nw: nw,
                    ne: ne.setNodeAt(x:x-offset, y: y+offset, to: true),
                    sw: sw,
                    se: se
                )
            } else {
                return TreeNode(
                    nw: nw,
                    ne: ne,
                    sw: sw,
                    se: se.setNodeAt(x:x-offset, y: y-offset, to: true)
                )
            }
        }
    }
}
