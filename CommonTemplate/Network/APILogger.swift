//
//  APILogger.swift
//  CommonTemplate
//
//  Created by 이동희 on 2023/04/19.
//

import Foundation
import Moya

class APILogPlugIn: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        guard let resolvedRequest = request.request, let urlString = request.request?.url else { return }
        print("======\n\(getCurrentDate()) 🚀 \(resolvedRequest.httpMethod!) \(urlString) \n \(resolvedRequest.headers)\n======")
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            switch response.statusCode {
            case 200...299:
                print("\(getCurrentDate()) ✅ \(response.statusCode):", response.request?.url?.absoluteString ?? "", "")
                if response.data.count < 10000 {
                    print("✅ RESPONSE:", String(decoding: response.data, as: UTF8.self), "")
                }
            default:
                print("\(getCurrentDate()) 🛑 \(response.statusCode):", response.request?.url?.absoluteString ?? "", (try? response.mapString()) ?? "")
            }
        case let .failure(error):
            print("Fail request", error.errorDescription ?? "")
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss:SSS"
        return formatter
    }()
    
    private func getCurrentDate() -> String {
        "[\(dateFormatter.string(from: Date()))]"
    }
}
