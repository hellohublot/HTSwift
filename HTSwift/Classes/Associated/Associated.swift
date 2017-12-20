

import Foundation

struct AssociatedManager {
	static var AssociatedKeyValue:[String:Any] = [:]
	static func point(forKey key: String) -> UnsafeRawPointer {
		let value = AssociatedKeyValue[key] ?? {
			var temp: UnsafeRawPointer
			temp = UnsafeRawPointer.init(key)
			AssociatedKeyValue[key] = temp
			return temp
		}()
		return value as! UnsafeRawPointer
	}
}

public protocol AssociatedAble {
	
}

public extension HTBox where Base: AssociatedAble {
	
	private func point(forKey key: String) -> UnsafeRawPointer {
		let dictionaryKey = "\(self)" + key
		let dictionaryValue = AssociatedManager.point(forKey: dictionaryKey)
		return dictionaryValue
	}
	
	func setValue(value: Any?, forKey key: String) {
		let point = self.point(forKey: key)
		objc_setAssociatedObject(base, point, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
	
	func valueFor(key: String) -> Any? {
		let point = self.point(forKey: key)
		return objc_getAssociatedObject(base, point)
	}
	
}
