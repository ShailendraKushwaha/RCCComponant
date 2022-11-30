//
//  AppNetworkingRequest.swift
 
import Foundation

public enum AppNetworkingHttpMethods: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

typealias JSONDict = [String: Any]

func printDebug<T>(_ obj : T) {
    #if DEBUG
    print(obj)
    #endif
}

protocol Request {
    var url: URL { get set }
    var method: AppNetworkingHttpMethods {get set}
}

public struct AppNetworkingRequest: Request {
    var url: URL
    var method: AppNetworkingHttpMethods
    var requestBody: Data?

    init(withUrl url: URL, forHttpMethod method: AppNetworkingHttpMethods, requestBody: Data? = nil) {
        self.url = url
        self.method = method
        self.requestBody = requestBody
    }
}

public struct MultiPartRequest : Request {
    var url: URL
    var method: AppNetworkingHttpMethods
    var request : Encodable
    var media: [MediaRequest]?
}

public struct MediaRequest {
    let fileName: String // the name of the file that you want to save on the server
    let data: Data
    let mimeType: String // mime type of the file  image/jpeg or image/png etc
    let parameterName : String // api parameter name

    init(withMediaData data: Data, name: String, mimeType: RequestMimeType, parameterName: String) {
        self.data = data
        self.fileName = name
        self.mimeType = mimeType.rawValue
        self.parameterName = parameterName
    }
}

public enum RequestMimeType: String {

    // images mime type
    case gif = "image/gif"
    case jpeg = "image/jpeg"
    case pjpeg = "image/pjpeg"
    case png = "image/png"
    case svgxml = "image/svg+xml"
    case tiff = "image/tiff"
    case bmp = "image/bmp"

    // document mime type
    case csv = "text/csv"
    case wordDocument = "application/msword"
    case pdf = "application/pdf"
    case richTextFormat = "application/rtf"
    case plainText = "text/plain"
}
