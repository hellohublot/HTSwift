

import Foundation

public enum ConnectMethod {
	case get
	case post
	case download
	case upload
	case put
	case patch
}

public typealias OutputProgressHandler = (_ progress: Double, _ completeMegaByte: Double, _ totalMegaByte: Double) -> Void

public typealias ResponseHandler = (_ response: Result<Any>) -> Void

public protocol Task {
	
	func resume()
	
	func suspend()
	
	func cancel()
	
}

public protocol ConnectProvider {
	static func request(_ model: Network) -> Task
	static func download(_ model: Network) -> Task
	static func upload(_ model: Network) -> Task
}

public protocol CacheProvider {
	func setCacheNetwork(_ url: String, _ parameter: [String: Any], _ response: Any?)
	func cacheNetwork(_ url: String, _ parameter: [String: Any]) -> Any?
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

public protocol ValidateProvider {
	func result(_ response: Any?) -> Result<Any>
}

open class Network {
	
	open let method: ConnectMethod
	open let url: String
	open let readResponse: ResponseHandler
	open let parameters: [String: Any]
	
	open var parametersEncoding: Any?
	
	open var headers: [String: String]?
	
	open var progress: OutputProgressHandler?
	
	open var dataResponse: ResponseHandler?
	open var destination: URL?
	
	open var uploadData: Data?
	open var uploadFormArray: [URL]?
	
	public init(url: String, method: ConnectMethod = .get, parameter: [String: Any] = [:], validateProvider: ValidateProvider, complete: @escaping ResponseHandler = {response in}) {
		self.url = url
		self.method = method
		self.parameters = parameter
		self.readResponse = complete
		self.validateProvider = validateProvider
	}
	
	open var task: Task?
	open var validateProvider: ValidateProvider
	open var connectProvider: ConnectProvider.Type?
	open var cacheProvider: CacheProvider?
	
	open func request() {
		var task: Task?
		switch method {
		case .upload:
			task = connectProvider?.upload(self)
		case .download:
			task = connectProvider?.download(self)
		default:
			task = connectProvider?.request(self)
		}
		self.task = task
	}
	
	open func cacheResult(_ inResult: Result<Any>) -> Result<Any> {
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
