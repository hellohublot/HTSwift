//
//  ImageExtension.swift
//  HTSwift
//
//  Created by hublot on 2017/12/23.
//

import Foundation

public extension UIImage {
	
	convenience init(_ color: UIColor) {
		let size = CGSize(width: 1, height: 1)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.set()
		UIRectFill(CGRect(origin: CGPoint.zero, size: size))
		let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage ?? UIImage().cgImage!
		UIGraphicsEndImageContext()
		self.init(cgImage: image)
	}
	
}

public extension UIImage {
	
	func imageWith(size: CGSize) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		draw(in: CGRect(origin: CGPoint.zero, size: size))
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image ?? self
	}
	
	func imageWith(zoom: CGFloat) -> UIImage {
		var zoomSize = size
		zoomSize.width *= zoom
		zoomSize.height *= zoom
		return imageWith(size: zoomSize)
	}
	
}



