//
//  Simulator.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/21/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation

public class Simulator {
    static var universe: UniverseProtocol! //change the universe to use here.
    
    class public func interpret(rle: String){
        var x = 0, y = 0, paramArg = 0;
        for line in rle.components(separatedBy: "\n") {
//            print(line, terminator: "\n")
//            print("I am here")
            if line.characters.first == "x" || line.characters.first == "#"{
                continue
            }
            
            for c in line.characters {
                
                var param = (paramArg == 0 ? 1 : paramArg)
                switch c {
                case "b":
                    x += param
                    paramArg = 0 //debug 
                case "o":
                    (0..<param).forEach{_ in
                        universe.setNodeAt(x: x, y: y, to: true)
                        print("(\(x),\(y))", terminator: ",")
                        x += 1
                    }
                    param = 0
                    paramArg = 0
                case "$":
//                    print("Increment y. Clear x. Clear paramArg.")
                    y += param
                    x = 0
                    paramArg = 0
                case "!": break
                case let c:
                    let q = Int(String(c))
                    if (q == nil || q! > 9 || q! < 0) {fallthrough}
                    paramArg = 10 * paramArg + q!
                default: print("unrecognized: \(c)")
                }
            }
        }
    }
}
