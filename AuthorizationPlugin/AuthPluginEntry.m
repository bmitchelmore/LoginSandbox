//
//  AuthPluginEntry.m
//  LoginSandbox
//
//  Created by Blair Mitchelmore on 2023-11-12.
//

#import <Foundation/Foundation.h>
#import "LoginSandbox-Swift.h"
#import <Security/AuthorizationPlugin.h>

OSStatus AuthorizationPluginCreate(
    const AuthorizationCallbacks *callbacks,
    AuthorizationPluginRef *outPlugin,
    const AuthorizationPluginInterface **outPluginInterface
) {
    return [AuthPluginFactory 
        pluginFromCallbacks:callbacks
        plugin:outPlugin
        pluginInterface:outPluginInterface
    ];
}
