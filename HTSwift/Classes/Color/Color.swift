//
//  ColorExtension.swift
//  HTSwift
//
//  Created by hublot on 2017/12/23.
//

import Foundation

public extension UIColor {
	
	convenience init(_ array: [Int]) {
		guard array.count >= 3 else {
			self.init(white: 1, alpha: 0)
			return
		}
		let valueArray = array[0..<3].map {item -> CGFloat in
			return CGFloat(item) / 255
		}
		let alpha = array.count > 3 ? array[3] : 255
		self.init(red: valueArray[0], green: valueArray[1], blue: valueArray[2], alpha: CGFloat(alpha) / 255.0)
	}
	
}
