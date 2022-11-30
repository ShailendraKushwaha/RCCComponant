//
//  Webservices.swift
 
import Foundation
import Combine

public class WebServices {
    
    private var cancellables = Set<AnyCancellable>()
    var appNetworkObject: AppNetworking?
    
    public static var shared : WebServices {
        get{
            return self.init(AppNetworking.shared)
        }
    }
    
    private init() {
        
    }
    
    required init(_ appNetwork: AppNetworking) {
        appNetworkObject = appNetwork
    }
    
    public func commonAPICall<T: Encodable, R: Decodable> (appendedValue: String = "",
                                                    query: [String:Any] = [:],
                                                    requestBodyModel: T?,
                                                    requestType: AppNetworkingHttpMethods,
                                                    endPoint: WebServices.EndPoint,
                                                    loader: Bool = true,
                                                    resultType: R.Type,
                                                    customURL: URL? = nil) -> Future<R?,NetworkError> {
        
        guard let appNetworking = self.appNetworkObject else {
            let networkError = NetworkError(forRequestUrl: URL(string:endPoint.rawValue)!, errorMessage: "AppNetworking nil \(#function)", forStatusCode: 420)
            printDebug(networkError)
            return Future<R?,NetworkError>{promise in
                promise(.failure(networkError))
            }
        }
        let value = appendedValue.isEmpty ? "" : "/\(appendedValue)"
        var queryParam = ""
        for (index,item) in query.enumerated() {
                if index == 0 {
                    queryParam += "?\(item.key)=\(item.value)"
                } else {
                    queryParam += "&\(item.key)=\(item.value)"
                }
        }
        guard let url = URL(string: (endPoint.path + value + queryParam).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "" ) else {
            let networkError = NetworkError(forRequestUrl: URL(string:endPoint.rawValue)!, errorMessage: "Error: URL  nil \(#function)", forStatusCode: 420)
            printDebug(networkError)
            return Future<R?,NetworkError>{promise in
                promise(.failure(networkError))
            }
        }
        
        var request = AppNetworkingRequest.init(withUrl: url, forHttpMethod: requestType)
        self.printAPILogs(model: requestBodyModel, url: url)
        
        do {
            if let body = requestBodyModel {
                let data = try JSONEncoder().encode(body)
                request.requestBody = data
                self.printAPILogs(model: requestBodyModel, url: url)
            }
            
            return self.makeAPICall(appNetworking, loader: loader, request: request, resultType: resultType)
            
        } catch {
            let networkError = NetworkError(forRequestUrl: url, errorMessage: error.localizedDescription, forStatusCode: 420)
            printDebug(networkError)
            return Future<R?,NetworkError>{promise in
                promise(.failure(networkError))
            }
        }
    }
    
    private func makeAPICall<T: Decodable>(_ appNetworking: AppNetworking, loader: Bool, request: AppNetworkingRequest, resultType: T.Type,doNotIncludeAuth: Bool = false) -> Future<T?,NetworkError> {
        return AppNetworking.shared.request(request: request, resultType: T.self,doNotIncludeAuth: doNotIncludeAuth)
    }
    
    private func printAPILogs<T: Encodable>(model: T, url: URL) {
        printDebug("=======PARAMS========")
        printDebug(model)
        printDebug("\n\n")
        printDebug("=======Endpoint URL========")
        printDebug("\(url)")
    }
    
//    func multipartAPICall<T: Encodable, R: Decodable> (appendedValue: String = "",query: [String:String] = [:],requestBodyModel: T?,mediaRequest:[MediaRequest],endPoint: WebServices.EndPoint,
//                                                       loader: Bool = true,
//                                                       resultType: R.Type) -> Future<R?,NetworkError> {
//
//        let value = appendedValue.isEmpty ? "" : "/\(appendedValue)"
//        var queryParam = ""
//        if let query = query.first {
//            queryParam = "?\(query.key)=\(query.value)"
//        }
//        guard let url = URL(string: (endPoint.path + value + queryParam).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "" ) else {
//            let networkError = NetworkError(forRequestUrl: URL(string:endPoint.rawValue)!, errorMessage: "Error: URL  nil \(#function)", forStatusCode: 420)
//            printDebug(networkError)
//            return Future<R?,NetworkError>{promise in
//                promise(.failure(networkError))
//            }
//        }
//
//        let multipartRequest = MultiPartRequest(url: url, method:.post, request: requestBodyModel, media: mediaRequest)
//
//        self.printAPILogs(model: requestBodyModel, url: url)
//        return AppNetworking.shared.requestWithMultiPartFormData(multiPartRequest: multipartRequest, responseType: R.self)
//
//    }
}
