//
//  ApiKeys.swift
 
import Foundation
enum ApiKey {
    
    static var status: String { return "status" }
    static var statusCode: String { return "statusCode" }
    static var code: String { return "CODE" }
    static var result: String { return "result" }
    static var message: String { return "message" }
    static var authorization: String { return "Authorization" }
    static var contentType: String { return "Content-Type" }
    static var data: String { return "data" }
    static var accessToken: String { return "access_token"}
    static var emoji: String { return "emoji" }
    static var accept: String { return "Accept" }
    static var platform : String {return "platform"}
    static var offset : String {return "offset"}
    static var timezone : String {return "timezone"}
    static var deviceid : String {return "deviceid"}
    static var deviceId : String { return "deviceId" }
    static var devicetoken : String {return "devicetoken"}
    static var deviceToken : String {return "deviceToken"}
    static var deviceType : String {return "deviceType"}
    static var otpTimeStamp: String { return "otpTimeStamp" }
    static var abbreviation : String {return "abbreviation"}
    static var devicedetails : String        {return  "devicedetails"}
    static var Authorization : String       {return "authorization" }
    static var success: String {return "success"}
    static var failure: String {return "failure"}
    static var keyTipsData: String {return "keyTipsData"}
    static var name : String {return "name"}
    static var email : String {return "email"}
    static var password : String {return "password"}
    static var confirmPassword : String { return "confirmPassword" }
    static var countryCode : String {return "countryCode"}
    static var phoneNo : String {return "phoneNo"}
    static var image : String {return "image"}
    static var crc : String {return "crc"}
    static var isChangeNumberOtp : String {return "isChangeNumberOtp"}
    static var gender: String {return "gender"}
    static var _id : String {return "_id"}
    static var otp : String {return "otp"}
    static var device : String {return "device"}
    static var token : String {return "token"}
    static var resetToken : String {return "resetToken"}
    static var registeredBy : String  {return "registeredBy"}
    static var clinicRegCode : String  {return "clinicRegCode"}
    static var authToken : String {return "authToken"}
    static var createdAt : String {return "createdAt"}
    static var emailVerified : String {return "emailVerified"}
    static var isDelete : String {return "isDelete"}
    static var otpExpiry : String {return "otpExpiry"}
    static var phoneVerified : String {return "phoneVerified"}
    static var deviceDetails   : String  {return "deviceDetails"}
    static var socialId: String {return "socialId"}
    static var user_type: String {return "user_type"}
    static var nextHit : String {return "nextHit"}
    static var page : String {return "page"}
    static var pageNo: String {return "pageNo"}
    static var totalPage : String {return "totalPage"}
    static var limit : String {return "limit"}
    static var type : String {return "type"}
    static var extUrl : String {return "extUrl"}
    static var description : String {return "description"}
    static var icon : String { return "icon"}
    static var isActionBlocked : String { return "isActionBlocked"}
    static var isRead : String { return "isRead"}
    static var isNotificationAvailable : String { return "isNotificationAvailable"}
    
    static var notificationId : String { return "notificationId"}
    static var termsAndCondition : String {return "termsAndCondition"}
    static var notificationEnabled : String {return "notificationEnabled"}
    static var provinceAbbreviation : String {return "provinceAbbreviation"}
    static var province : String {return "province"}
    static var fullName : String {return "fullName"}
    static var firstName : String {return "firstName"}
    static var lastName : String {return "lastName"}
    static var profilePicture : String {return "profilePicture"}
    static var docStatus : String {return "docStatus"}
    static var signupSource:String {return "signupSource"}
    static var accountType : String {return "accountType"}
    static var city : String {return "city"}
    static var fullPhoneNo : String {return "fullPhoneNo"}
    static var category : String {return "category"}
    static var id: String{ return "id"}
    static var dob: String{return "dob"}
    static var year: String{ return "year"}
    static var maker: String{ return "maker"}
    static var model: String{ return "model"}
    static var colour: String{ return "colour"}

    static var startDate: String{ return "startDate"}
    static var expireDate: String{ return "expireDate"}
    static var validFrom: String{ return "validFrom"}
    static var validUpto: String{ return "validUpto"}
    static var oldPassword: String{ return "oldPassword"}
    
    static var location: String { return "location" }
    static var latitude : String {return "latitude"}
    static var longitude : String {return "longitude"}
    static var coordinates: String { return "coordinates" }
    static var completeAddress: String { return "completeAddress" }
    static var state: String { return "state" }
    static var pinCode: String { return "pinCode" }
    static var currentLocation: String { return "currentLocation" }
    static var availabilityStatus: String { return "availabilityStatus" }
    static var suspendedStatus: String { return "suspendedStatus" }

    //Default
    static var Success : String {return "Success"}
    static var failed : String {return "failed"}

    //privee

    static var sessionId: String { return "sessionId" }
    static var httpCode : String {return "httpCode"}
    static var feedSortBy : String {return "feedSortBy"}
    static var communitySortBy : String {return "communitySortBy"}
    static var comingFromFeed : String {return "comingFromFeed"}
    static var index: String { return "index" }
    static var userName: String { return "userName" }

    static var turnOffComment : String {return "turnOffComment"}
    static var phone : String {return "phone"}
    
    static var apikey: String { return "api_key"}
    static var catname: String { return "catname" }
    static var formType: String { return "formType"}
    static var lmsType: String { return "lmsType"}
}

// MARK: - RequestType Enum
//==========================
enum RequestType {
    static var CONSULTATION : String {return "CONSULTATION"}
    static var EXTRA_SUPPORT : String {return "EXTRA_SUPPORT"}
}


// MARK: - Api Code
//=======================
enum HTTPCode {
    static var success              : Int { return 200 }
    static var sessionExpired       : Int { return 440 }
    static var session_Expired      : Int { return 408}
    static var invalidSession       : Int { return 498 }
    static var blockedByAdmin       : Int { return 403 } // User blocked by admin
    static var propertyDoesNotExist : Int { return 404 } // Property deleted by admin
    static var pleaseTryAgain       : Int { return 500 }
    static var tokenExpired         : Int { return 408 } // Token expired refresh token needed to be generated
    static var emailNotVerified     : Int { return 202 }
    static var created: Int { return 201 }
    static var updated: Int { return 202 }
    static var noContent: Int { return 204 }
    static var badRequest: Int { return 400 }
    static var unAuthorized: Int { return 401 } // Unauthorized request
    static var forbidden: Int { return 403 }
    static var notFound: Int { return 404 }
    static var notAllowed: Int { return 405 }
    static var blocked: Int { return 409 } // blocked by admin
    static var notVerified: Int { return 410 }
    static var emailNotExist: Int { return 411 }
    static var invalidOTP: Int { return 412 }
    static var userAlreadyExist: Int { return 422 }

}
