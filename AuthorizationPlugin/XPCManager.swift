//
//  XPCManager.swift
//  LoginSandbox
//
//  Created by Blair Mitchelmore on 2023-11-14.
//

import Foundation

enum XPCError: Error {
    case cannotBuildRemoteObjectProxy
    case xpcInterrupted
    case xpcInvalidated
}

class WorkItemRef {
    var workItem: DispatchWorkItem
    
    init(workItem: DispatchWorkItem) {
        self.workItem = workItem
    }
}

class OneshotCallback<T, E: Error> {
    var complete: AtomicBoolean = false
    var callback: (Result<T, E>) -> Void
    
    init(callback: @escaping (Result<T, E>) -> Void) {
        self.callback = callback
    }
    
    func finish(_ result: Result<T, E>) {
        guard complete.compareAndSwap(false, to: true) else {
            return
        }
        callback(result)
    }
}

class XPCManager {
    private let connection: NSXPCConnection
    
    init() {
        connection = NSXPCConnection(machServiceName: "ca.burea.labs.login-sandbox.prelogin-agent")
    }
    
    func connect() async throws -> XPCInterfaceProtocol {
        let callback: OneshotCallback<XPCInterfaceProtocol, Error> = OneshotCallback { _ in }
        let workItem = WorkItemRef(workItem: DispatchWorkItem(block: {
            
        }))
        
        log("Connecting to ca.burea.labs.login-sandbox.prelogin-agent")
        
        connection.remoteObjectInterface = NSXPCInterface(with: XPCInterfaceProtocol.self)
        connection.interruptionHandler = {
            log("xpc interrupted")
            callback.finish(.failure(XPCError.xpcInterrupted))
        }
        connection.invalidationHandler = {
            log("xpc invalidated")
            callback.finish(.failure(XPCError.xpcInvalidated))
        }
        connection.activate()
        
        return try await withCheckedThrowingContinuation { cont in
            
            callback.callback = {
                log("Callback triggered: \($0)")
                cont.resume(with: $0)
                workItem.workItem.cancel()
            }
            let object = connection.remoteObjectProxyWithErrorHandler { error in
                log("Error result: \(error)")
                callback.finish(.failure(error))
            }
            workItem.workItem = DispatchWorkItem(block: {
                guard let object = object as? XPCInterfaceProtocol else {
                    log("throwing fallback error")
                    callback.finish(.failure(XPCError.cannotBuildRemoteObjectProxy))
                    return
                }
                log("returning object")
                callback.finish(.success(object))
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem.workItem)
        }
    }
}

@objc(XPCInterfaceProtocol)
protocol XPCInterfaceProtocol {
    func checkBluetooth() async -> Bool
}
