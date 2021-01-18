//
//  KeychainAuthenticationWrapper.swift
//  GFSwiftUtilities
//
//  Created by Gualtiero Frigerio on 18/01/2021.
//

import Foundation
import LocalAuthentication

/// Wrapper around Keychain with support for biometric authentication
/// The wrapper writes value as kSecClassGenericPassword
/// so getValue and setValue work like a dictionary with a key/value approach.
/// When reading or writing a value biometric authentication can be requested
/// so the operation is perfomed only after a successful attempt to authenticate
class KeychainAuthenticationWrapper {
    /// Reads a generic password from the keychain associated
    /// with the account specified by the key parameter
    /// It is possible to require biometric authentication so the keychain
    /// is accessed only after a successful authentication
    /// - Parameters:
    ///   - key: The key to get from the keychain
    ///   - requireAuthentication: true if biometric authentication is required
    ///   - authenticationReason: The  reason to specify when asking for biometric authentication
    ///   - completion: Completion handler with a Bool parameter for success and the optional string retrieved
    func getValue(forKey key:String,
                  requireAuthentication:Bool,
                  authenticationReason:String?,
                  completion: @escaping (Bool, String?) -> Void) {
        if requireAuthentication {
            performAuthentication(withReason: authenticationReason) { success in
                if success {
                    self.getValue(forKey: key, completion: completion)
                }
            }
        }
        getValue(forKey: key, completion: completion)
    }
    
    /// Writes a generic password to the keychain
    /// - Parameters:
    ///   - value: the string to write
    ///   - key: the key representing the value to write
    ///   - requireAuthentication: true if biometric authentication is required
    ///   - authenticationReason: The  reason to specify when asking for biometric authentication
    ///   - completion: Completion handler with a Bool parameter for success
    func setValue(_ value:String,
                  forKey key:String,
                  requireAuthentication:Bool,
                  authenticationReason:String?,
                  completion: @escaping (Bool) -> Void) {
        if requireAuthentication {
            performAuthentication(withReason: authenticationReason) { success in
                if success {
                    self.setValue(value, forKey: key, completion: completion)
                }
            }
        }
        setValue(value, forKey: key, completion: completion)
    }
    
    //MARK: - Private
    
    private var context = LAContext()
    
    // MARK: - Biometric authentication
    
    private func authenticateUser(withReason reason:String, completion: @escaping (Bool) -> Void) {
        var error:NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                if success {
                    completion(true)
                }
                else {
                    print(error?.localizedDescription ?? "Failed to authenticate")
                    completion(false)
                }
            }
        }
        else {
            print(error?.localizedDescription ?? "Can't evaluate policy")
            completion(false)
        }
    }
    
    private func performAuthentication(withReason reason:String?, completion: @escaping (Bool) -> Void) {
        guard let reason = reason else {
            print("you need to give an authentication reason")
            completion(false)
            return
        }
        authenticateUser(withReason: reason) { success in
            completion(success)
        }
    }
    
    // MARK: - Keychain
    
    private func getValue(forKey key:String, completion:(Bool, String?) -> Void) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess {
            if item == nil {
                completion(false,  nil)
            }
            if let itemData = item as? Data {
                completion(true, String(data: itemData, encoding: .utf8))
            }
        }
        else {
            if #available(iOS 11.3, *) {
                let errorDescription = SecCopyErrorMessageString(status,nil)
                print("SecItemCopyMatching returned \(String(describing: errorDescription))")
            }
            completion(false,  nil)
        }
    }
    
    private func setValue(_ value:String, forKey key:String, completion:(Bool) -> Void) {
        let valueData = value.data(using: .utf8)!
        let addquery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: key,
                                       kSecValueData as String: valueData]
        let status = SecItemAdd(addquery as CFDictionary, nil)
        if status == errSecSuccess {
            completion(true)
        }
        else {
            if #available(iOS 11.3, *) {
                let errorDescription = SecCopyErrorMessageString(status,nil)
                print("SecItemAdd returned \(String(describing: errorDescription))")
            }
            completion(false)
        }
    }
}
