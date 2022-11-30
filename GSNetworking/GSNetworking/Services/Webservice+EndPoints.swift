//
//  Webservice+EndPoints.swift
 
import Foundation

var baseUrl = "https://devpg-backend.herokuapp.com/api/v1"


public extension WebServices {
    
    enum EndPoint : String {
        // Login & Logout
        case sendOtp = "/sendotp"
        case verifyOtp="verifyotp"
        case logout = "/user/logout"
        case searchUsers="/search"
        case createPost="/create/post"
        case myPosts="/myposts"
        case userPosts="/user/posts"
        case deletePosts="/delete/post"
        case userProfile="/user/profile"
        case myProfile="/profile"
        case follow = "/follow"
        case feeds = "/feeds"
        case like = "/like"
        case comment = "/comments"
        
        case generateURLforUpload = "/generate_signed_url"
        
        var path : String {
            let url = baseUrl
            return url + self.rawValue
        }
    }
}
