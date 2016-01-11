
//  See http://www.raywenderlich.com/76433/how-to-make-a-custom-control-swift for info on implementing range slider
//

import UIKit
import QuartzCore

class RangeSliderTrackLayer: BVSliderTrackLayer {
    override func drawInContext(ctx: CGContext) {
        if let rangeSlider = self.slider as? RangeSlider {
            super.drawInContext(ctx)
            
            // Fill the highlighted range
            CGContextSetFillColorWithColor(ctx, rangeSlider.trackHighlightTintColor.CGColor)
            let lowerValuePosition = CGFloat(rangeSlider.positionForValue(rangeSlider.lowerValue))
            let upperValuePosition = CGFloat(rangeSlider.positionForValue(rangeSlider.upperValue))
            let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition - 1, height: bounds.height)
            CGContextFillRect(ctx, rect)
        }
    }
}

class RangeSlider: BVSlider {
    var lowerValue: Double = 0.2 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var upperValue: Double = 0.8 {
        didSet(newValue) {
            updateLayerFrames()
        }
    }
    
    var gapBetweenThumbs: Double {
        return Double(thumbWidth)*(maximumValue - minimumValue) / Double(bounds.width)
    }
    
    var trackHighlightTintColor: UIColor = Constants.blueColor() {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    private var previouslocation = CGPoint()
    
    private let lowerThumbLayer = BVSliderThumbLayer()
    private let upperThumbLayer = BVSliderThumbLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.trackLayer = RangeSliderTrackLayer()

        trackLayer.slider = self
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.slider = self
        lowerThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.slider = self
        upperThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(upperThumbLayer)

        updateLayerFrames()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height/3)
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth/2.0, y: -4.0, width: self.thumbWidth, height: self.thumbWidth)
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth/2.0, y: -4.0, width: self.thumbWidth, height: self.thumbWidth)
        upperThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    // MARK: - Touches
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        self.isFinished = false
        previouslocation = touch.locationInView(self)
        
        // Hit test the thumb layers
        if lowerThumbLayer.frame.contains(previouslocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previouslocation) {
            upperThumbLayer.highlighted = true
        }
        
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
    
        // Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previouslocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        
        previouslocation = location
        
        // Update the values
        if lowerThumbLayer.highlighted {
            lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gapBetweenThumbs)
        } else if upperThumbLayer.highlighted {
            upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gapBetweenThumbs, upperValue: maximumValue)
        }
        
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
}
