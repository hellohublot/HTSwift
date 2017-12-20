

import Foundation

public enum Method {
	case get
	case post
	case download
	case upload
	case put
	case patch
}

public typealias OutputProgress = (_ progress: Double, _ completeMegaByte: Double, _ totalMegaByte: Double) -> Void

public typealias Response = (_ response: Result<Any>) -> Void

public protocol Task {
	
	func resume()
	
	func suspend()
	
	func cancel()
	
}

public protocol NetworkProvider {
	static func request(_ model: Network) -> Task
	static func download(_ model: Network) -> Task
	static func upload(_ model: Network) -> Task
}

public protocol CacheProvider {
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

public protocol ValidateProvider {
	static func result(_ response: Any?) -> Result<Any>
}

public class Network {
	
	public let method: Method
	public let url: String
	public let readResponse: Response
	public let parameters: [String: Any]
	
	public var parametersEncoding: Any?
	
	public var headers: [String: String]?
	
	public var progress: OutputProgress?
	
	public var dataResponse: Response?
	public var destination: URL?
	
	public var uploadData: Data?
	public var uploadFormArray: [URL]?
	
	public init(url: String, method: Method = .get, parameter: [String: Any] = [:], validateProvider: ValidateProvider.Type, complete: @escaping Response = {response in}) {
		self.url = url
		self.method = method
		self.parameters = parameter
		self.readResponse = complete
		self.validateProvider = validateProvider
	}
	
	public var task: Task?
	public var validateProvider: ValidateProvider.Type
	public var networkProvider: NetworkProvider.Type?
	public var cacheProvider: CacheProvider.Type?
	
	public func request() {
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
	
	public func cacheResult(_ inResult: Result<Any>) -> Result<Any> {
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
