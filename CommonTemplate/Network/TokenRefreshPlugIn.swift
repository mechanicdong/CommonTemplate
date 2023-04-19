//
//  TokenRefreshPlugIn.swift
//  CommonTemplate
//
//  Created by 이동희 on 2023/04/19.
//

import Foundation
import Moya


final class TokenRefreshPlugIn: PluginType {
//    var authRepository: AuthRepository = .init()
    
    func willSend(_ request: RequestType, target: TargetType) {
        guard let expiredAt = SecurityManager.shared.find(key: .tokenExpiration) else { return }
        
        // 만료 시간에 따라 달라지는 계산식
        let leftMinutes = (Int64(expiredAt)! - (Date().timeStampMilli - 10000)) / 60000
        
        if leftMinutes < 6 { // 만료시간 = 5분
            guard let refreshToken = SecurityManager.shared.find(key: .refresh) else { return }
            
            
            let semaphore = DispatchSemaphore(value: 0)
            
            //엑코 업뎃합시다. 동희야.
            _Concurrency.Task {
//                guard let result = try? await authRepo.refreshToken(refreshToken) else { return }
//                SecurityManager.shared.addUserAuth(result.accessToken, result.refreshToken, result.tokenExpiration)
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
}

public extension Date {
    var timeStampMilli: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}
