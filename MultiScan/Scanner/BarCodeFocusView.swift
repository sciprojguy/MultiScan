//
//  BarCodeFocusView.swift
//  CAB
//
//  Created by Chris Woodard on 5/14/18.
//  Copyright © 2018 Actsoft. All rights reserved.
//

import UIKit

@IBDesignable
class BarCodeFocusView: UIView {
    
    @IBInspectable
    var displayMode:Bool
    @IBInspectable
    var linethickness:CGFloat = 6
    @IBInspectable
    var scanLineThickness:CGFloat = 2
    
    override init(frame: CGRect) {
        self.displayMode = false
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.displayMode = false
        super.init(coder:aDecoder)
    }
    
    var isScanning:Bool {
        get {
            return displayMode
        }
        
        set {
            displayMode = newValue
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
     
        let focusFrame = self.bounds
        let xLeft = focusFrame.origin.x
        let yTop = focusFrame.origin.y
        let xRight = focusFrame.origin.x + focusFrame.size.width
        let yBottom = focusFrame.origin.y + focusFrame.size.height
        
        let thePath = UIBezierPath()
        
        thePath.lineWidth = linethickness
        
        //top left
        thePath.move(to: CGPoint(x: xLeft, y: yTop))
        thePath.addLine(to: CGPoint(x: xLeft, y: yTop + 24))
        thePath.move(to: CGPoint(x: xLeft, y: yTop))
        thePath.addLine(to: CGPoint(x: xLeft + 24, y: yTop))

        //top right
        thePath.move(to: CGPoint(x: xRight, y: yTop))
        thePath.addLine(to: CGPoint(x: xRight, y: yTop + 24))
        thePath.move(to: CGPoint(x: xRight, y: yTop))
        thePath.addLine(to: CGPoint(x: xRight - 24, y: yTop))

        //bottom left
        thePath.move(to: CGPoint(x: xLeft, y: yBottom))
        thePath.addLine(to: CGPoint(x: xLeft, y: yBottom - 24))
        thePath.move(to: CGPoint(x: xLeft, y: yBottom))
        thePath.addLine(to: CGPoint(x: xLeft + 24, y: yBottom))

        //bottom right
        thePath.move(to: CGPoint(x: xRight, y: yBottom))
        thePath.addLine(to: CGPoint(x: xRight, y: yBottom - 24))
        thePath.move(to: CGPoint(x: xRight, y: yBottom))
        thePath.addLine(to: CGPoint(x: xRight - 24, y: yBottom))

        if(self.displayMode) {
            UIColor.red.setStroke()
        }
        else {
            UIColor.lightGray.setStroke()
        }
        
        thePath.stroke()
        
        if(self.displayMode) {
            UIColor.red.setStroke()
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: xLeft + 8, y: yTop + (yBottom-yTop)/2))
            linePath.addLine(to: CGPoint(x: xRight - 8, y: yTop + (yBottom-yTop)/2))
            linePath.lineWidth = 2
            linePath.stroke()
        }

     }
}
