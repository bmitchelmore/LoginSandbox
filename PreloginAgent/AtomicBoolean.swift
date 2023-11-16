//
//  AtomicBoolean.swift
//  LoginSandbox
//
//  Created by Blair Mitchelmore on 2023-11-12.
//

import Foundation

class AtomicBoolean: ExpressibleByBooleanLiteral {
    private var value: Bool
    private let semaphore: DispatchSemaphore
    
    required init(booleanLiteral: Bool) {
        value = booleanLiteral
        semaphore = DispatchSemaphore(value: 1)
    }
    
    func compareAndSwap(_ current: Bool, to updated: Bool) -> Bool {
        semaphore.wait()
        defer { semaphore.signal() }
        if value == current {
            value = updated
            return true
        } else {
            return false
        }
    }
    
    func isEqual(to current: Bool) -> Bool {
        return compareAndSwap(current, to: current)
    }
}
