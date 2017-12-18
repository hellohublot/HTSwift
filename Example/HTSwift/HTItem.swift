//
//  HTItem.swift
//  HTSwift_Example
//
//  Created by hublot on 2017/12/17.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import HTSwift

class HTItem: UICollectionViewCell, ReuseCell {
	func setModel(_ model: Any?, for IndexPath: IndexPath) {
		backgroundColor = UIColor(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1)
	}
}
