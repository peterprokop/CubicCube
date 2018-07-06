![Animated cube](http://i.imgur.com/A2PTLHa.gif)

CubicCube is a Swift GUI library for embedding view controllers on faces of cube
(well, technically it's a parallelepiped, but we'll call it a cube)

## Installation

### Manual
Just clone and add ```CubicViewController.swift``` to your project.

### Carthage
* `touch Cartfile`
* `nano Cartfile`
* put `github "peterprokop/CubicCube"` into Cartfile
* Save it: `ctrl-x`, `y`, `enter`
* Run `carthage update`
* Copy `CubicCube.framework` from `Carthage/Build/iOS` to your project
* Make sure that `CubicCube` is added in `Embedded Binaries` section of your target (or else you will get `dyld library not loaded referenced from ... reason image not found` error)
* Add `import CubicCube` on top of your view controller's code

### Cocoapods
Stop using this piece of crap. Seriously.

## Requirements
- Xcode 9.4.1+
- Swift 4.1

## Usage
Minimal working example is following:
```swift
import CubicCube

class ViewController: CubicViewController {
    required init(coder aDecoder: NSCoder) {
        let makeViewController = { (color: UIColor) -> UIViewController in
            let vc = UIViewController()
            vc.view.backgroundColor = color
            return vc
        }

        super.init(
            firstViewController: makeViewController(.red),
            secondViewController: makeViewController(.green),
            thirdViewController: makeViewController(.purple),
            fourthViewController: makeViewController(.orange)
        )
    }
}
```

Also please check example project in the repo.
