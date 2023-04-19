//
//  BaseRepository.swift
//  CommonTemplate
//
//  Created by 이동희 on 2023/04/19.
//

import Foundation
import Moya
import Alamofire

protocol BaseRepository {
    associatedtype APIProvider: TargetType
    var provider: MoyaProvider<APIProvider> { get }
}

class Plugins {
    static let loggerPlugIn = APILogPlugIn()
    // Token Refresh 추가할거면 하고
    
}

class Providers<T: TargetType> {
    static func get(autoRefresh: Bool = true) -> MoyaProvider<T> {
        let plugins: [PluginType]
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let redirector = Redirector(behavior: .doNotFollow)
        let session = Session(configuration: configuration, redirectHandler: redirector)
        
        #if Release
        if autoRefresh {
            plugins = [] // token refresh
        } else {
            plugins = []
        }
        
        #else
        if autoRefresh {
            plugins = [Plugins.loggerPlugIn] // + token refresh
        } else {
            plugins = [Plugins.loggerPlugIn]
        }
        
        #endif
        
        return MoyaProvider<T>(
            callbackQueue: .global(qos: .default),
            session: session,
            plugins: plugins
        )
    }
}
