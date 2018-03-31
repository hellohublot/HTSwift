

import Foundation

public typealias ProgressHandler = (_ progress: Double, _ completeMegaByte: Double, _ totalMegaByte: Double) -> Void

public typealias ResponseHandler = (_ response: Result) -> Void


public enum Result {
	case success(_: Data)
	case failure(_: Error?)
	public static let unknow = Result.failure(nil)
}

public protocol TaskProvider {
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
		session.stater?.becomplete(session)
	}
}

public protocol CacheProvider: class {
	typealias CacheResult = ((_ data: Data) -> Void)
	func setCacheNetwork(_ session: Session, _ response: Data?)
	func cacheNetwork(_ session: Session, _ resultQueue: DispatchQueue, _ result: @escaping CacheResult)
}

public protocol ValidateProvider: class {
	func result(_ session: Session, _ response: Result?) -> Result
}

public protocol StateProvider: class {
	func beresume(_ session: Session)
	func besuspend(_ session: Session)
	func becomplete(_ session: Session)
}

public protocol MonitorProvider: class {
	func monitor(_ session: Session, _ request: URLRequest, _ response: URLResponse?)
}


public protocol Session: class {
	var connector: TaskProvider? { get set }
	var validator: ValidateProvider? { get set }
	var cacher: CacheProvider? { get set }
	var stater: StateProvider? { get set }
	var monitor: MonitorProvider? { get set }
}

public extension Session {
	
	func request(_ request: URLRequest, _ progress: ProgressHandler? = nil, _ responseQueue: DispatchQueue = DispatchQueue.global(), _ response: @escaping ResponseHandler) {
		
		let reresponse: ResponseHandler = { result in
			
			DispatchQueue.global().async {
				
				var reresult = self.validator?.result(self, result) ?? Result.unknow
				
				let completeHandler: ((_: Result) -> Void) = { reresult in
					
					responseQueue.async {
						response(reresult)
					}
					
					self.stater?.becomplete(self)
					
				}
				
				switch reresult {
				case .success(let data):
					if data.count > 0 {
						self.cacher?.setCacheNetwork(self, data)
					}
					completeHandler(reresult)
				case .failure(_):
					self.cacher?.cacheNetwork(self, DispatchQueue.global(), { (data) in
						if data.count > 0 {
							reresult = Result.success(data)
						}
						completeHandler(reresult)
					})
				}
				
			}
			
		}
		
		connector?.createTask(request, progress, reresponse)
		
		connector?.resume(self)
	}
	
}

