

import Foundation

public typealias ProgressHandler = (_ progress: Double, _ completeMegaByte: Double, _ totalMegaByte: Double) -> Void

public typealias ResponseHandler = (_ data: Data?, _ error: Error?) -> Void

public typealias ResultHandler = (_ result: Result) -> Void


public enum Result {
	case success(_: Data, _: Any)
	case failure(_: Error?)
	public static let unknow = Result.failure(nil)
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
			
			let suredata = data ?? Data()
			
			var reresult = self.parser?.parse(self, data, error) ?? Result.success(suredata, suredata)
			
			let completeHandler: ResultHandler = { reresult in
				
				responseQueue.async {
					response(reresult)
				}
				
				self.stater?.becomplete(self, reresult)
				
			}
			
			switch reresult {
			case .success(let (data, _)):
				if data.count > 0 {
					self.cacher?.setCacheNetwork(self, data)
				}
				completeHandler(reresult)
			case .failure(_):
				self.cacher?.cacheNetwork(self, DispatchQueue.global(), { (data) in
					if data.count > 0 {
						reresult = self.parser?.parse(self, data, nil) ?? Result.failure(error)
					}
					completeHandler(reresult)
				})
			}
			
		}
		
		connector?.createTask(request, progress, reresponse)
		
		connector?.resume(self)
		
//		print("😆" + (connector?.task?.originalRequest?.url?.absoluteString ?? ""))
//		print("🤗" + (request.url?.absoluteString ?? ""))
		
	}
	
}

