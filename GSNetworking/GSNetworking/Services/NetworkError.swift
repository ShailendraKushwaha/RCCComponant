//
//  NetworkError.swift
 
import Foundation

public struct NetworkError: Error {
    let reason: String?
    let httpStatusCode: Int?
    let requestUrl: URL?
    let requestBody: String?
    let serverResponse: String?

    init(withServerResponse response: Data? = nil, forRequestUrl url: URL? = nil, withHttpBody body: Data? = nil, errorMessage message: String, forStatusCode statusCode: Int = 0) {
        self.serverResponse = response != nil ? String(data: response!, encoding: .utf8) : nil
        self.requestUrl = url
        self.requestBody = body != nil ? String(data: body!, encoding: .utf8) : nil
        self.httpStatusCode = statusCode
        self.reason = "GSNetworking Error:" + message
    }
    
}
