//
//  main.swift
//  HashlifeModelTest
//
//  Created by Jiachen Ren on 7/22/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation

extension Date {
    public var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}

print("Please paste rle file content below: ")
var input = ""
while(true) {
    let line = readLine()!
    input += "\(line)\n"
    if (line.characters.last == "!") {
        break
    }
}
print("Use hash life algorithm? (Y/N)")
Simulator.universe = (readLine()! == "Y" ? HashlifeUniverse() : Universe())
print("Number of steps: ")
let numSteps = Int(readLine()!)!
print("Reading configuration...")
Simulator.interpret(rle: input)
print("\nDone. Starting...")

//for debug testing
let millis = Date().millisecondsSince1970
for _ in 0...numSteps {
    Simulator.universe.step()
    debugPrint(Simulator.universe)
}

print("Current generation: \(Simulator.universe)")
print("Time elapsed: \(Date().millisecondsSince1970 - millis)")


//hashValue testing
//var proto = HashedTreeNode(isAlive: false)
//var nw = proto.initGhost(isAlive: true)
//var ne = proto.initGhost(isAlive: false)
//var sw = proto.initGhost(isAlive: true)
//var se = proto.initGhost(isAlive: false)
//
//var cell4 = proto.initGhost(nw: nw, ne: ne, sw: sw, se: se)
//var anotherCell4 = proto.initGhost(nw: nw, ne: ne, sw: sw, se: se)
//
//var cell16 = proto.initGhost(nw: cell4, ne: cell4, sw: cell4, se: cell4)
//var anotherCell16 = proto.initGhost(nw: cell4, ne: cell4, sw: cell4, se: cell4)
//
//print(cell16  ===  anotherCell16)
//print(cell4.hashValue)
