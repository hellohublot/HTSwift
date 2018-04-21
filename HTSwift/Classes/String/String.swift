//
//  StringExtension.swift
//  HTSwift
//
//  Created by hublot on 2017/12/24.
//

import Foundation

public extension String {
	
	func size(_ font: UIFont, _ size: CGSize) -> CGSize {
		let attributedString = NSAttributedString.init(string: self, attributes: [
			NSAttributedStringKey.font: font
		])
		return attributedString.size(font, size)
	}
	
	func height(_ font: UIFont, _ width: CGFloat) -> CGFloat {
		return size(font, CGSize.init(width: width, height: 0)).height
	}
	
	func width(_ font: UIFont, _ height: CGFloat) -> CGFloat {
		return size(font, CGSize.init(width: 0, height: height)).width
	}

}

extension NSAttributedString {
	
	func size(_ font: UIFont, _ size: CGSize) -> CGSize {
		return self.boundingRect(with: size, options: [
			.usesLineFragmentOrigin,
			.usesFontLeading
		], context: nil).size
	}
	
}

