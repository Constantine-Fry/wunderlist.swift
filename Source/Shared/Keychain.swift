//
//  Keychain.swift
//  Wunderlist
//
//  Created by Constantine Fry on 17/01/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation
import Security

/** 
    The error domain for errors returned by `Keychain Service`.
    The `code` property will contain OSStatus. See SecBase.h for error codes.
    The `userInfo` is always nil and there is no localized description provided.
*/
public let WunderlistKeychainOSSatusErrorDomain = "QuadratKeychainOSSatusErrorDomain"

class Keychain {
    
    /** Logger to log all errors. */
    var logger : Logger?
    
    /** Query to get keychain items. */
    private var keychainQuery: [String:AnyObject]
    
    init(configuration: Configuration) {
        let serviceAttribute = "net.wunderlist"
        var accountAttribute: String
        
        if let userTag = configuration.sessionTag {
            accountAttribute = configuration.client.clientId + "_" + configuration.sessionTag!
        } else {
            accountAttribute = configuration.client.clientId
        }
        
        keychainQuery = [
            kSecClass           : kSecClassGenericPassword,
            kSecAttrAccessible  : kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecAttrService     : serviceAttribute,
            kSecAttrAccount     : accountAttribute
        ]
        
        #if os(OSX)
            keychainQuery[kSecAttrIsInvisible] = true
        #endif
    }
    
    func accessToken() -> (String?, NSError?) {
        var query = keychainQuery
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitOne
        
        /** 
            Fixes the issue with Keychain access in release mode.
            https://devforums.apple.com/message/1070614#1070614
        */
        var dataTypeRef: AnyObject? = nil
        let status = withUnsafeMutablePointer(&dataTypeRef) {cfPointer -> OSStatus in
            SecItemCopyMatching(query, UnsafeMutablePointer(cfPointer))
        }
        var accessToken: String? = nil
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as NSData? {
                if retrievedData.length != 0 {
                    accessToken = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
                }
            }
        }
        let error = errorWithStatus(status)
        if status != errSecSuccess {
            if status != errSecSuccess && status != errSecItemNotFound {
                logger?.logError(error!, withMessage: "Keychain can't read access token.")
            }
        }
        return (accessToken, error)
    }
    
    func deleteAccessToken() -> (Bool, NSError?) {
        let query = keychainQuery
        let status = SecItemDelete(query)
        let error = errorWithStatus(status)
        if status != errSecSuccess {
            logger?.logError(error!, withMessage: "Keychain can't delete access token .")
        }
        return (status != errSecSuccess, error)
    }
    
    func saveAccessToken(accessToken: String) -> (Bool, NSError?) {
        var query = keychainQuery
        
        let (existingAccessToken, _ ) = self.accessToken()
        if existingAccessToken  != nil {
            deleteAccessToken()
        }
        
        let accessTokenData = accessToken.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        query[kSecValueData] =  accessTokenData
        let status = SecItemAdd(query, nil)
        let error = errorWithStatus(status)
        if status != errSecSuccess {
            logger?.logError(error!, withMessage: "Keychain can't add access token.")
        }
        return (status == errSecSuccess, error)
    }
    
    private func errorWithStatus(status: OSStatus) -> NSError? {
        var error: NSError?
        error = NSError(domain: WunderlistKeychainOSSatusErrorDomain, code: Int(status), userInfo: nil)
        return error
    }
    
    func allAllAccessTokens() -> [String] {
        return [""]
    }
}
