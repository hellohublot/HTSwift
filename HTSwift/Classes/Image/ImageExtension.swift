//
//  ImageExtension.swift
//  HTSwift
//
//  Created by hublot on 2017/12/23.
//

import Foundation

public extension UIImage {
	
	convenience init(_ color: UIColor) {
		let size = CGSize.zero
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.set()
		UIRectFill(CGRect(origin: CGPoint.zero, size: size))
		let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage ?? UIImage().cgImage!
		UIGraphicsEndImageContext()
		self.init(cgImage: image)
	}
	
}

extension UIImage: HTSwiftCompatible {}

public extension HTBox where Base: UIImage {
	
	func imageWith(size: CGSize) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		base.draw(in: CGRect(origin: CGPoint.zero, size: size))
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image ?? base
	}
	
	func imageWith(zoom: CGFloat) -> UIImage {
		var zoomSize = base.size
		zoomSize.width *= zoom
		zoomSize.height *= zoom
		return imageWith(size: zoomSize)
	}
	
}



