//
//  Observer.swift
//  HTSwift
//
//  Created by hublot on 2018/3/2.
//

import UIKit

public typealias ObserverBlock<T> = (_: T, _: Selector) -> Void

class _Observer<T: NSObject>: NSObject {
	
	weak var beObserver: T?
	
	let observerKey: Selector
	
	let observerBlock: ObserverBlock<T>
	
	init(beObserver: T, observerKey: Selector, options: NSKeyValueObservingOptions, observerBlock: @escaping ObserverBlock<T>) {
		self.beObserver = beObserver
		self.observerKey = observerKey
		self.observerBlock = observerBlock
		super.init()
		beObserver.addObserver(self, forKeyPath: NSStringFromSelector(observerKey), options: options, context: nil)
	}
	
	deinit {
        beObserver?.removeObserver(self, forKeyPath: NSStringFromSelector(observerKey), context: nil)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if let beObserver = beObserver {
			observerBlock(beObserver, observerKey)
		}
	}
	
}

open class Observer {
	
	open static func add<T: NSObject>(_ beObserver: T, _ observerKey: Selector, _ options: NSKeyValueObservingOptions = .initial, _ observerBlock: @escaping ObserverBlock<T>) {
		let observer = _Observer<T>.init(beObserver: beObserver, observerKey: observerKey, options: options, observerBlock: observerBlock)
		var oldObserverList = observerList(beObserver)
		oldObserverList.append(observer)
		setObserverList(beObserver, oldObserverList)
	}
	
	open static func add<T: NSObject>(_ beObserver: T, _ observerKeyList: [Selector], _ options: NSKeyValueObservingOptions = .initial, _ observerBlock: @escaping ObserverBlock<T>) {
		for observerKey in observerKeyList {
			add(beObserver, observerKey, options, observerBlock)
		}
	}
	
	open static func remove<T: NSObject>(_ beObserver: T, _ observerKey: Selector) {
		var newObserverList = [_Observer<T>]()
		for observer in observerList(beObserver) {
			if observer.observerKey != observerKey {
				newObserverList.append(observer)
            }
		}
		setObserverList(beObserver, newObserverList)
	}
	
	open static func removeAll<T: NSObject>(_ beObserver: T) {
		setObserverList(beObserver, [])
	}
	
	static func observerList<T: NSObject>(_ beobserver: T) -> [_Observer<T>] {
		return beobserver.associatedValueFor(key: #function) as? [_Observer] ?? [_Observer]()
	}
	
	static func setObserverList<T>(_ beobserver: T, _ observerList: [_Observer<T>]) {
		beobserver.setAssociatedValue(value: observerList, forKey: #function)
	}
	
}

