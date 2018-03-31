//
//  ViewExtension.swift
//  HTSwift
//
//  Created by hublot on 2017/12/23.
//

import Foundation

public extension UIView {
	
	var controller: UIViewController? {
		var responder: UIResponder? = self
		while responder is UIViewController == false {
			responder = responder?.next
		}
		return responder as? UIViewController
	}
	
}

extension UIView: UIGestureRecognizerDelegate {

	public typealias TouchInsideBlock = ((_:UIView) -> (Void))
	
	public typealias TouchReceiveBlock = ((_:UIView, _: UIView) -> (Bool))
	
	public var distanceTouchInside: TimeInterval {
		get {
			return associatedValueFor(key: #function) as? TimeInterval ?? 0.25
		}
		set {
			setAssociatedValue(value: newValue, forKey: #function)
		}
	}
	
	private var whenTouchGesture: UITapGestureRecognizer {
		get {
			let gesture = (associatedValueFor(key: #function) as? UITapGestureRecognizer) ?? {
				let gesture = UITapGestureRecognizer.init(target: self, action: #selector(touchInsideReponse(_:)))
				setAssociatedValue(value: gesture, forKey: #function)
				gesture.delegate = self
				return gesture
			}()
			return gesture
		}
	}
	
	public var whenTouchInside: TouchInsideBlock? {
		get {
			return associatedValueFor(key: #function) as? TouchInsideBlock
		}
		set {
			addGestureRecognizer(whenTouchGesture)
			setAssociatedValue(value: newValue, forKey: #function)
		}
	}
	
	public var whenTouchReceive: TouchReceiveBlock? {
		get {
			return associatedValueFor(key: #function) as? TouchReceiveBlock
		}
		set {
			setAssociatedValue(value: newValue, forKey: #function)
		}
	}
	
	@objc private func touchInsideReponse(_ gesture: UITapGestureRecognizer) {
		self.isUserInteractionEnabled = false
		whenTouchInside?(self)
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.distanceTouchInside) {
			self.isUserInteractionEnabled = true
		}
	}
	
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		if let whenTouchReceive = whenTouchReceive, let view = touch.view {
			return whenTouchReceive(self, view)
		}
		return true
	}
	
	public func whenTouchInside(_ whenTouchInside: @escaping TouchInsideBlock, _ whenTouchReceive: TouchReceiveBlock? = nil) {
		self.isUserInteractionEnabled = true
		self.whenTouchInside = whenTouchInside
		self.whenTouchReceive = whenTouchReceive
	}
	
}
