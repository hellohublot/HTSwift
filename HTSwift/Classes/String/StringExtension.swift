//
//  StringExtension.swift
//  HTSwift
//
//  Created by hublot on 2017/12/24.
//

import Foundation

public class StringProxy {
	public let base: String
	public init(_ base: String) {
		self.base = base
	}
}

extension String: HTSwiftCompatible {
	public var h: StringProxy {
		return StringProxy(self)
	}
}

public extension StringProxy {
	
	var origin: NSString {
		return base as NSString
	}
	
	func height(_ font: UIFont, _ width: CGFloat) -> CGFloat {
		let string = self.origin
		let height = string.boundingRect(with: CGSize(width: width, height: 0), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: font], context: nil).size.height
		return height
	}

}

