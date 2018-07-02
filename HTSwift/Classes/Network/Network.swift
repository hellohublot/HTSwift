

import Foundation

public typealias ProgressHandler = (_ progress: Double, _ completeMegaByte: Double, _ totalMegaByte: Double) -> Void

public typealias ResponseHandler = (_ data: Data?, _ error: Error?) -> Void

public typealias ResultHandler = (_ result: Result) -> Void

public enum HTResultError: Error {
	case unknown
	var localizedDescription: String {
		return "未知错误"
	}
}

open class Result {
	open var data: Data?
	open var value: Any?
	open var error: Error = HTResultError.unknown
	public init(_ data: Data?, _ value: Any?, _ error: Error? = HTResultError.unknown) {
		self.data = data
		self.value = value
		let reerror = error ?? HTResultError.unknown
		self.error = reerror
	}
}

public protocol TaskProvider: class {
	weak var task: URLSessionTask? { get set }
	weak var session: URLSession? { get set }
	func createTask(_ request: URLRequest, _ progress: ProgressHandler?, _ response: @escaping ResponseHandler)
}

public extension TaskProvider {
	func resume(_ session: Session) {
		task?.resume()
		session.stater?.beresume(session)
	}
	func suspend(_ session: Session) {
		task?.cancel()
		session.stater?.besuspend(session)
	}
	func cancel(_ session: Session) {
		task?.cancel()
		session.stater?.becomplete(session, nil)
	}
}

public protocol CacheProvider: class {
	typealias CacheResult = ((_ data: Data) -> Void)
	func setCacheNetwork(_ session: Session, _ response: Data?)
	func cacheNetwork(_ session: Session, _ resultQueue: DispatchQueue, _ result: @escaping CacheResult)
}

public protocol ParseProvider: class {
	func parse(_ session: Session, _ data: Data?, _ error: Error?) -> Result
}

public protocol StateProvider: class {
	func beresume(_ session: Session)
	func besuspend(_ session: Session)
	func becomplete(_ session: Session, _ result: Result?)
}

public protocol Session: class {
	var connector: TaskProvider? { get set }
	var parser: ParseProvider? { get set }
	var cacher: CacheProvider? { get set }
	var stater: StateProvider? { get set }
}

public extension Session {
	
	func handler(_ request: URLRequest, _ progress: ProgressHandler? = nil, _ responseQueue: DispatchQueue = DispatchQueue.main, _ response: @escaping ResultHandler) {
		
		let reresponse: ResponseHandler = { (data, error) in
			
			var reresult = self.parser?.parse(self, data, error) ?? Result.init(data, data)
			
			let completeHandler: ResultHandler = { reresult in
				
				responseQueue.async {
					
					self.stater?.becomplete(self, reresult)
					
					response(reresult)
					
				}
				
			}
			
			if error == nil {
				self.cacher?.setCacheNetwork(self, data)
				completeHandler(reresult)
			} else if let cacher = self.cacher {
				cacher.cacheNetwork(self, DispatchQueue.global(), { (data) in
					reresult = self.parser?.parse(self, data, nil) ?? Result.init(data, data)
					completeHandler(reresult)
				})
			} else {
				completeHandler(reresult)
			}
			
		}
		
		connector?.createTask(request, progress, reresponse)
		
		connector?.resume(self)
		
	}
	
}

