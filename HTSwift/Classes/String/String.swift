//
//  StringExtension.swift
//  HTSwift
//
//  Created by hublot on 2017/12/24.
//

import Foundation

public extension String {
	
	var ns: NSString {
		return self as NSString
	}
	
	func height(_ font: UIFont, _ width: CGFloat) -> CGFloat {
		let string = self.ns
		let height = string.boundingRect(with: CGSize(width: width, height: 0), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: font], context: nil).size.height
		return height
	}

}

