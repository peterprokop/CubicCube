//
//  ViewController.swift
//  CubicCubeExample
//
//  Created by Peter Prokop on 02/07/2018.
//  Copyright © 2018 Peter Prokop. All rights reserved.
//

import UIKit
import CubicCube

class ViewController: CubicViewController {

    var backgroundIV: UIImageView?

    required init(coder aDecoder: NSCoder) {
        let makeViewController = { (color: UIColor, text: String) -> UIViewController in
            let vc = UIViewController()
            vc.view.backgroundColor = color

            let label = UILabel()
            label.textAlignment = .center
            label.text = text
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 72, weight: .medium)
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            label.frame = vc.view.bounds
            vc.view.addSubview(label)

            return vc
        }

        super.init(
            firstViewController: makeViewController(UIColor(red: 0xf1/255.0, green: 0x6a/255.0, blue: 0x70/255.0, alpha: 1.0), "1"),
            secondViewController: makeViewController(UIColor(red: 0xb1/255.0, green: 0xd8/255.0, blue: 0x77/255.0, alpha: 1.0), "2"),
            thirdViewController: makeViewController(UIColor(red: 0x8c/255.0, green: 0xdc/255.0, blue: 0xda/255.0, alpha: 1.0), "3"),
            fourthViewController: makeViewController(UIColor(red: 0x4d/255.0, green: 0x4d/255.0, blue: 0x4d/255.0, alpha: 1.0), "4")
        )
    }

    override func viewDidLayoutSubviews() {
        if backgroundIV == nil {
            let img = UIImage(named: "background")
            backgroundIV = UIImageView(image: img)
            backgroundIV!.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, -1600);

            view.addSubview(backgroundIV!)
        }

        backgroundIV?.frame = view.bounds

        super.viewDidLayoutSubviews()
    }

}
