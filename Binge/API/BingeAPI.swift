//
//  BingeAPI.swift
//  Binge
//
//  Created by Will Gilman on 5/22/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation
import Alamofire
import Contacts

enum DishFilter {
    case noauth
    case none
    case like
    case match
}

enum DishAction {
    case like
    case unlike
    case match
}

class BingeAPI: NSObject {
    static let sharedClient = BingeAPI(baseURL: AppVariable.baseURL)
    var baseURL: String
    var headers: HTTPHeaders = ["content-type": "application/json"]
    var af: Alamofire.Session?
    
    init(baseURL: String) {
        self.baseURL = baseURL
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.urlCache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        self.af = Alamofire.Session(configuration: configuration)
    }
    
    func getDishes(filter: DishFilter, success: @escaping ([Dish]) -> (), failure: @escaping (Error, String?) -> ()) {
        let headers = getAuthHeaders()
        let url = buildURL(filter: filter)
        af?.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: Dishes.self, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    success(value.dishes)
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    private func buildURL(filter: DishFilter) -> String {
        switch filter {
        case .noauth:
            return self.baseURL + "/dishes"
        case .none:
            return self.baseURL + "/users/dishes"
        case .like:
            return self.baseURL + "/users/dishes?filter=likes"
        case .match:
            return self.baseURL + "/users/dishes?filter=matches"
        }
    }
    
    func dishAction(dish: Dish, action: DishAction, success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/dishes/action"
        let headers = getAuthHeaders()
        var params: Parameters = ["dish_id": dish.id, "restaurant_id": dish.restaurantId, "action": "\(action)"]
        if action == .match && dish.match == false && dish.restaurantMatch == true {
            params["restaurant"] = true
        }
        af?.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response(completionHandler: { response in
                switch response.result {
                case .success:
                    success()
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    func createUser(name: String, phone: String, success: @escaping (User) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users"
        let params: Parameters = [
            "first_name": name,
            "phone": phone.cleanPhoneNumber(),
            "status": "signed_up"
        ]
        af?.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: User.self, completionHandler: { response in
                switch response.result {
                case .success(let user):
                    success(user)
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    func generateCode(user: User, success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/action"
        let params: Parameters = ["user_id": user.id, "type": "sms"]
        af?.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response(completionHandler: { response in
                switch response.result {
                case .success:
                    success()
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    func verifyCode(user: User, code: String, success: @escaping (Token) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/action"
        let params: Parameters = ["user_id": user.id, "code": code]
        af?.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: Token.self, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    success(value)
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    func inviteUser(contact: CNMutableContact, success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/invite"
        let headers = getAuthHeaders()
        guard let phone = contact.phoneNumbers.first else { return }
        let params: Parameters = [
            "first_name": contact.givenName,
            "last_name": contact.familyName,
            "phone": phone.value.stringValue.cleanPhoneNumber(),
            "status": "invited"
        ]
        af?.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response(completionHandler: { response in
                switch response.result {
                case .success:
                    success()
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    func getUser(success: @escaping (User) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users"
        let headers = getAuthHeaders()
        af?.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: User.self, completionHandler: { response in
                switch response.result {
                case .success(let user):
                    success(user)
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    func updateUser(params: Dictionary<String, String>, success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users"
        let headers = getAuthHeaders()
        let params: Parameters = params
        af?.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response(completionHandler: { response in
                switch response.result {
                case .success:
                    success()
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    func deleteUser(success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users"
        let headers = getAuthHeaders()
        af?.request(url, method: .delete, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response(completionHandler: { response in
                switch response.result {
                case .success:
                    success()
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    func getFriend(success: @escaping (User?) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/friends?active=true"
        let headers = getAuthHeaders()
        af?.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: User.self, completionHandler: { response in
                switch response.result {
                case .success(let user):
                    success(user)
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    func getFriends(success: @escaping ([User]) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/friends"
        let headers = getAuthHeaders()
        af?.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: Friends.self, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    success(value.friends)
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    func getFriendLikes(success: @escaping ([Like]) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/friends/likes?active_friend=true"
        let headers = getAuthHeaders()
        af?.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: Likes.self, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    success(value.likes)
                case .failure(let error):
                    print(error)
                    failure(error, error.errorDescription)
                }
            })
    }
    
    private func getAuthHeaders() -> HTTPHeaders {
        var headers = self.headers
        guard let token: String = AppVariable.accessToken else {
            return headers
        }
        headers["authorization"] = "Bearer " + token
        return headers
    }
    
    private func handleFailure(error: ApiError) {
        switch error.code {
        case "authentication_error":
            print("deleted User")
            User.delete()
        default:
            print("other error")
        }
    }
    
//    private func getError(response: AFDataResponse<Data>) -> ApiError {
//        if let data = response.data {
//            do {
//                let err = try data.decoded() as ApiError
//                return err
//            } catch {
//                // Handle error.
//                print("decoding ApiError failed")
//                return ApiError(code: "decode_error", message: "Failed to decode API error.")
//            }
//        }
//        return ApiError(code: "unknown_error", message: "No response from server.")
//    }
}
