//
//  GraphView.swift
//  This graph view is grabbed from my old Flo project.
//
//  Created by Jiachen Ren on 6/27/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    @IBInspectable var startColor: UIColor = UIColor.white
    @IBInspectable var endColor: UIColor = UIColor.orange
    @IBInspectable var graphStartColor: UIColor = UIColor.white
    @IBInspectable var graphEndColor: UIColor = UIColor.white.withAlphaComponent(0)
    @IBInspectable var graphMargins: CGPoint = .init(x: 20, y: 20)
    @IBInspectable var userDefinedBounds: Bool = false
    @IBInspectable var cornerRadii: CGFloat = 4.0
    @IBInspectable var max: CGFloat = 10
    @IBInspectable var min: CGFloat = -10
    @IBInspectable var graphStyleVal: Int {
        get {return graphStyle.rawValue}
        set {
            graphStyle = GraphStyle(rawValue: newValue) ?? .straight
        }
    }
    @IBInspectable var showPoints: Bool = true
    @IBInspectable var pointSize: CGFloat = 3
    @IBInspectable var pointColor: UIColor = UIColor.white
    
    private var graphStyle: GraphStyle = .curved
    
    enum GraphStyle: Int {
        case straight
        case curved
        case quadCurved
    }
    
    private var graphWidth: CGFloat {
        return bounds.width - graphMargins.x * 2
    }
    
    private var graphHeight: CGFloat {
        return bounds.height - graphMargins.y * 2
    }
    
    private var graphRect: CGRect {
        return .init(x: graphMargins.x, y: graphMargins.y, width: graphWidth, height: graphHeight)
    }
    
    public var dataSet = GraphDataSet(data: [CGFloat](repeatElement(0, count: 3))) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var context: CGContext? {
        return UIGraphicsGetCurrentContext()
    }
    
    override func draw(_ rect: CGRect) {
        fillBackground()
        if dataSet.data.count > 2 {
            renderGraph()
        }
    }
    
    private func pathForGraph() ->UIBezierPath{
        if userDefinedBounds {
            dataSet.max = {_ in self.max}
            dataSet.min = {_ in self.min}
        }
        
        var coordinates = dataSet.transform(by: graphRect)
//        if coordinates.count > 100 {
//            coordinates = coordinates.enumerated().filter{(i, _) in i > coordinates.count - 50}.map{(_, item) in item}
//        }
        
        //calculate the midpoints
        var midpoints = coordinates.enumerated().map { (offset, point) -> CGPoint? in
            if offset == 0  {return nil}
            return CGPoint.midpoint(from: coordinates[offset-1], to: point)
        }
        midpoints.remove(at: 0)
        
        //initiate the path at starting position
        let path = UIBezierPath()
        path.move(to: coordinates[0])
        
        //draws the trendLine according to the user defined graph style
        switch graphStyle {
        case .curved: midpoints.enumerated().forEach { (index, point) in
            path.addCurve(to: point!, controlPoint1: coordinates[index], controlPoint2: coordinates[index])
        }
        path.addLine(to: coordinates[coordinates.count-1])
        case .quadCurved: midpoints.enumerated().forEach { (index, point) in
            path.addQuadCurve(to: point!, controlPoint: coordinates[index])
        }
        path.addLine(to: coordinates[coordinates.count-1])
        case .straight: for (i,p) in coordinates.enumerated() where i > 0 {
            let midpoint = CGPoint.midpoint(from: coordinates[i-1], to: p)
            path.addQuadCurve(to: p, controlPoint: midpoint)
            }
        }
        return path
    }
    
    private func renderGraph(){
        //draws the graph trend line
        let path = pathForGraph()
        graphStartColor.setStroke()
        path.stroke()
        
        //modify the path to complete the clipping area
        let clippingPath = path.copy() as! UIBezierPath
        clippingPath.addLine(to: .init(x: graphRect.maxX, y: graphRect.maxY))
        clippingPath.addLine(to: .init(x: graphRect.minX, y: graphRect.maxY))
        clippingPath.close()
        
        //adds the clip to the current context
        clippingPath.addClip()
        
        //initiate the gradient
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [graphStartColor.cgColor, graphEndColor.cgColor] as CFArray,
            locations: [0,1.0]
        )
        
        //determine the highest point
        let coordinates = dataSet.transform(by: graphRect)
        let minY = coordinates.min {$0.y < $1.y}!.y
        
        //draws the gradient
        context?.drawLinearGradient(
            gradient!,
            start: CGPoint(x: graphRect.minX, y: minY),
            end: .init(x: graphRect.minX, y: graphRect.maxY),
            options: .init(rawValue: 0)
        )
        
        //draws the points
        if showPoints {
            context?.restoreGState()
            pointColor.setFill()
            coordinates.forEach {
                CGContext.point(at: $0, strokeWeight: pointSize)
            }
        }
    }
    
    private func fillBackground() {
        context?.saveGState()
        
        UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: UIRectCorner.allCorners,
            cornerRadii: .init(width: cornerRadii, height: cornerRadii)
            ).addClip()
        
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [startColor.cgColor, endColor.cgColor] as CFArray,
            locations: [0.0, 1.0]
        )
        context?.drawLinearGradient(
            gradient!,
            start: .zero,
            end: .init(x: 0, y: bounds.height),
            options: .init(rawValue: 0)
        )
    }
    
    public struct GraphDataSet {
        var data: [CGFloat]
        var min: ([CGFloat]) -> CGFloat = {$0.min()!}
        var max: ([CGFloat]) -> CGFloat = {$0.max()!}
        var maxNumData = 100
        
        init(data: [CGFloat]){
            self.data = data
        }

        public mutating func add(_ val: CGFloat) {
            self.data.append(val)
            if data.count > maxNumData {
                data.remove(at: 0)
            }
        }
        
        func transform(by rect: CGRect) -> [CGPoint]{
            var coordinates: [CGPoint] = []
            for (i,e) in data.enumerated() {
                let x: CGFloat = rect.origin.x + rect.size.width / CGFloat((data.count - 1)) * CGFloat(i)
                var minData = min(data), maxData = max(data)
                if minData == maxData {
                    minData -= 1
                    maxData += 1
                }
                let y: CGFloat = rect.maxY - (e - minData) / (maxData - minData) * rect.size.height
                coordinates.append(.init(x: x, y: y))
            }
            return coordinates
        }
    }
}
