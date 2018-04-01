//
//  Utils.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/24/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import Foundation
import UIKit

public func loadJSON(from fileName: String) -> Any? {
    let path = Bundle.main.path(forResource: fileName, ofType: "json", inDirectory: nil)
    let url = URL(fileURLWithPath: path!)
    let data = try? Data(contentsOf: url)
    let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
    print(jsonObj ?? "not valid")
    return jsonObj
}

public func loadFrom(url: String) {
    if let url = URL(string: url) {
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let html = String(data: data!, encoding: .utf8)
            print("html: \(String(describing: html))\n" +
                    "response: \(String(describing: response))\n" +
                    "error: \(String(describing: error))")

            DispatchQueue.main.async {
                //do somthing that will happen in the main thread. (for animation... stuff like that.)
                
            }
        }
        dataTask.resume()
    }
}

public func saveToUserDefault(obj: Any, key: String) {
    UserDefaults.standard.set(obj, forKey: key)
    print("saved: \(obj) with key: \(key)")
}

public func retrieveFromUserDefualt(key: String) -> Any? {
    let obj = UserDefaults.standard.object(forKey: key)
    print("retrieved \(String(describing: obj)) for key: \(key)")
    return obj
}

public func randomCoordinate(rangeX: Int, rangeY: Int) -> (x: Int, y: Int) {
    return (
        x: Int(CGFloat.random() * CGFloat(rangeX) - CGFloat(rangeX) / 2),
        y: Int(CGFloat.random() * CGFloat(rangeY) - CGFloat(rangeY) / 2)
    )
}

//Various extensions developed by Jiachen Ren.

extension CGPoint {
    func translate(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y);
    }
    
    func translate(by point: CGPoint) -> CGPoint {
        return self.translate(point.x, point.y)
    }
    
    static func midpoint(from p1: CGPoint, to p2: CGPoint) -> CGPoint{
        return CGPoint(x: (p2.x+p1.x)/2, y: (p2.y+p1.y)/2)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        let dividingConst: UInt32 = 4294967295
        return CGFloat(arc4random()) / CGFloat(dividingConst)
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        var min = min, max = max
        if (max < min) {swap(&min, &max)}
        return min + random() * (max - min)
    }
    
    private static func swap(_ a: inout CGFloat, _ b: inout CGFloat){
        let temp = a
        a = b
        b = temp
    }
}

extension Decimal {
    var intValue: Int {
        return NSDecimalNumber(decimal: self).intValue
    }
}

extension Date {
    public var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}

//Modified from https://stackoverflow.com/questions/28644311/how-to-get-the-rgb-code-int-from-an-uicolor-in-swift
extension UIColor {
    func rgb() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (r: red, g: green, b: blue, a: alpha)
    }
}


public class Utils {
    public static func map(_ i: CGFloat, _ v1: CGFloat, _ v2: CGFloat, _ t1: CGFloat, _ t2: CGFloat) -> CGFloat {
        return (i - v1) / (v2 - v1) * (t2 - t1) + t1
    }

    public static func loadFile(name: String, extension ext: String) -> String? {
        let path = Bundle.main.path(forResource: name, ofType: ext, inDirectory: nil)
        let url = URL(fileURLWithPath: path!)
        let data = try? Data(contentsOf: url)
        return String(data: data!, encoding: .utf8)
    }
}

extension CGContext {
    static func point(at point: CGPoint, strokeWeight: CGFloat){
        let circle = UIBezierPath(ovalIn: CGRect(center: point, size: CGSize(width: strokeWeight, height: strokeWeight)))
        circle.fill()
    }
    static func fillCircle(center: CGPoint, radius: CGFloat) {
        let circle = UIBezierPath(ovalIn: CGRect(center: center, size: CGSize(width: radius * 2, height: radius * 2)))
        circle.fill()
    }
}

extension CGRect {
    init(center: CGPoint, size: CGSize){
        self.init(
            origin: CGPoint(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2
            ),
            size: size
        )
    }
    static func fillCircle(center: CGPoint, radius: CGFloat) {
        let circle = UIBezierPath(ovalIn: CGRect(center: center, size: CGSize(width: radius * 2, height: radius * 2)))
        circle.fill()
    }
}
