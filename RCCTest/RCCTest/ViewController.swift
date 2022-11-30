//
//  ViewController.swift
//  RCCTest
//
//  Created by Admin. on 30/11/22.
//

import UIKit
import Combine
import GSNetworking

class ViewController: UIViewController {

    let vm = ViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.getUserData(userId: "637c816d5bb7e176ba1d329e")
        print("Got Data", vm.userProfileData)
    }
}

// MARK: - UserDataModel
struct ProfileModel: Codable {
    let id: String
    let isPrivate, isProfessional, kycVerified: Bool
    let followersCount, followingCount: Int
    let email, firstName, lastName, username: String
    let profilePic: String
    let isOwner: Bool
    let totalFollowing: Int?
    let totalFollowers: Int?
    var followYouBack, followedByYou: Bool
    let feedCount: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case isPrivate = "is_private"
        case isProfessional = "is_professional"
        case kycVerified = "kyc_verified"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case profilePic = "profile_pic"
        case isOwner = "is_owner"
        case totalFollowing = "total_following"
        case totalFollowers = "total_followers"
        case followYouBack = "follow_you_back"
        case followedByYou = "followed_by_you"
        case feedCount = "feed_count"
    }
}


class ViewModel {
    
    @Published var userProfileData: ProfileModel? = nil
    
    var subscriptions: Set<AnyCancellable> = []
    
    func getUserData(userId: String) {
        let service =  GSNetworking.shared
        let params: [String:Any] = ["id":userId]
        service.commonAPICall(query: params , requestBodyModel:  String(), requestType: .get, endPoint: "/user/profile", resultType: ProfileModel.self)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Api call finished")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] userData in
                self?.userProfileData = userData
            }.store(in: &subscriptions)
    }

}
