//
//  UniverseView.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/23/17. Best custom view class I ever created. I put in my life.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

@IBDesignable class UniverseView: UIView {
    @IBInspectable var initialCellSize: CGFloat = 10
    @IBInspectable var maxCellSize: CGFloat = 100
    @IBInspectable var minCellSize: CGFloat = 0.7
    @IBInspectable var initialGridLineWidth: CGFloat = 1
    @IBInspectable var symbolLineWidth: CGFloat = 3
    @IBInspectable var symbolUniversalTint: UIColor = UIColor.black.withAlphaComponent(0.85)
    @IBInspectable var gridVisibleThreshold: CGFloat = 0.9
    @IBInspectable var gridVisible: Bool = true
    @IBInspectable var aliveColor: UIColor = UIColor.black.withAlphaComponent(0.7) {
        didSet {
            delegate?.cellColorDidChange(color: aliveColor)
            let rgb = aliveColor.rgb()
            symbolUniversalTint = UIColor(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: 0.85)
        }
    }
    @IBInspectable var gridColor: UIColor = UIColor.black
    override var backgroundColor: UIColor? {
        didSet {
            super.backgroundColor = backgroundColor
            delegate?.backgroundColorDidChange(color: backgroundColor!)
        }
    }
    var cellStyle: CellStyle = .ellipse
    
    static var gradientFill = false
    static var gradientFillBrightness: CGFloat = 1.0
    static var gradientFillSaturation: CGFloat = 1.0
    static var gradientFillStart: CGFloat = 0.0
    static var gradientFillEnd: CGFloat = 1.0
    
    public enum CellStyle {
        case rect, ellipse
    }
    
    public enum RenderingMode: CGFloat {
        case balanced = 0.1875
        case better = 0.125
        case faster = 0.25
    }
    
    var delegate: UniverseViewDelegate?

    var maxAllowedRenderingduration: Int = 250 //max allowed rendering duration for root visualization.
    var ctr: CGPoint = .init(x: 0, y: 0) //universe center translation
    var panAcc = Vec2D() //a 2D vector library implemented in swift by Jiachen Ren. Transcribed from PVector.
    var zoomVelocity: CGFloat = 0
    var root: HashedTreeNode! //root to be decomposed for drawing
    var nodeRadius: CGFloat! //computed radius of the cell
    var nodeRadiusScale: CGFloat = 1 //range from 0 to 1, can only make cells smaller.
    
    var baseLevelExponent: RenderingMode = .balanced //recommended range is between 0.125 to 0.25 or (1/8 ~ 1/4)
    var baseLevel: Int!
    var resolution: CGFloat {
        return bounds.height * bounds.width //determines the resolution of the display
    }
    var renderingCanceled: Bool = false
    var longPressCanceled: Bool = false

    //crucial part for controlling the resolution of the view
    var startDate: Int!
    var millisPerFrame: Int?
    var balance: CGFloat = 0

    var context: CGContext? {
        return UIGraphicsGetCurrentContext()
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        UIColor.red.setFill()
        CGContext.fillCircle(center: ctr, radius: 2)
        gridColor.setStroke()
        if initialGridLineWidth > gridVisibleThreshold && gridVisible {
            pathForGrid().stroke()
        }
        if root == nil {
            return
        }
        //calculate the node radius
        let tmp = (initialCellSize / 2 - initialGridLineWidth / 2) * nodeRadiusScale
        self.nodeRadius = tmp < minCellSize ? minCellSize : tmp

        //calculate the current view port
        let vp = self.getUniverseViewPort()
        //determine the ratio of cells on screen and the pixels on screen
        let ratio = CGFloat(vp.numCells()) / (self.resolution)

        //determine the level that corresponds to the maximum resolution of the screen
        //the depth level is also adjusted according to how fast the view is refreshing
        var level = Int(pow(ratio, baseLevelExponent.rawValue) + balance)
        level = level >= root.lev - 1 ? root.lev - 1 : level < 1 ? 1 : level
        baseLevel = level

        //test the speed, if the app is slowing down then reduce the resolution.
        startDate = Date().millisecondsSince1970
        aliveColor.setFill()

        visualizeRoot(node: root, upperLeft: vp.upperLeft, lowerRight: vp.lowerRight, offset: (0, 0))
        refreshRenderingStatus()

        //visualize long press
        if let del = delegate, del.hasRecognizedLongPress() {
            let completionInfo = del.longPressCompletionInfo()
            self.visualizeLongPressProgress(with: completionInfo)
            if completionInfo.0 >= 1 && !longPressCanceled {
                delegate?.longPressCompleted()
            }
        }

        //visualize simulator speed change
        if let del = delegate, del.twoFingerPanIsInProgress() {
            let percentage = del.simulatorSpeedPercentage()
            self.visualizeSimulatorSpeedChange(percentage)
        }
    }

    private func visualizeLongPressProgress(with info: (percentage: CGFloat, center: CGPoint)) {
        if info.0 >= 1 || info.center.x == 0.0 {
            return
        }
        context?.saveGState()
        context?.translateBy(x: bounds.midX, y: bounds.midY)
        context?.rotate(by: CGFloat.pi * 2 / 6 * info.percentage)
        let triangle = pathForPolygon(radius: 20, sides: 6)
        triangle.lineWidth = symbolLineWidth
        triangle.lineCapStyle = .round
        symbolUniversalTint.setStroke()
        triangle.stroke()
        context?.restoreGState()
    }
    
    private func pathForPolygon(radius: CGFloat, sides: Int) -> UIBezierPath {
        let path = UIBezierPath()
        let step = CGFloat.pi * 2 / CGFloat(sides)
        path.move(to: Vec2D(x: cos(step), y: sin(step)).setMag(radius).cgPoint)
        for i in 1...sides {
            let angle = step * CGFloat(i + 1)
            let pointer = Vec2D(x: cos(angle), y: sin(angle))
                .setMag(radius).cgPoint
            path.addLine(to: pointer)
        }
        return path
    }

    private func refreshRenderingStatus() {
        //the resolution of the root visualization is balanced with rendering speed 
        //with this following segment of code.
        let cur = Date().millisecondsSince1970 - startDate
        if renderingCanceled {
            balance += 1
        } else if millisPerFrame != nil {
            if balance > 0 && cur < millisPerFrame! {
                balance -= 0.1
            }
        }
        self.millisPerFrame = cur
        renderingCanceled = false
    }

    private func drawNode(at loc: Coordinate) {
        let center = self.convertToPosInSelf(from: loc)
        //TODO: customization for gradient fill
        if UniverseView.gradientFill {
            let dist = Vec2D(point: center).dist(Vec2D(x: bounds.midX, y: bounds.midY))
            let weighted = Utils.map(dist, 0, bounds.width, UniverseView.gradientFillStart, UniverseView.gradientFillEnd)
            UIColor(hue: weighted, saturation: UniverseView.gradientFillSaturation, brightness: UniverseView.gradientFillBrightness, alpha: 1).setFill()
        }
        switch cellStyle {
        case .rect: UIBezierPath(rect: CGRect(center: center, size: CGSize(width: nodeRadius * 2, height: nodeRadius * 2))).fill()
        case .ellipse: CGContext.fillCircle(center: center, radius: nodeRadius)
        }
        
    }

    //AS OF JULY 15TH, ACCELERATION SUCCEEDED.
    //YES!!! YES!! YES I DID IT!!! IT IS NOW OFFICIALLY COMPLET AS OF JULY 24TH, 2:21PM! YES!!!!
    private func visualizeRoot(node: HashedTreeNode, upperLeft: Coordinate, lowerRight: Coordinate, offset: Coordinate) {
        if node.lev == baseLevel {
            if node.lev == 1 {
                if node.se.alive {
                    drawNode(at: offset)
                }
                if node.sw.alive {
                    drawNode(at: (offset.x - 1, offset.y))
                }
                if node.ne.alive {
                    drawNode(at: (offset.x, offset.y - 1))
                }
                if node.nw.alive {
                    drawNode(at: (offset.x - 1, offset.y - 1))
                }
            } else {
                let offsetToSubnode = node.offsetToSubnode()
//                nodeRadius = CGFloat(node.lev) * initialCellSize
                if node.se.alive {
                    drawNode(at: (offset.x + offsetToSubnode, offset.y + offsetToSubnode))
                }
                if node.sw.alive {
                    drawNode(at: (offset.x - offsetToSubnode, offset.y + offsetToSubnode))
                }
                if node.ne.alive {
                    drawNode(at: (offset.x + offsetToSubnode, offset.y - offsetToSubnode))
                }
                if node.nw.alive {
                    drawNode(at: (offset.x - offsetToSubnode, offset.y - offsetToSubnode))
                }
            }
            renderingCanceled = Date().millisecondsSince1970 - startDate > maxAllowedRenderingduration
            return
        }
        if node.pop == 0 {
            return
        } //would it be faster to put this before lev == 1?
        let offsetToSubnode = node.offsetToSubnode()
        if lowerRight.x >= offset.x { //east
            //process right quadrant
            if upperLeft.y < offset.y {
                // process upper right quadrant (ne)
                let offset2D = (x: offsetToSubnode, y: -offsetToSubnode)
                self.visualizeRoot(
                        node: node.ne,
                        upperLeft: upperLeft,
                        lowerRight: lowerRight,
                        offset: offset + offset2D
                )
            }

            if lowerRight.y >= offset.y {
                //process lower right quadrant (se)
                let offset2D = (x: offsetToSubnode, y: offsetToSubnode)
                self.visualizeRoot(
                        node: node.se,
                        upperLeft: upperLeft,
                        lowerRight: lowerRight,
                        offset: offset + offset2D
                )
            }
        }
        if upperLeft.x < offset.x { //west
            //process left quadrant
            if upperLeft.y < offset.y {
                // process upper left quadrant (nw)
                let offset2D = (x: -offsetToSubnode, y: -offsetToSubnode)
                self.visualizeRoot(
                        node: node.nw,
                        upperLeft: upperLeft,
                        lowerRight: lowerRight,
                        offset: offset + offset2D
                )
            }

            if lowerRight.y >= offset.y {
                //process lower left quadrant (sw)
                let offset2D = (x: -offsetToSubnode, y: offsetToSubnode)
                self.visualizeRoot(
                        node: node.sw,
                        upperLeft: upperLeft,
                        lowerRight: lowerRight,
                        offset: offset + offset2D
                )
            }
        }

    }


    private func pathForGrid() -> UIBezierPath {
        let gridPath = UIBezierPath()
        var offsetY = (ctr.y < bounds.minY ? ctr.y : ctr.y - bounds.minY).truncatingRemainder(dividingBy: initialCellSize)
        var offsetX = (ctr.x < bounds.minX ? ctr.x : ctr.x - bounds.minX).truncatingRemainder(dividingBy: initialCellSize)
        while offsetY < bounds.maxY {
            gridPath.move(to: CGPoint(x: bounds.minX, y: offsetY))
            gridPath.addLine(to: CGPoint(x: bounds.maxX, y: offsetY))
            offsetY += initialCellSize
        }
        while offsetX < bounds.maxX {
            gridPath.move(to: CGPoint(x: offsetX, y: bounds.minY))
            gridPath.addLine(to: CGPoint(x: offsetX, y: bounds.maxY))
            offsetX += initialCellSize
        }
        gridPath.lineWidth = initialGridLineWidth
        return gridPath
    }


    public func respondTo(scale: CGFloat, at center: CGPoint) {
        if initialCellSize * scale > maxCellSize {
            initialCellSize = maxCellSize
            return
        }

        initialCellSize = initialCellSize * scale
        initialGridLineWidth = initialCellSize / 10 //TODO: might put a maximum limit on this.

        //Calculate the escaping direction of <#self.ctr#> to create an optical illusion.
        //This way users will be able to scale to exactly where they wanted on the screen
        //Again, this is made possible with my vector library. I cannot believe I figured this out myself!
        let escapeDir = Vec2D(point: self.ctr)
                .sub(Vec2D(point: center)) //translate to <#center#>'s coordinate system by subtracting it
                .mult(scale) //elongate or shrink according to the scale.

        //Compensating change in coordinate, since escapeDir is now in <#center#>'s coordinate system.
        self.ctr = escapeDir
                .add(Vec2D(point: center))
                .cgPoint //Optical illusion so that the view will move to desired location.

        setNeedsDisplay()
    }

    public func respondTo(translation: CGPoint) {
        ctr = ctr.translate(by: translation)
        setNeedsDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }

    //Construct the bounds of the nodes that are currently in display.
    public func getUniverseViewPort() -> UniverseViewPort {
        let upperLeft = convertToNodePos(from: posInUniverse(from: bounds.origin))
        let lowerRight = convertToNodePos(from: posInUniverse(from: CGPoint(x: bounds.maxX, y: bounds.maxY)))
        return UniverseViewPort(
                upperLeft: upperLeft,
                upperRight: convertToNodePos(from: posInUniverse(from: CGPoint(x: bounds.maxX, y: bounds.minY))),
                lowerLeft: convertToNodePos(from: posInUniverse(from: CGPoint(x: bounds.minX, y: bounds.maxY))),
                lowerRight: lowerRight,
                baseLevel: baseLevel
        )
    }

    //The intention of this method is to boost performance by only marking
    //areas with updated cells invalid and only redraw these ones. 
    //Does not know if this is going to work yet.
    public func receiveUpdatedRoot(_ root: HashedTreeNode) {
        //Should compare the cached <#livingNodes#> with <#updatedNodes#> and
        //only mark the ones that are changed for redrawing for better performance. (Theoretically.)
        self.root = root
        self.setNeedsDisplay()
    }

    //Took me a lot of drawings to figure this coordinate system out...
    //Returns the raw coordinate, not the actual node coordinate.
    public func posInUniverse(from posInSelf: CGPoint) -> CGPoint {
        return Vec2D(point: posInSelf)
                .add(Vec2D(point: ctr)
                        .mult(-1))
                .cgPoint
    }

    //Convert to actual node coordinate in the universe.
    public func convertToNodePos(from posInUniv: CGPoint) -> Coordinate {
        func biasedInt(_ n: CGFloat) -> Int {
            return n >= 0 ? Int(n) : Int(n) - 1
        }

        return (biasedInt(posInUniv.x / initialCellSize), biasedInt(posInUniv.y / initialCellSize))
    }

    private func convertToPosInSelf(from nodePos: (x: Int, y: Int)) -> CGPoint {
        func revertBiasedInt(_ n: Int) -> CGFloat {
            return CGFloat(n) + 0.5
        }

        return Vec2D(x: revertBiasedInt(nodePos.x) * initialCellSize, y: revertBiasedInt(nodePos.y) * initialCellSize)
                .sub(Vec2D(point: ctr).mult(-1))
                .cgPoint
    }


    //dynamic switch of cells. Might not work, because the root is immutable.
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let numTouches = event?.allTouches?.count
        if numTouches == 1 && !didDeepPress {
            if let pos = touches.first?.location(in: self) {
                let coordinate = convertToNodePos(from: posInUniverse(from: pos))
                delegate?.didTouch(at: coordinate)
            }
        } else if numTouches == 2 {
            delegate?.didTouchWithTwoFingers()
        }
        didDeepPress = false
    }
    
    private var didDeepPress = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        didDeepPress = false
    }

    
    //same effect as long press
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let first = touches.first else {return}
        let normalized = first.force / first.maximumPossibleForce
        if normalized > 0.75 && !didDeepPress {
            delegate?.longPressCompleted()
            didDeepPress = true
        }

    }

    //draws a stream of arrows.
    private func visualizeSimulatorSpeedChange(_ percentage: CGFloat) {
        guard let ctx = context else {
            return
        }
        let path = pathForArrow(width: 12, height: 6)
        ctx.saveGState()
        symbolUniversalTint.setStroke()
        ctx.translateBy(x: bounds.midX, y: bounds.height - 2)
        stride(from: 0, to: percentage, by: 0.02).enumerated().forEach { (i, _) in
            if i != 0 {
                ctx.translateBy(x: 0, y: -bounds.height * 0.02)
            }
            path.stroke()
        }
        ctx.restoreGState()
    }

    private func pathForArrow(width: CGFloat, height: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -width / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -height))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.lineWidth = symbolLineWidth
        path.lineCapStyle = .round
        return path
    }
    
    public func inheritAppearance(from view: UniverseView) {
        self.gridColor = view.gridColor
        self.gridVisibleThreshold = view.gridVisibleThreshold
        self.gridVisible = view.gridVisible
        self.aliveColor = view.aliveColor
        self.root = view.root
        self.backgroundColor = view.backgroundColor
        self.nodeRadiusScale = view.nodeRadiusScale
        self.cellStyle = view.cellStyle
    }
}

protocol UniverseViewDelegate {
    func didTouch(at coordinate: Coordinate)
    func didTouchWithTwoFingers()
    func hasRecognizedLongPress() -> Bool
    func longPressCompletionInfo() -> (percentage: CGFloat, center: CGPoint)
    func twoFingerPanIsInProgress() -> Bool
    func simulatorSpeedPercentage() -> CGFloat
    func longPressCompleted()
    func backgroundColorDidChange(color: UIColor)
    func cellColorDidChange(color: UIColor)
}

public struct UniverseViewPort {
    let upperLeft: Coordinate
    let upperRight: Coordinate
    let lowerLeft: Coordinate
    let lowerRight: Coordinate
    let baseLevel: Int?
    var cols: Int {
        return lowerRight.x - upperLeft.x
    }
    var rows: Int {
        return lowerRight.y - upperLeft.y
    }

    func numCells() -> Int64 {
        return Int64(cols * rows)
    }
}
