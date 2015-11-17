//The MIT License (MIT)
//
//Copyright (c) 2015 Ashley Hunter
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import UIKit

@IBDesignable class AHStepperControl: UIView {

    var context = UIGraphicsGetCurrentContext()
    
    //// Color Declarations
    @IBInspectable var stepperColor: UIColor = UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.000)
    @IBInspectable var stepperFillColor: UIColor = UIColor(red: 0.098, green: 0.655, blue: 0.510, alpha: 1.000)
    @IBInspectable var leftTextColor: UIColor = UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.000)
    @IBInspectable var rightTextColor: UIColor = UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.000)
    
    @IBInspectable var leftTextFont: UIFont = UIFont.systemFontOfSize(UIFont.labelFontSize())
    @IBInspectable var rightTextFont: UIFont = UIFont.systemFontOfSize(UIFont.labelFontSize())
    
    @IBInspectable var nodeCircumference: Double = 47;
    @IBInspectable var linkLength: Double = 20;
    @IBInspectable var linkThickness: Double = 5;
    @IBInspectable var nodeStrokeWidth: Double = 5;
    
    @IBInspectable var innerNodeOffset: Double = 11;
    
    @IBOutlet weak var stepperDataSource: NSObject?
    
    override func drawRect(rect: CGRect) {
        
        #if TARGET_INTERFACE_BUILDER
            self.drawDemoData(rect)
            return
        #endif
        
        if(stepperDataSource == nil) {
            return
        }
        
        let dataSource = stepperDataSource as! AHStepperDataSource
        
        let nodeCount = dataSource.stepperNodeCount()
        
        for(var i = 0; i < nodeCount; i++) {
            
            let yOffset = Double(i) * (nodeCircumference + linkLength)
            
            let node = dataSource.stepperNodeAtIndex(i)
            
            drawNode(node, x: rect.origin.x, y: CGFloat(yOffset), width: rect.width, height: rect.height, isLast: (i == (nodeCount - 1)))
        }
    }
    
    func drawDemoData(rect: CGRect) {
        let nodes: [AHStepperNode] = [
            AHStepperNode(isSelected: true, leftText: "10:30pm", rightText: "Station One"),
            AHStepperNode(isSelected: true, leftText: "10:40pm", rightText: "Station Two"),
            AHStepperNode(isSelected: true, leftText: "11:00pm", rightText: "Station Three"),
            AHStepperNode(isSelected: false, leftText: "11:30pm", rightText: "Station Four"),
            AHStepperNode(isSelected: false, leftText: "12:30pm", rightText: "Station Five")
        ]
        
        for(var i = 0; i < nodes.count; i++) {
            
            let yOffset = Double(i) * (self.nodeCircumference + linkLength)
            
            drawNode(nodes[i], x: rect.origin.x, y: CGFloat(yOffset), width: rect.width, height: rect.height, isLast: (i == (nodes.count - 1)))
        }
    }
    
    func drawNode(node: AHStepperNode, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isLast: Bool) {
        
        let center: Double = Double(width) / 2.0;
        
        //// Node Drawing
        
        let nodeX = CGFloat(center - (nodeCircumference / 2))
        let nodeY = y + CGFloat(linkThickness / 2.0)
        
        let nodePath = UIBezierPath(ovalInRect: CGRectMake(nodeX, nodeY, CGFloat(nodeCircumference), CGFloat(nodeCircumference)))
        UIColor.whiteColor().setFill()
        nodePath.fill()
        stepperColor.setStroke()
        nodePath.lineWidth = CGFloat(linkThickness)
        nodePath.stroke()
        
        if(node.isSelected) {
            //// InnerNode Drawing
            let innerNodeX = CGFloat(center - ((nodeCircumference - innerNodeOffset) / 2))
            let innerNodeY = nodeY + CGFloat(innerNodeOffset / 2)
            let innerWidth = CGFloat(nodeCircumference - innerNodeOffset)
            
            let innerNodePath = UIBezierPath(ovalInRect: CGRectMake(innerNodeX, innerNodeY, innerWidth, innerWidth))
            stepperFillColor.setFill()
            innerNodePath.fill()
        }
        
        if(node.leftText != "") {
            
            let leftTextWidth = CGFloat(center - nodeCircumference)
            
            let leftLabelRect = CGRectMake(0, nodeY, leftTextWidth, CGFloat(nodeCircumference))
            let leftLabelTextContent = NSString(string: node.leftText)
            let leftLabelStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            leftLabelStyle.alignment = NSTextAlignment.Right
            
            let leftLabelFontAttributes = [NSFontAttributeName: leftTextFont, NSForegroundColorAttributeName: leftTextColor, NSParagraphStyleAttributeName: leftLabelStyle]
            
            let leftLabelTextHeight: CGFloat = leftLabelTextContent.boundingRectWithSize(CGSizeMake(leftLabelRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: leftLabelFontAttributes, context: nil).size.height
            CGContextSaveGState(context)
            CGContextClipToRect(context, leftLabelRect);
            leftLabelTextContent.drawInRect(CGRectMake(leftLabelRect.minX, leftLabelRect.minY + (leftLabelRect.height - leftLabelTextHeight) / 2, leftLabelRect.width, leftLabelTextHeight), withAttributes: leftLabelFontAttributes)
            CGContextRestoreGState(context)
        }
        
        if(node.rightText != "") {
            
            let rightTextX = CGFloat(center + nodeCircumference)
            let rightTextWidth = width - rightTextX
            
            let rightLabelRect = CGRectMake(rightTextX, nodeY, rightTextWidth, CGFloat(nodeCircumference))
            let rightLabelTextContent = NSString(string: node.rightText)
            let rightLabelStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            rightLabelStyle.alignment = NSTextAlignment.Left
            
            let rightLabelFontAttributes = [NSFontAttributeName: rightTextFont, NSForegroundColorAttributeName: rightTextColor, NSParagraphStyleAttributeName: rightLabelStyle]
            
            let rightLabelTextHeight: CGFloat = rightLabelTextContent.boundingRectWithSize(CGSizeMake(rightLabelRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: rightLabelFontAttributes, context: nil).size.height
            CGContextSaveGState(context)
            CGContextClipToRect(context, rightLabelRect);
            
            rightLabelTextContent.drawInRect(CGRectMake(rightLabelRect.minX, rightLabelRect.minY + (rightLabelRect.height - rightLabelTextHeight) / 2, rightLabelRect.width, rightLabelTextHeight), withAttributes: rightLabelFontAttributes)
            CGContextRestoreGState(context)
        }
        
        
        if(isLast) {
            return
        }
        
        //// Link Drawing
        let linkX = CGFloat(center - (linkThickness / 2))
        let linkY = nodeY + CGFloat(nodeCircumference)
        
        let linkPath = UIBezierPath(rect: CGRectMake(linkX, linkY, CGFloat(linkThickness), CGFloat(linkLength)))
        stepperColor.setFill()
        linkPath.fill()
        
    }

}
