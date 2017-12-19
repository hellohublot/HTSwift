

import Foundation

enum Method {
	case get
	case post
	case download
	case upload
	case put
	case patch
}

public typealias OutputProgress = (_ progress: Double, _ completeMegaByte: Double, _ totalMegaByte: Double) -> Void

public typealias Response = (_ response: Result<Any>) -> Void

protocol Task {
	
	func resume()
	
	func suspend()
	
	func cancel()
	
}

protocol NetworkProvider {
	static func request(_ model: Network) -> Task
	static func download(_ model: Network) -> Task
	static func upload(_ model: Network) -> Task
}

protocol CacheProvider {
	static func setCacheNetwork(_ url: String, _ parameter: [String: Any], _ response: Any?)
	static func cacheNetwork(_ url: String, _ parameter: [String: Any]) -> Any?
}

public enum Result<Value> {
	case success(Value)
	case failure(Error)
	var isSuccess: Bool {
		switch self {
		case .success:
			return true
		case .failure:
			return false
		}
	}
	var value: Value? {
		switch self {
		case .success(let value):
			return value
		case .failure:
			return nil
		}
	}
	var error: Error? {
		switch self {
		case .success:
			return nil
		case .failure(let error):
			return error
		}
	}
}

protocol ValidateProvider {
	static func result(_ response: Any?) -> Result<Any>
}

class Network {
	
	let method: Method
	let url: String
	let readResponse: Response
	let parameters: [String: Any]
	
	var parametersEncoding: Any?
	
	var headers: [String: String]?
	
	var progress: OutputProgress?
	
	var dataResponse: Response?
	var destination: URL?
	
	var uploadData: Data?
	var uploadFormArray: [URL]?
	
	init(url: String, method: Method = .get, parameter: [String: Any] = [:], validateProvider: ValidateProvider.Type, complete: @escaping Response = {response in}) {
		self.url = url
		self.method = method
		self.parameters = parameter
		self.readResponse = complete
		self.validateProvider = validateProvider
	}
	
	var task: Task?
	var validateProvider: ValidateProvider.Type
	var networkProvider: NetworkProvider.Type?
	var cacheProvider: CacheProvider.Type?
	
	func request() {
		var task: Task?
		switch method {
		case .upload:
			task = networkProvider?.upload(self)
		case .download:
			task = networkProvider?.download(self)
		default:
			task = networkProvider?.request(self)
		}
		self.task = task
	}
	
	func cacheResult(_ inResult: Result<Any>) -> Result<Any> {
		var read: Any?
		switch inResult {
		case .failure:
			read = cacheProvider?.cacheNetwork(url, parameters)
		case .success(let value):
			read = value
			cacheProvider?.setCacheNetwork(url, parameters, value)
		}
		let outResult = validateProvider.result(read)
		return outResult
	}
	
}
