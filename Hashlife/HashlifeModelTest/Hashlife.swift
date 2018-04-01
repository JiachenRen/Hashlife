//
//  HashedTreeNode.swift
//  HashlifeModelTest
//
//  Created by Jiachen Ren on 7/22/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation

public extension HashedTreeNode {
    private func horizontalForward(w: HashedTreeNode, e: HashedTreeNode) -> HashedTreeNode {
        return self.initGhost(nw: w.ne, ne: e.nw, sw: w.se, se: e.sw).evalNextState()
    }
    
    private func verticalForward(n: HashedTreeNode, s: HashedTreeNode) -> HashedTreeNode{
        return self.initGhost(nw: n.sw, ne: n.se, sw: s.nw, se: s.ne).evalNextState()
    }
    
    private func centerForward() -> HashedTreeNode{
        return self.initGhost(nw: nw.se, ne: ne.sw, sw: sw.ne, se: se.nw).evalNextState()
    }
    
    public func hashlife() -> HashedTreeNode {
        if pop == 0 {return nw}
        if lev == 2 {return nextGen()}
        
        let n00 = nw.evalNextState()
        let n01 = horizontalForward(w: nw, e: ne)
        let n02 = ne.evalNextState()
        let n10 = verticalForward(n: nw, s: sw)
        let n11 = centerForward()
        let n12 = verticalForward(n: ne, s: se)
        let n20 = sw.evalNextState()
        let n21 = horizontalForward(w: sw, e: se)
        let n22 = se.evalNextState()
        return self.initGhost(
            nw: self.initGhost(nw: n00, ne: n01, sw: n10, se: n11).evalNextState(),
            ne: self.initGhost(nw: n01, ne: n02, sw: n11, se: n12).evalNextState(),
            sw: self.initGhost(nw: n10, ne: n11, sw: n20, se: n21).evalNextState(),
            se: self.initGhost(nw: n11, ne: n12, sw: n21, se: n22).evalNextState()
        )
    }
}
