

import Foundation

extension Decodable {
	
	public static func decode(_ any: Any?) -> Self? {
		return decode(Extension.dataFromAny(any))
	}
	
	public static func decodeArray(_ any: Any?) -> [Self] {
		return decodeArray(Extension.dataFromAny(any))
	}
	
	public static func decode(_ string: String?) -> Self? {
		return decode(Extension.dataFromString(string))
	}
	
	public static func decodeArray(_ string: String?) -> [Self] {
		return decodeArray(Extension.dataFromString(string))
	}
	
	public static func decode(_ data: Data?) -> Self? {
		var object: Self?
		do {
			if let _ = data {
				object = try JSONDecoder().decode(self, from: data!)
			}
		} catch {
		}
		return object
	}
	
	public static func decodeArray(_ data: Data?) -> [Self] {
		var objectArray: [Self] = [Self]()
		do {
			if let _ = data {
				objectArray = try JSONDecoder().decode([Self].self, from: data!)
			}
		} catch {
		}
		return objectArray
	}
	
}

public class Extension {
	
	static func dataFromString(_ string: String?) -> Data? {
		return string?.data(using: .utf8)
	}
	
	static func dataFromAny(_ any: Any?) -> Data? {
		var data: Data?
		do {
			if let _ = any {
				data = try JSONSerialization.data(withJSONObject: any!)
			}
		} catch {
		}
		return data
	}
	
	static func dictionary(_ any: Any) -> [String: Any]? {
		return any as? [String: Any]
	}
	
}

extension Dictionary where Key == String, Value == Any {
	
	public func object(_ key: String) -> Any? {
		let object = self[key]
		return object
	}
	
	public func dictionary(_ key: String) -> [String: Any]? {
		let dictionary = self[key] as? [String: Any]
		return dictionary
	}
	
}



