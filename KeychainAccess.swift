//
//  KeychainAccess.swift
//
//  Created by Prasanna Vishwas Ballal on 24/08/16.
//  Copyright © 2016 Prasanna Ballal. All rights reserved.
//

import UIKit

class KeychainAccess: NSObject {
    fileprivate static let defaultInstance = KeychainAccess()
    
    class func sharedKeychainAccess() -> KeychainAccess{
        return defaultInstance
    }
    
    func saveObject(_ object: AnyObject, forService service: String) -> Bool{
        var keychainQuery: [NSString: AnyObject] = getKeychainQuery(service)
        SecItemDelete(keychainQuery as CFDictionary)
        
        let archivedData: Data = NSKeyedArchiver.archivedData(withRootObject: object)
        keychainQuery[kSecValueData] = archivedData as AnyObject?
        var result: AnyObject?
        let status = SecItemAdd(keychainQuery as CFDictionary, &result)
        print(status)
        return (SecItemAdd(keychainQuery as CFDictionary, &result) == noErr)
    }
    
    func loadObject(forService service: String) -> AnyObject? {
        var keychainQuery: [NSString: AnyObject] = getKeychainQuery(service)
        
        keychainQuery[kSecReturnData] = kCFBooleanTrue
        keychainQuery[kSecMatchLimit] = kSecMatchLimitOne
        
        var keyData: AnyObject?
        if SecItemCopyMatching(keychainQuery as CFDictionary, &keyData) == noErr {
            if let data = keyData as? Data{
                return NSKeyedUnarchiver.unarchiveObject(with: data) as AnyObject
            }
        }
        
        return nil
    }
    
    func deleteObject(forService service: String) -> Bool {
        let keychainQuery: [NSString: AnyObject] = getKeychainQuery(service)
        return (SecItemDelete(keychainQuery as CFDictionary) == noErr)
    }
    
    fileprivate func getKeychainQuery(_ service: String) -> [NSString: AnyObject]{
        let query: [NSString: AnyObject] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service as AnyObject,
            kSecAttrAccount: service as AnyObject,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock]
        return query
    }
}
