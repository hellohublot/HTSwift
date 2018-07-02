

import Foundation

struct AssociatedManager {
	static var AssociatedKeyValue = [String:Any]()
	static func point(forKey key: String) -> UnsafeRawPointer {
		let value = (AssociatedKeyValue[key] as? UnsafeRawPointer) ?? {
			var temp: UnsafeRawPointer
			temp = UnsafeRawPointer.init(key)
			AssociatedKeyValue[key] = temp
			return temp
		}()
		return value
	}
}

public extension NSObject {
	
	private func point(forKey key: String) -> UnsafeRawPointer {
		let dictionaryKey = "\(self.hashValue)" + key
		let dictionaryValue = AssociatedManager.point(forKey: dictionaryKey)
		return dictionaryValue
	}
	
	func setAssociatedValue(value: Any?, forKey key: String) {
		let point = self.point(forKey: key)
		objc_setAssociatedObject(self, point, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
	
	func associatedValueFor(key: String) -> Any? {
		let point = self.point(forKey: key)
		return objc_getAssociatedObject(self, point)
	}
	
}
