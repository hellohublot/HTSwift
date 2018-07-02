//
//  ImageExtension.swift
//  HTSwift
//
//  Created by hublot on 2017/12/23.
//

import Foundation

public extension UIImage {
	
	static func from(_ color: UIColor) -> UIImage {
		let size = CGSize(width: 1, height: 1)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.set()
		UIRectFill(CGRect(origin: CGPoint.zero, size: size))
		let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
		UIGraphicsEndImageContext()
		return image
	}
	
	static func from(_ view: UIView) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
		if let context = UIGraphicsGetCurrentContext() {
			view.layer.render(in: context)
		}
		let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
		UIGraphicsEndImageContext()
		return image
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

public extension UIImage {
	
	func imageInsert(_ color: UIColor, _ edge: UIEdgeInsets) -> UIImage {
		let width = size.width + edge.left + edge.right
		let height = size.height + edge.top + edge.bottom
		var image = UIImage.from(color).imageWith(size: CGSize.init(width: width, height: height))
		image = image.imageAppend(self, at: CGPoint.init(x: edge.left, y: edge.top))
		return image
	}
	
	func imageAppend(_ image: UIImage, at origin: CGPoint) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		draw(in: CGRect(origin: CGPoint.zero, size: size))
		image.draw(at: origin)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image ?? self
	}
	
	func imageCropped(at rect: CGRect) -> UIImage {
		let frame = CGRect.init(x: rect.origin.x * scale,
								y: rect.origin.y * scale,
								width: rect.size.width * scale,
								height: rect.size.height * scale)
		var image = self
		if let imageRef = cgImage?.cropping(to: frame) {
			image = UIImage.init(cgImage: imageRef, scale: scale, orientation: imageOrientation)
		}
		return image
	}
	
}

public extension UIImage {
	
	func imageTintColor(_ tintColor: UIColor) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		let context = UIGraphicsGetCurrentContext()
		context?.translateBy(x: 0, y: size.height)
		context?.scaleBy(x: 1.0, y: -1.0)
		context?.setBlendMode(.normal)
		let frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
		context?.clip(to: frame, mask: cgImage!)
		tintColor.setFill()
		context?.fill(frame)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image ?? self
	}
	
}



