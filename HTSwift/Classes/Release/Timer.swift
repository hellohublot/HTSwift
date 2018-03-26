//
//  Timer.swift
//  HTSwift
//
//  Created by hublot on 2018/3/1.
//

extension Timer {
	
	public typealias TimerBlock<T> = (_: T, _: Timer) -> Void
	
	open class func timer<T: AnyObject>(timeInterval ti: TimeInterval, master aMaster: T, timerPoint: UnsafeMutablePointer<Timer?>, repeats yesOrNo: Bool, usingBlock block: @escaping TimerBlock<T>) {
		weak var weakMaster = aMaster
		let seconds = fmax(ti, 0.0001)
		let interval = yesOrNo ? seconds : 0
		let fireDate = CFAbsoluteTimeGetCurrent() + seconds
		let handler: (CFRunLoopTimer?) -> Void = {cftimer in
			if let timer = cftimer as Timer? {
				if let strongmaster = weakMaster {
					block(strongmaster, timer)
				} else {
					timer.invalidate()
				}
				if yesOrNo == false {
					timer.invalidate()
				}
			}
		}
		if let cftimer = CFRunLoopTimerCreateWithHandler(nil, fireDate, interval, 0, 0, handler),
			let timer = cftimer as Timer? {
			timerPoint.pointee?.invalidate()
			timerPoint.pointee = timer
		}
	}
	
	open class func scheduled<T: AnyObject>(timeInterval ti: TimeInterval, master aMaster: T, timerPoint: UnsafeMutablePointer<Timer?>, repeats yesOrNo: Bool, usingBlock block: @escaping TimerBlock<T>) {
		self.timer(timeInterval: ti, master: aMaster, timerPoint: timerPoint, repeats: yesOrNo, usingBlock: block)
		if let timer = timerPoint.pointee {
			CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, .defaultMode)
		}
	}
	
}
