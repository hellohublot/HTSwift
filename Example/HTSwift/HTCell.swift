//
//  HTCell.swift
//  HTSwift_Example
//
//  Created by hublot on 2017/12/11.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import HTSwift

class HTCell: UITableViewCell, ReuseCell {
	
	func setModel(_ model: Any?, for indexPath: IndexPath) {
		self.textLabel?.text = String(indexPath.row)
	}
	
}
