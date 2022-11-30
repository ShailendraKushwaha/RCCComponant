//
//  AppNetworking.swift
import Foundation
import Combine

class AppNetworking {
    
    static let shared = AppNetworking()
    
    private init() {
        
    }
    
    public var authenticationToken: String?
    public var customJsonDecoder: JSONDecoder?
    private var cancellables = Set<AnyCancellable>()
    
    public func request<T: Decodable>(request: AppNetworkingRequest, resultType: T.Type,doNotIncludeAuth:Bool = false) -> Future<T?,NetworkError> {
        
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
        urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.httpMethod = method.rawValue
        
        if authenticationToken != nil {
            urlRequest.setValue(authenticationToken!, forHTTPHeaderField: "authorization")
        }
        
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
    private func decodeJsonResponse<T: Decodable>(data: Data, responseType: T.Type , code: Int = 200) -> (res: T?, jsonDict: JSONDict?) {
        let decoder = createJsonDecoder()
        do {
            if let jsonDataDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSONDict {
                do {
                    printDebug("=========== JSON Response ========= ")
                    printDebug(jsonDataDict)
                    //let code = jsonDataDict[ApiKey.statusCode] as? Int ?? ApiCode.unAuthorized
                    switch code {
                    case ApiCode.success, ApiCode.created, ApiCode.updated, ApiCode.noContent:
                        guard let objectData = try? JSONSerialization.data(withJSONObject: jsonDataDict, options: []) else {
                            return (nil, nil)
                            
                        }
                            let responseObject = try decoder.decode(responseType, from: objectData)
                            printDebug("response object => \(responseObject)")
                            return (responseObject, nil)
                    default:
                        printDebug(jsonDataDict[ApiKey.message] as? String ?? "")
                        return (nil, jsonDataDict)
                    }
                } catch DecodingError.keyNotFound(let key, let context) {
                    Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                } catch DecodingError.valueNotFound(let type, let context) {
              
                    Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                } catch DecodingError.typeMismatch(let type, let context) {
    
                    Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                } catch DecodingError.dataCorrupted(let context) {
                
                    Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                } catch let error as NSError {
                    NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                }
            }
        } catch DecodingError.keyNotFound(let key, let context) {
            Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(let context) {
            Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
        } catch let error as NSError {
            NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
        }
        return (nil, nil)
    }
    
    private func performOperationWithCombine<T: Decodable>(requestUrl: URLRequest, responseType: T.Type) -> Future<T?, NetworkError> {

        return Future<T?,NetworkError> {[weak self] promise in

            guard let `self` = self else {return}

            var request = requestUrl
            //MARK: TODO for App User Defaults
            // TODO: Do adding Tokens here or any appropriate space like init
            // or in configure Function Just Like Firebase  do
//            if !doNotIncludeAuth{
//                if let token = AppUserDefaults.value(forKey: .accesstoken) as? String , token.isEmpty == false {
//                    request.addValue("Bearer " + token, forHTTPHeaderField: ApiKey.authorization)
//                }
//            }

//            let deviceDetails : [String:Any] = [ApiKey.deviceType: 1,
//                                                ApiKey.deviceToken: AppUserDefaults.value(forKey: .fcmToken) ?? "",
//                                                ApiKey.deviceId: DeviceDetail.deviceId]
            
            // TODO: Update This method also which includes Device details 
//            do{ let jsonData = try JSONSerialization.data(withJSONObject: deviceDetails, options: [])
//                let deviceDetailsInString = String(data: jsonData, encoding: .utf8)
//                request.addValue( deviceDetailsInString ?? "", forHTTPHeaderField: ApiKey.devicedetails )
//            }catch {
//                printDebug("Device details to bce sent in request headers could not be serialized.")
//            }
            URLSession.shared.dataTaskPublisher(for: request)
                .sink(receiveCompletion: { completion in
                    //                    CommonFunctions.hideActivityLoader()
                    if case .failure(let error) = completion {
                        print("Failed with error \(error)")
                        let networkError = NetworkError(withServerResponse: nil, forRequestUrl: request.url!, withHttpBody: request.httpBody, errorMessage: error.localizedDescription, forStatusCode: 1)
                        promise(.failure(networkError))
                    }
                }, receiveValue: { data, response in
                    //CommonFunctions.hideActivityLoader()
                    print(String(data: data, encoding: .utf8) ?? "nil found")
                    print("Data retrieved with size \(data.count), response = \(response)")
                    var statusCode = 200
                    if let htmlResponse = response as? HTTPURLResponse {
                        statusCode =  htmlResponse.statusCode
                    }
                    let responseData = self.decodeJsonResponse(data: data, responseType: responseType ,code: statusCode).res
                    let jsonDict = self.decodeJsonResponse(data: data, responseType: responseType).jsonDict
                    print(responseData ?? "nil found")
                    print(jsonDict ?? "nil found")
                    if let jsonDict = jsonDict {
                        if let success = jsonDict[ApiKey.success] as? Bool {
                            if success == false {
                                let networkError = NetworkError(withServerResponse: nil, forRequestUrl: request.url!, withHttpBody: request.httpBody, errorMessage: jsonDict[ApiKey.message] as! String, forStatusCode: 1)
                                promise(.failure(networkError))
                            }
                        }
                    } else {
                        promise(.success(responseData))
                    }
                }).store(in: &self.cancellables)
        }
    }
}


