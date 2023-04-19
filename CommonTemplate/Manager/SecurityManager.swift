//
//  SecurityManager.swift
//  CommonTemplate
//
//  Created by 이동희 on 2023/04/19.
//

import Foundation
import Alamofire

final class SecurityManager {
    private let service = "service"
    
    public static let shared = SecurityManager()
    
    private init() {}
    
    public enum Key: String {
        case access = "AccessToken"
        case refresh = "RefreshToken"
        case tokenExpiration = "TokenExpiration"
        case FCM = "FCM"
    }
    
    public func find(key: Key) -> String? {
        return self.read(service, account: key.rawValue)
    }
    
    public func addUserAuth(_ accessToken: String, _ refreshToken: String, _ expiredAt: Int64) {
        Task { @MainActor in
            add(accessToken, key: .access)
            add(refreshToken, key: .refresh)
            add(expiredAt, key: .tokenExpiration)
        }
    }
    
    private func add(_ value: String, key: Key) {
        Task { @MainActor in
            create(service, account: key.rawValue, value: value)
        }
    }
    
    private func add(_ value: Int64, key: Key) {
        Task { @MainActor in
            create(service, account: key.rawValue, value: String(value))
        }
    }
    
    private func removeAll() {
        Task { @MainActor in
            remove(key: .access)
            remove(key: .refresh)
            remove(key: .tokenExpiration)
            remove(key: .FCM)
        }
    }
    
    private func remove(key: Key) {
        Task { @MainActor in 
            delete(service, account: key.rawValue)
        }
    }
}

extension SecurityManager {
    private func create(_ service: String, account: String, value: String) {
            let keyChainQuery: NSDictionary = [
                    kSecClass : kSecClassGenericPassword,
                    kSecAttrService: service,
                    kSecAttrAccount: account,
                    kSecValueData: value.data(using: .utf8, allowLossyConversion: false)!
            ]
            
            SecItemDelete(keyChainQuery)
            
            let status: OSStatus = SecItemAdd(keyChainQuery, nil)
            assert(status == noErr, "failed to saving Token")
    }
    
    private func read(_ service: String, account: String) -> String? {
            let KeyChainQuery: NSDictionary = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecReturnData: kCFBooleanTrue,
                kSecMatchLimit: kSecMatchLimitOne
            ]
            
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(KeyChainQuery, &dataTypeRef)
            
            if(status == errSecSuccess) {
                let retrievedData = dataTypeRef as! Data
                let value = String(data: retrievedData, encoding: String.Encoding.utf8)
                return value
            } else {
                return nil
            }
    }
    
    private func delete(_ service: String, account: String) {
            let keyChainQuery: NSDictionary = [
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrService: service,
                    kSecAttrAccount: account
            ]
            
            SecItemDelete(keyChainQuery)
    }
}
