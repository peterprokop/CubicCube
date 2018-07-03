//
//  Created by Peter Prokop on 07/06/15.
//  Copyright (c) 2015 Peter Prokop. All rights reserved.
//

import UIKit

open class CubicViewController: UIViewController, UIGestureRecognizerDelegate {

    var subControllers: [UIViewController]!
    var rotationAngles: [CGFloat]!
    var visibleControllerIndex = 0
    var currentAngle = CGFloat(0)
    var didLayout = false
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    // Animation
    let numAnimationFrames = 180
    let turnBackAnimationDuration = TimeInterval(0.3)
    let startupAnimationDuration = TimeInterval(3)
    var currentScale = Double(0)
    
    var animationDuration = TimeInterval(0.3)
    var animIterator: Int = 0
    var delta = CGFloat(0)
    var animationTimer: Timer?
    var shouldIncrementScale = false
    
    var isStartupAnimationShown = false
    var onlyLeftSwipeAllowed = false

    public init(
        firstViewController: UIViewController,
        secondViewController: UIViewController,
        thirdViewController: UIViewController,
        fourthViewController: UIViewController
    ) {
        subControllers = [
            firstViewController,
            secondViewController,
            thirdViewController,
            fourthViewController,
        ]

        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGestureRecognizer)
        
        panGestureRecognizer.delegate = self
        panGestureRecognizer.cancelsTouchesInView = false
        
        rotationAngles = Array<CGFloat>(repeating: 0, count: subControllers.count)
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if didLayout {
            return
        }
        didLayout = true
        
        let center = CGPoint(x: view.bounds.size.width/2, y:view.bounds.size.height/2)

        var i = 0
        for vc in subControllers {
            let subview = vc.view!
            subview.center = center
            
            subview.alpha = 0
            view.addSubview(subview)
            subview.layer.transform = CATransform3DMakeScale(0, 0, 0)
            addChildViewController(vc)
            
            let angle = -Double(i) * Double.pi/2
            setViewRotation(index: i, angle: CGFloat(angle))

            i += 1
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for c in subControllers {
            c.viewDidAppear(animated)
        }
        
        if !isStartupAnimationShown {
            self.perform(#selector(beginStartupAnimation), with: nil, afterDelay: 1)
            isStartupAnimationShown = true
        }
    }
    
    func setViewRotation(index: Int, angle: CGFloat) {
        let view = subControllers[index].view!
        rotationAngles[index] += angle
        
        var scale = Double(abs(rotationAngles[index])).truncatingRemainder(dividingBy: Double.pi/2)
        scale = max(0.5, abs(Double.pi/4 - scale) / (Double.pi/4))
        
        if shouldIncrementScale {
            scale = currentScale
        }
        
        let rotationPointZ = CGFloat(-view.bounds.size.width / CGFloat(2.0) * CGFloat(scale))
        
        
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 1000

        // Compose translation & rotation to rotate around rotationPointZ
        transform = CATransform3DTranslate(transform,
            0,
            0,
            rotationPointZ);
        transform = CATransform3DRotate(transform, rotationAngles[index], 0.0, -1.0, 0.0);
        transform = CATransform3DTranslate(transform,
            0,
            0,
            -rotationPointZ);
        transform = CATransform3DScale(transform, CGFloat(scale), CGFloat(scale), CGFloat(scale))
        
        view.layer.transform = transform
    }

    
    @objc func animationTimerCallback() {
        var i = 0
        
        if animIterator != 0 {
            if shouldIncrementScale {
                currentScale += 1 / Double(numAnimationFrames)
            }
            
            for _ in self.subControllers {
                self.setViewRotation(index: i, angle: delta / CGFloat(numAnimationFrames))
                i += 1
            }
        } else {
            animationTimer!.invalidate()
            animationTimer = nil
            shouldIncrementScale = false
            panGestureRecognizer.isEnabled = true
            
            for vc in self.subControllers {
                if i != visibleControllerIndex {
                    vc.view.isHidden = true
                }
                i += 1
            }
        }
        
        animIterator -= 1
    }
    
    func rotateByAngle(angle: CGFloat, withDuration duration: TimeInterval, shouldIncrementScale: Bool = false) {
        delta = angle
        animationDuration = duration
        self.shouldIncrementScale = shouldIncrementScale
        currentScale = 0
        
        animIterator = numAnimationFrames
        panGestureRecognizer.isEnabled = false
        
        animationTimer = Timer.scheduledTimer(
            timeInterval: animationDuration / TimeInterval(numAnimationFrames),
            target: self,
            selector: #selector(animationTimerCallback),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func beginStartupAnimation() {
        UIView.animate(withDuration: 0.1) { () -> Void in
            for vc in self.subControllers {
                vc.view.alpha = 1
            }
        }
        
        rotateByAngle(angle: CGFloat.pi * 2, withDuration: startupAnimationDuration, shouldIncrementScale: true)
    }
    
    func showNearestFace() {
        let adjustedAngle = round(Double(currentAngle)/(Double.pi/2))
        
        let nearestIndex = Int(adjustedAngle)
        let angleDelta = CGFloat(Double.pi/2 * Double(nearestIndex)) - currentAngle
        visibleControllerIndex = nearestIndex % self.subControllers.count
        while visibleControllerIndex < 0 {
            visibleControllerIndex += 4
        }
        
        currentAngle = CGFloat.pi/2 * CGFloat(nearestIndex)
        
        rotateByAngle(angle: angleDelta, withDuration: turnBackAnimationDuration)
    }

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)

        if recognizer.state == .ended {
            showNearestFace()
        } else {
            if onlyLeftSwipeAllowed && translation.x > 0 {
                return
            }

            let rotationAngle = -1.5 * CGFloat.pi * translation.x / self.view.bounds.size.width

            for i in subControllers.indices {
                setViewRotation(index: i, angle: rotationAngle)
            }

            recognizer.setTranslation(CGPoint.zero, in: self.view)
            currentAngle += rotationAngle
        }
    }

    // MARK: UIGestureRecognizerDelegate
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let gc = gestureRecognizer as! UIPanGestureRecognizer
        let vel = gc.velocity(in: view)
        if fabs(vel.x) > fabs(vel.y) {
            view.endEditing(true)

            for vc in subControllers {
                vc.view.isHidden = false
            }

            return true
        }

        return false
    }
}
