//
//  Vec2D.swift
//  Machine Learning Simulation
//
//  Created by Jiachen Ren on 7/17/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation
import UIKit

public class Vec2D: CustomStringConvertible {
    public var description: String {
        return "[\(self.x), \(self.y)]"
    }
    var x: CGFloat
    var y: CGFloat

    var cgPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }

    required public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }

    convenience init(point: CGPoint) {
        self.init(x: point.x, y: point.y)
    }

    convenience init() {
        self.init(x: 0, y: 0)
    }

    public func add(_ vec: Vec2D) -> Vec2D {
        self.x += vec.x
        self.y += vec.y
        return self
    }

    public func sub(_ vec: Vec2D) -> Vec2D {
        self.x -= vec.x
        self.y -= vec.y
        return self
    }

    public func mult(_ n: CGFloat) -> Vec2D {
        self.x *= n
        self.y *= n
        return self
    }

    public func div(_ n: CGFloat) -> Vec2D {
        self.x /= n
        self.y /= n
        return self
    }

    public func norm() -> Vec2D {
        let mag = self.mag()
        if mag != 0 && mag != 1.0 {
            return self.div(mag)
        }
        return self
    }

    public func mag() -> CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }

    public func limit(_ n: CGFloat) -> Vec2D {
        if self.mag() * self.mag() > n * n {
            return self.norm().mult(n)
        }
        return self
    }

    public func setMag(_ n: CGFloat) -> Vec2D {
        return self.norm().mult(n)
    }

    public func rotate(_ angle: CGFloat) -> Vec2D {
        let temp = self.x
        self.x = self.x * cos(angle) + self.y * sin(angle)
        self.y = temp * sin(angle) + self.y * cos(angle)
        return self
    }

    public func heading() -> CGFloat {
        return atan2(self.y, self.x)
    }

    public func dist(_ vec: Vec2D) -> CGFloat {
        let dx = self.x - vec.x
        let dy = self.y - vec.y
        return sqrt(dx * dx + dy * dy)
    }

    public func clone(_ vec: Vec2D) -> Vec2D {
        return Vec2D(point: self.cgPoint)
    }

    public class func angleBetween(_ vec1: Vec2D, _ vec2: Vec2D) -> CGFloat {
        if vec1.x == 0.0 && vec1.y == 0.0 {
            return 0.0
        } else if vec2.x == 0.0 && vec2.y == 0.0 {
            return 0.0
        } else {
            let dot = vec1.x * vec2.x + vec1.y * vec2.y
            let amt = dot / (vec1.mag() * vec2.mag())
            return amt <= -1.0 ? CGFloat.pi : (amt >= 1.0 ? 0.0 : acos(amt))
        }
    }

    public class func random() -> Vec2D {
        let seed1 = CGFloat(arc4random_uniform(0x186A0)) - 0xC350
        let seed2 = CGFloat(arc4random_uniform(0x186A0)) - 0xC350
        return Vec2D(x: seed1, y: seed2).norm()
    }
}
