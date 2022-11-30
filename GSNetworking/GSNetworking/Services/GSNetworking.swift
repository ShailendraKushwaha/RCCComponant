import Foundation
import Combine

public class GSNetworking {
    
    ///baseURL - serves as basel for api end point
    private var baseURL : String? = ""
    
    public static var shared : GSNetworking = GSNetworking()
    
    private init() {
        
    }
    /// sets the base url for working with api calls and endpoints of api
    ///
    /// - parameters:
    ///   - baseURL: string baseurl to set to the variable
    public func setBaseURL(_ baseURL : String){
        self.baseURL = baseURL
    }
    
    public func setAdditionalHeaders(_ value: String,httpHeaderField:String){
        AppNetworking.shared.additionalHeaders.append((httpHeaderField,value))
    }
    
    public func setJsonHeaders(_ dictionary :[ String: Any],httpHeaderField: String){
        AppNetworking.shared.jsonHeaders = dictionary
        AppNetworking.shared.jsonHeaderKey = httpHeaderField
    }
    
    public func setAuthneticationToken(_ token: String,authType:AuthenticationType = .bearer){
        AppNetworking.shared.authenticationToken = token
        AppNetworking.shared.authnticationType = authType
    }
    
    public func commonAPICall<T: Encodable, R: Decodable> (query: [String:Any] = [:],
                                                    requestBodyModel: T?,
                                                    requestType: AppNetworkingHttpMethods,
                                                    endPoint: String,
                                                    loader: Bool = true,
                                                    resultType: R.Type,
                                                    customURL: URL? = nil) -> Future<R?,NetworkError> {
        guard let baseURL = baseURL else {
            let error = NetworkError(errorMessage: "Base URL not found. You have to set base URL manually.")
            return Future<R?,NetworkError>{promise in
                promise(.failure(error))
            }
        }
        
        let stringURL = baseURL + endPoint
        
        guard let url = URL(string: stringURL) else {
            let error = NetworkError(errorMessage: "invalid URL - \(stringURL)")
            return Future<R?,NetworkError>{promise in
                promise(.failure(error))
            }
        }
        
        var request: AppNetworkingRequest
        
        if requestType == .get {
            request = AppNetworkingRequest.init(withUrl: url, forHttpMethod: requestType)
            
            let queryItems = query.map{
                return URLQueryItem(name: "\($0)", value: "\($1)")
            }
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = queryItems
            if let urlComponents = urlComponents , let componantURL = urlComponents.url{
                request = AppNetworkingRequest.init(withUrl: componantURL, forHttpMethod: requestType)
            }
            
        }
        else  {
            request = AppNetworkingRequest.init(withUrl: url, forHttpMethod: .post)
            do {
                if let requestBody = requestBodyModel {
                    let data = try JSONEncoder().encode(requestBody)
                    request.requestBody = data
                    self.printAPILogs(model: requestBodyModel, url: url)
                } else {
                    request.requestBody = try JSONSerialization.data(withJSONObject:query, options: [])
                }
            }
            catch (let error){
                print(error)
                let error = NetworkError(errorMessage:error.localizedDescription)
                return Future<R?,NetworkError>{promise in
                    promise(.failure(error))
                }
            }
            
        }
        
        self.printAPILogs(model: requestBodyModel, url: url)
        return AppNetworking.shared.request(request: request, resultType: R.self)
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
