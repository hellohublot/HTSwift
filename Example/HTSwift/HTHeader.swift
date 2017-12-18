//
//  HTHeader.swift
//  HTSwift_Example
//
//  Created by hublot on 2017/12/17.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import HTSwift

class HTHeader: UICollectionReusableView, ReuseCell {
	
	func setModel(_ model: Any?, for IndexPath: IndexPath) {
		backgroundColor = UIColor.orange
	}
	
}
