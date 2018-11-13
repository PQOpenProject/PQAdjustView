//
//  PQAdjustView.swift
//  PQAdjustView
//
//  Created by 盘国权 on 2018/11/13.
//  Copyright © 2018 pgq. All rights reserved.
//

import UIKit

public enum PQAdjustViewShowType: Int {
    case white = 0
    case hueWhite
    case rgb
}

open class PQAdjustView: UIView {
    // MARK: - public typealias
    public typealias PQAdjustChangeBlock = (CGFloat) -> ()
    public typealias PQAdjustChangeColorBlock = (CGFloat, UIColor?) -> ()
    
    // MARK: - public property
    
    /// default is 0.1s
    open var dueTime: TimeInterval = 0.1
    /// default is 0
    public var progress: CGFloat = 0.5 {
        didSet {
            let height = progress * self.frame.height
            changeView.frame = CGRect(x: 0, y: height, width: changeView.bounds.width, height: self.frame.height - height)
        }
    }
    /// borderColor default .gray
    public var borderColor: UIColor = .gray {
        didSet {
            maskLayer.borderColor = borderColor.cgColor
        }
    }
    /// borderWidth default 1
    public var borderWidth: CGFloat = 0 {
        didSet {
            maskLayer.borderWidth = borderWidth
        }
    }
    
    /// default is .white
    public var showType: PQAdjustViewShowType = .white {
        didSet {
            if showType == .white {
                imageView.image = UIImage.adjust_drawImage(size: bounds.size, color: UIColor.lightText)
                changeView.backgroundColor = .white
                changeView.alpha = 1
                gradientLayer.removeFromSuperlayer()
            }
            
            if showType == .hueWhite {
                changeView.alpha = 0.85
                changeView.backgroundColor = .lightGray
                drawLayer([UIColor.yellow.cgColor, UIColor.white.cgColor], locations: [0.0,1.0])
            }
            
            if showType == .rgb {
                changeView.alpha = 0.85
                changeView.backgroundColor = .lightGray
                let colors = [UIColor.adjust_hex(0xff0000).cgColor,
                              UIColor.adjust_hex(0xff00ff).cgColor,
                              UIColor.adjust_hex(0x0000ff).cgColor,
                              UIColor.adjust_hex(0x00ffff).cgColor,
                              UIColor.adjust_hex(0x00ff00).cgColor,
                              UIColor.adjust_hex(0xffff00).cgColor,
                              UIColor.adjust_hex(0xff0000).cgColor]
                let locations = [0.0, 0.15, 0.33, 0.49, 0.67, 0.84, 1]
                drawLayer(colors, locations: locations as [NSNumber])
            }
        }
    }
    
    //MARK: - system method
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
        self.setValue(PQAdjustViewShowType.white, forKey: "showType")
        self.setValue(0.5, forKey: "progress")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
        self.setValue(PQAdjustViewShowType.white, forKey: "showType")
        self.setValue(0.5, forKey: "progress")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.mask = maskLayer
    }
    
    open override func setValue(_ value: Any?, forKey key: String) {
        if key == "progress" {
            self.progress = value as! CGFloat
        } else if key == "showType"{
            if let v = value as? NSNumber,
                let type = PQAdjustViewShowType(rawValue: v.intValue){
                self.showType = type
            } else if let type = value as? PQAdjustViewShowType {
                self.showType = type
            }
        }else {
            super.setValue(value, forKey: key)
        }
    }
    
    // MARK: - private property
    private lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = bounds
        let cornerRadius: CGFloat = frame.width - 20
        layer.path = UIBezierPath(roundedRect: CGRect(x: 10, y: 0, width: frame.width - 20, height: frame.height), cornerRadius: cornerRadius * 0.2).cgPath
        layer.borderWidth = self.borderWidth
        layer.borderColor = self.borderColor.cgColor
        return layer
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: bounds)
        return view
    }()
    
    private lazy var changeView: UIView = {
        let view = UIView(frame: bounds)
        view.alpha = 0.8
        return view
    }()
    
    private var gradientLayer: CAGradientLayer = CAGradientLayer()
    
    private var imageViewStartFrameYMax: CGFloat = 0
    private var imageViewStartHeightMax: CGFloat = 0
    private var imageViewStartFrameY: CGFloat = 0
    private var imageViewStartHeight: CGFloat = 0
    private var minValue: CGFloat = 0
    private var lastTimeinterval: TimeInterval = CFAbsoluteTimeGetCurrent()
    private var color: UIColor?
    private var lastRate: CGFloat = 0
    
    private var changeBlock: PQAdjustChangeBlock?
    private var changeColorBlock: PQAdjustChangeColorBlock?
}



// MARK: - public method
public extension PQAdjustView {
    public func change(_ block: PQAdjustChangeBlock?) {
        self.changeBlock = block
    }
    
    public func changColor(_ block: PQAdjustChangeColorBlock?) {
        self.changeColorBlock = block
    }
}


// MARK: - private method
private extension PQAdjustView {
    private func setUp() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)
        addSubview(imageView)
        addSubview(changeView)
        imageViewStartFrameYMax = bounds.origin.y
        imageViewStartHeightMax = bounds.height
    }
    
    private func drawLayer(_ colors: [CGColor], locations: [NSNumber]) {
        self.gradientLayer.removeFromSuperlayer()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 20
        //        layer.addSublayer(gradientLayer)
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        layer.insertSublayer(gradientLayer, at: 1)
    }
    
    private func viewFrameChange(_ view: UIView) {
        print(lastTimeinterval)
        let value = view.frame.height / imageViewStartHeightMax
        if let rate = Double(String(format: "%.2f", value)) {
            changeBlock?(CGFloat(rate))
            changeColorBlock?(CGFloat(rate), color)
        }
        
    }
}

extension PQAdjustView {
    @objc private func panGesture(_ panGesture: UIPanGestureRecognizer) {
        
        switch panGesture.state {
        case .began:
            imageViewStartFrameY = changeView.frame.origin.y
            imageViewStartHeight = changeView.frame.height
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 1.025, y: 1.025)
            }, completion: { _ in
                UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveLinear, animations: {
                    self.transform = CGAffineTransform.identity
                }, completion: nil)
            })
        case .changed:
            let translation = panGesture.translation(in: changeView.superview)
            let rect = CGRect(x: changeView.frame.origin.x, y: imageViewStartFrameY + translation.y, width: changeView.frame.width, height: imageViewStartHeight - translation.y)
            if rect.origin.y < imageViewStartHeightMax + imageViewStartFrameYMax {
                changeView.frame = CGRect(x: changeView.frame.origin.x, y: imageViewStartFrameY + translation.y, width: changeView.frame.width, height: imageViewStartHeightMax - translation.y)
            }
            if (rect.origin.y < imageViewStartFrameYMax) {
                changeView.frame = CGRect(x: changeView.frame.origin.x, y: imageViewStartFrameYMax, width: changeView.frame.width, height: imageViewStartHeightMax)
            } else {
                changeView.frame = CGRect(x: changeView.frame.origin.x, y: imageViewStartFrameY + translation.y, width: changeView.frame.width, height: imageViewStartHeight - translation.y)
            }
            
            if (rect.origin.y > imageViewStartHeightMax + imageViewStartFrameYMax - minValue) {
                changeView.frame = CGRect(x: changeView.frame.origin.x, y: imageViewStartHeightMax + imageViewStartFrameYMax - minValue, width: changeView.frame.width, height: minValue)
            }
            
            let currentTimeinterval = CFAbsoluteTimeGetCurrent()
            let offsetTime = currentTimeinterval - lastTimeinterval
            color = UIColor(hue: 1 - ((imageViewStartHeightMax - changeView.frame.height) / imageViewStartHeightMax), saturation: 1, brightness: 1, alpha: 1)
            
            
            if offsetTime >= dueTime {
                lastTimeinterval = currentTimeinterval
                viewFrameChange(changeView)
            }
            
        case .ended:
            viewFrameChange(changeView)
        case .cancelled, .failed, .possible:
            break
        }
        
    }
}


fileprivate extension UIImage {
    class func adjust_drawImage(size: CGSize, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        color.setFill()
        UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerRadius: 0).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

fileprivate extension UIColor {
    class func adjust_hex(_ value: Int64) -> UIColor {
        return UIColor(red: CGFloat((((value & 0xFF0000) >> 16))) / 255.0, green: CGFloat((((value & 0xFF00) >> 8))) / 255.0, blue: CGFloat(((value & 0xFF))) / 255.0, alpha: 1)
    }
}
