//
//  AuthPlugin.swift
//  LoginSandbox
//
//  Created by Blair Mitchelmore on 2023-11-12.
//

import Foundation
import Security.Authorization
import Security.AuthorizationPlugin

enum OSStatusError: Error {
    case status(OSStatus)
}

private var PluginInterface: AuthorizationPluginInterface = AuthorizationPluginInterface(
    version: UInt32(kAuthorizationPluginInterfaceVersion),
    PluginDestroy: { plugin in
        log("Grabbing plugin to destroy")
        let plugin = Unmanaged<AuthPlugin>.fromOpaque(plugin).takeRetainedValue()
        return plugin.destroy()
    },
    MechanismCreate: { plugin, engine, mechanismId, mechanismPointer in
        log("Creating mechanism")
        let plugin = Unmanaged<AuthPlugin>.fromOpaque(plugin).takeUnretainedValue()
        let result = plugin.createMechanism(with: mechanismId, for: engine)
        switch result {
        case .success(let mechanism):
            mechanismPointer.pointee = Unmanaged.passRetained(mechanism).toOpaque()
            return errSecSuccess
        case .failure(.status(let code)):
            return code
        }
    },
    MechanismInvoke: { mechanism in
        log("Grabbing mechanism to invoke")
        let mechanism = Unmanaged<Mechanism>.fromOpaque(mechanism).takeUnretainedValue()
        return mechanism.invoke()
    },
    MechanismDeactivate: { mechanism in
        log("Grabbing mechanism to deactivate")
        let mechanism = Unmanaged<Mechanism>.fromOpaque(mechanism).takeUnretainedValue()
        return mechanism.deactivate()
    },
    MechanismDestroy: { mechanism in
        log("Grabbing mechanism to destroy")
        let mechanism = Unmanaged<Mechanism>.fromOpaque(mechanism).takeUnretainedValue()
        return mechanism.destroy()
    }
)

@objc
class AuthPluginFactory: NSObject {
    @objc
    class func pluginFromCallbacks(
        _ callbacks: UnsafePointer<AuthorizationCallbacks>,
        plugin: UnsafeMutablePointer<AuthorizationPluginRef>,
        pluginInterface: UnsafeMutablePointer<UnsafePointer<AuthorizationPluginInterface>?>
    ) -> OSStatus {
        log("Creating Auth Plugin")
        let authPlugin = AuthPlugin(callbacks: callbacks)
        plugin.pointee = Unmanaged.passRetained(authPlugin).toOpaque()
        pluginInterface.pointee = UnsafePointer(&PluginInterface)
        return errSecSuccess
    }
}

class AuthPlugin: NSObject {
    let callbacks: UnsafePointer<AuthorizationCallbacks>
    
    init(callbacks: UnsafePointer<AuthorizationCallbacks>) {
        self.callbacks = callbacks
    }
        
    func destroy() -> OSStatus {
        return errSecSuccess
    }
    
    func createMechanism(with mechanismId: AuthorizationMechanismId, for engine: AuthorizationEngineRef) -> Result<Mechanism, OSStatusError> {
        let mechanismId = String(cString: mechanismId)
        log("Creating Mechanism with id: \(mechanismId)")
        switch mechanismId {
        case "Privileged":
            return .success(PrivMech(plugin: self, engine: engine))
        case "Unprivileged":
            return .success(UnprivMech(plugin: self, engine: engine))
        case "Authenticate":
            return .success(AuthenticateMech(plugin: self, engine: engine))
        default:
            return .failure(.status(errSecParam))
        }
    }
}

class Mechanism: NSObject {
    private weak var plugin: AuthPlugin?
    private let engine: AuthorizationEngineRef
    
    init(plugin: AuthPlugin, engine: AuthorizationEngineRef) {
        log("Creating Mechanism: \(Self.self)")
        self.plugin = plugin
        self.engine = engine
    }
    
    func allowLogin() {
        log("Allowing login")
        _ = plugin?.callbacks.pointee.SetResult(self.engine, .allow)
    }
    
    func invoke() -> OSStatus {
        return errSecSuccess
    }
    
    func deactivate() -> OSStatus {
        return errSecSuccess
    }
    
    func destroy() -> OSStatus {
        return errSecSuccess
    }
}
