//
//  BVSlider.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/11/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import QuartzCore

class BVSliderTrackLayer: CALayer {
    weak var slider: BVSlider?
    
    override func draw(in ctx: CGContext) {
        if let slider = self.slider {
            // Clip
            let cornerRadius = bounds.height * slider.curvaceousness / 2.0
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            ctx.addPath(path.cgPath)
            
            // Fill the track
            ctx.setFillColor(slider.trackTintColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        }
    }
}


class BVSliderThumbLayer: CALayer {
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var slider: BVSlider?
    
    override func draw(in ctx: CGContext) {
        if let slider = slider {
            let thumbFrame = bounds.insetBy(dx: 1, dy: 1)
            let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            // Fill
            ctx.setFillColor(slider.thumbTintColor.cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
            
            // Outline
            let strokeColor = UIColor.gray
            ctx.setStrokeColor(strokeColor.cgColor)
            ctx.setLineWidth(0.25)
            ctx.addPath(thumbPath.cgPath)
            ctx.strokePath()
            
            if highlighted {
                ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
                ctx.addPath(thumbPath.cgPath)
                ctx.fillPath()
            }
        }
    }
}

class BVSlider: UIControl {
    var trackLayer = BVSliderTrackLayer()
    let thumbLayer = BVSliderThumbLayer()
    
    var isFinished = false
    
    fileprivate var previouslocation = CGPoint()

    var currentValue: Double = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }

    var minimumValue: Double = 0.0 {
        willSet(newValue) {
            assert(newValue < maximumValue, "RangeSlider: minimumValue should be lower than maximumValue")
        }
        didSet {
            updateLayerFrames()
        }
    }
    
    var maximumValue: Double = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var trackTintColor: UIColor = Constants.sliderHighlightColor() {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var thumbTintColor: UIColor = UIColor.white {
        didSet {
            thumbLayer.setNeedsDisplay()
        }
    }
    
    var curvaceousness: CGFloat = 1.0 {
        didSet(newValue) {
            if newValue < 0.0 {
                curvaceousness = 0.0
            }
            
            if newValue > 1.0 {
                curvaceousness = 1.0
            }
            
            trackLayer.setNeedsDisplay()
            thumbLayer.setNeedsDisplay()
        }
    }
    
    var thumbWidth: CGFloat {
        return CGFloat(bounds.height * 3.0) / 2.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.trackTintColor = UIColor.black

        trackLayer.slider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        thumbLayer.slider = self
        thumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(thumbLayer)
        
        updateLayerFrames()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }

    func positionForValue(_ value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height/3)
        trackLayer.setNeedsDisplay()
        
        let thumbCenter = CGFloat(positionForValue(self.currentValue))
        thumbLayer.frame = CGRect(x: thumbCenter - thumbWidth/2.0, y: -4.0, width: thumbWidth, height: thumbWidth)
        thumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    // MARK: - Touches
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.isFinished = false
        previouslocation = touch.location(in: self)
        
        print("current value \(currentValue) touch \(previouslocation.x)")
        
        // Hit test the thumb layers
        if thumbLayer.frame.contains(previouslocation) {
            thumbLayer.highlighted = true
        }
        
        return thumbLayer.highlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previouslocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        
        previouslocation = location
        
        // Update the values
        if thumbLayer.highlighted {
            if currentValue + deltaValue >= self.minimumValue && currentValue + deltaValue <= self.maximumValue {
                currentValue = currentValue + deltaValue
            }
        }
        print("updated value \(currentValue) deltaLocation \(deltaLocation)")

        sendActions(for: .valueChanged)
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        thumbLayer.highlighted = false
    }
}
