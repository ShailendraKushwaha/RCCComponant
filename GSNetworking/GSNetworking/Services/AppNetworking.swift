//
//  AppNetworking.swift
import Foundation
import Combine

class AppNetworking {
    
    static let shared = AppNetworking()
    
    var authenticationToken: String?
    var authnticationType : AuthenticationType = .bearer
    
    var jsonHeaderKey: String?
    var jsonHeaders : [String:Any]?
    var additionalHeaders : [(String,String)] = []
    
    var customJsonDecoder: JSONDecoder?
    var cancellables = Set<AnyCancellable>()
    
    private init() {
        
    }
    
    func addHeader(request:URLRequest,header:HTTPHeaderKey,value:String){
        
    }
    
    public func request<T: Decodable>(request: AppNetworkingRequest, resultType: T.Type) -> Future<T?,NetworkError> {
        
        switch request.method {
        case .get:
            return getData(request: request, resultType: resultType)
        case .post:
            return postData(request: request, resultType: resultType)
        case .put:
            return putData(request: request, resultType: resultType)
        case .delete:
            return deleteData(request: request, resultType: resultType)
        case .patch:
            return patchData(request: request, resultType: resultType)
        }
        
    }
    
//    public func requestWithMultiPartFormData<T: Decodable>(multiPartRequest: MultiPartRequest, responseType: T.Type) -> Future<T?,NetworkError> {
//        return postMultiPartFormData(request: multiPartRequest)
//    }
    
    // MARK: - Private functions
    private func createJsonDecoder() -> JSONDecoder {
        let decoder =  customJsonDecoder != nil ? customJsonDecoder! : JSONDecoder()
        if customJsonDecoder == nil {
            decoder.dateDecodingStrategy = .iso8601
        }
        return decoder
    }
    
    private func createUrlRequest(requestUrl: URL,with method:AppNetworkingHttpMethods) -> URLRequest {
        
        var urlRequest = URLRequest(url: requestUrl)
        urlRequest.addValue("application/json", forHTTPHeaderField:HTTPHeaderKey.contentType.rawValue)
        urlRequest.addValue("application/json", forHTTPHeaderField:HTTPHeaderKey.accept.rawValue)
        urlRequest.httpMethod = method.rawValue
        
        if let authenticationToken = authenticationToken {
            var token : String = ""
            
            if authnticationType == .bearer {
                token = "Bearer " + authenticationToken
            }
            
            if authnticationType == .basic {
                token = authenticationToken
            }
            
            urlRequest.addValue(token, forHTTPHeaderField: HTTPHeaderKey.authorization.rawValue)
        }
        
        if let customHeaders = jsonHeaders {
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: customHeaders, options: [])
                let customStringHeader = String(data: jsonData, encoding: .utf8)
                urlRequest.addValue( customStringHeader ?? "", forHTTPHeaderField: self.jsonHeaderKey ?? "")
            }catch {
                printDebug("Custom headers sent in request could not be serialized.\(customHeaders)")
            }
        }
        
        for (key,value) in self.additionalHeaders{
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        return urlRequest
    }
    
    public func getData<T: Decodable>(request: AppNetworkingRequest, resultType: T.Type) -> Future<T?,NetworkError> {
        
        let urlRequest = self.createUrlRequest(requestUrl: request.url, with: .get)
        return self.performOperationWithCombine(requestUrl: urlRequest, responseType: T.self)
    }
    
    public func putData<T: Decodable>(request: AppNetworkingRequest, resultType: T.Type,doNotIncludeAuth:Bool = false) -> Future<T?,NetworkError> {
        
        var urlRequest = self.createUrlRequest(requestUrl: request.url, with: .put)
        urlRequest.httpBody = request.requestBody
        
        return self.performOperationWithCombine(requestUrl: urlRequest, responseType: T.self)
    }
    
    public func deleteData<T: Decodable>(request: AppNetworkingRequest, resultType: T.Type) -> Future<T?,NetworkError> {
        let urlRequest = self.createUrlRequest(requestUrl: request.url, with: .delete)
        return self.performOperationWithCombine(requestUrl: urlRequest, responseType: T.self)
    }
    
    public func patchData<T: Decodable>(request: AppNetworkingRequest, resultType: T.Type) -> Future<T?,NetworkError> {
        var urlRequest = self.createUrlRequest(requestUrl: request.url, with: .patch)
        urlRequest.httpBody = request.requestBody
        return self.performOperationWithCombine(requestUrl: urlRequest, responseType: T.self)
    }
    
    public func postData<T: Decodable>(request: AppNetworkingRequest, resultType: T.Type)-> Future<T?,NetworkError>{
        var urlRequest = self.createUrlRequest(requestUrl: request.url,with: .post)
        urlRequest.httpBody = request.requestBody
        return self.performOperationWithCombine(requestUrl: urlRequest, responseType: T.self)
    }
    
    private func performOperationWithCombine<T: Decodable>(requestUrl: URLRequest, responseType: T.Type) -> Future<T?, NetworkError> {

        return Future<T?,NetworkError> {[weak self] promise in

            guard let `self` = self else {return}

            URLSession.shared.dataTaskPublisher(for: requestUrl)
                .sink(receiveCompletion: { completion in
                    //                    CommonFunctions.hideActivityLoader()
                    if case .failure(let error) = completion {
                        print("Failed with error \(error)")
                        let networkError = NetworkError(withServerResponse: nil, forRequestUrl: requestUrl.url!, withHttpBody: requestUrl.httpBody, errorMessage: error.localizedDescription)
                        promise(.failure(networkError))
                    }
                }, receiveValue: { data, response in
                    var statusCode = 200
                    if let htmlResponse = response as? HTTPURLResponse {
                        statusCode =  htmlResponse.statusCode
                    }
                    
                    let tupleDecodedResponse = self.decodeJsonResponse(data: data, responseType: responseType,code: statusCode)
                    if let error = tupleDecodedResponse.error{
                        promise(.failure(error))
                    }
                    
                    if let responseObject = tupleDecodedResponse.response {
                        promise(.success(responseObject))
                    }
                    
                    if let jsonDictionary = tupleDecodedResponse.jsonDictionary {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
                            let customStringHeader = String(data: jsonData, encoding: .utf8)
                            let error = NetworkError(errorMessage: customStringHeader ?? "String UTF8 Encoding error")
                            promise(.failure(error))
                        } catch {
                            print(jsonDictionary)
                            promise(.failure(NetworkError(errorMessage: error.localizedDescription)))
                        }
                        
                    }
                }).store(in: &self.cancellables)
        }
    }
    
    private func decodeJsonResponse<T: Decodable>(data: Data, responseType: T.Type , code: Int = 200) -> (response: T?, jsonDictionary: [String: Any]?,error:NetworkError?) {
        let decoder = createJsonDecoder()
        do {
            if let jsonDataDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {

                    printDebug("=========== JSON Response ========= ")
                    printDebug(jsonDataDict)
                    //let code = jsonDataDict[ApiKey.statusCode] as? Int ?? ApiCode.unAuthorized
                    switch code {
                    case HTTPCode.success, HTTPCode.created, HTTPCode.updated, HTTPCode.noContent:
                        let objectData = try JSONSerialization.data(withJSONObject: jsonDataDict, options:[])
                        let responseObject = try decoder.decode(responseType, from: objectData)
                        printDebug("response object => \(responseObject)")
                        return (responseObject, nil,nil)
                    default:
                        printDebug(jsonDataDict[ApiKey.message] as? String ?? "")
                        return (nil, jsonDataDict,nil)
                    }
            }
            else {
                let error = NetworkError(errorMessage:"Dictionary Expected : API call response is not a dictionary")
                return ( nil,nil,error)
            }
        }
        catch (let error) {
            print(error)
            let error = NetworkError(errorMessage:error.localizedDescription)
            return ( nil,nil,error)
        }
    }
    
    
//    private func postMultiPartFormData<T: Decodable>(request: MultiPartRequest) -> Future<T?,NetworkError> {
//        let boundary = "Boundary-\(UUID().uuidString)"
//        let lineBreak = "\r\n"
//        var urlRequest = self.createUrlRequest(requestUrl: request.url, with: .post)
//        urlRequest.httpMethod = AppNetworkingHttpMethods.post.rawValue
//        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        var postBody = Data()
//
//        if let media = request.media {
//            media.forEach({ (media) in
//                postBody.append("--\(boundary + lineBreak)" .data(using: .utf8)!)
//                postBody.append("Content-Disposition: form-data; name=\"\(media.parameterName)\"; filename=\"\(media.fileName)\" \(lineBreak)" .data(using: .utf8)!)
//                postBody.append("Content-Type: \(media.mimeType + lineBreak + lineBreak)" .data(using: .utf8)!)
//                print(String(data: postBody, encoding: .utf8))
//                postBody.append(media.data)
//                postBody.append(lineBreak .data(using: .utf8)!)
//            })
//        }
//
//
//        if let requestParams = request.{
//
//            requestParams.forEach({ (key, value) in
//
//                let strValue = value.map { String(describing: $0) }
//                if strValue != nil && strValue?.count != 0 {
//                    postBody.append("--\(boundary + lineBreak)" .data(using: .utf8)!)
//                    postBody.append("Content-Disposition: form-data; name=\"\(key)\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
//                    postBody.append("\(strValue! + lineBreak)".data(using: .utf8)!)
//                }
//
//            })
//
//            postBody.append("--\(boundary)--\(lineBreak)" .data(using: .utf8)!)
//            urlRequest.addValue("\(postBody.count)", forHTTPHeaderField: "Content-Length")
//        }
//        urlRequest.httpBody = postBody
//        print(postBody.count)
//        print(String(data:postBody,encoding: .utf8))
//        return self.performOperationWithCombine(requestUrl: urlRequest, responseType: T.self)
//    }
//
   
    
    
}

//
//catch DecodingError.keyNotFound(let key, let context) {
//    Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
//} catch DecodingError.valueNotFound(let type, let context) {
//    Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
//} catch DecodingError.typeMismatch(let type, let context) {
//    Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
//} catch DecodingError.dataCorrupted(let context) {
//    Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
//} catch let error as NSError {
//    NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
//}

//catch DecodingError.keyNotFound(let key, let context) {
//    Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
//} catch DecodingError.valueNotFound(let type, let context) {
//
//    Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
//} catch DecodingError.typeMismatch(let type, let context) {
//
//    Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
//} catch DecodingError.dataCorrupted(let context) {
//
//    Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
//} catch let error as NSError {
//    NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
//}


