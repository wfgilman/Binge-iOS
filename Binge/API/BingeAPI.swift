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

enum DishAction {
    case like
    case unlike
}

class BingeAPI: NSObject {
    static let sharedClient = BingeAPI(baseURL: AppVariable.baseURL)
    var baseURL: String
    var headers = ["content-type": "application/json"]
    var af: Alamofire.SessionManager?
    
    init(baseURL: String) {
        self.baseURL = baseURL
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.urlCache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        self.af = Alamofire.SessionManager(configuration: configuration)
    }
    
    func getDishes(success: @escaping ([Dish]) -> (), failure: @escaping (Error, String?) -> ()) {
        af?.request(self.baseURL + "/dishes").validate().responseData(completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                do {
                    let dishes = try value.decoded() as [Dish]
                    success(dishes)
                } catch {
                    // Handle failure.
                    print("decoding Dishes failed")
                }
            case .failure(let error):
                let err = self.getError(response: response)
                self.handleFailure(error: err)
                failure(error, err.message)
            }
        })
    }
    
    func getLikedDishes(success: @escaping ([Dish]) -> (), failure: @escaping (Error, String?) -> ()) {
        af?.request(self.baseURL + "/dishes?filter=likes").validate().responseData(completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                do {
                    let dishes = try value.decoded() as [Dish]
                    success(dishes)
                } catch {
                    // Handle failure.
                    print("decoding Dishes failed")
                }
            case .failure(let error):
                let err = self.getError(response: response)
                self.handleFailure(error: err)
                failure(error, err.message)
            }
        })
    }
    
    func dishAction(dish: Dish, action: DishAction, success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/dishes/action"
        let params: Parameters = ["user_id": "bg", "dish_id": dish.id, "restaurant_id": dish.restaurantId, "action": "\(action)"]
        af?.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success:
                    success()
                case .failure(let error):
                    let err = self.getError(response: response)
                    self.handleFailure(error: err)
                    failure(error, err.message)
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
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    do {
                        let user = try value.decoded() as User
                        success(user)
                    } catch {
                        // Handle failure.
                        print("decoding User failed")
                    }
                case .failure(let error):
                    let err = self.getError(response: response)
                    self.handleFailure(error: err)
                    failure(error, err.message)
            }
        })
    }
    
    func generateCode(user: User, success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/action"
        let params: Parameters = ["user_id": user.id, "type": "sms"]
        af?.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success:
                    success()
                case .failure(let error):
                    let err = self.getError(response: response)
                    self.handleFailure(error: err)
                    failure(error, err.message)
                }
        })
    }
    
    func verifyCode(user: User, code: String, success: @escaping (Token) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/action"
        let params: Parameters = ["user_id": user.id, "code": code]
        af?.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseData(completionHandler: { (response) in
            switch response.result {
                case .success(let value):
                    do {
                        let token = try value.decoded() as Token
                        success(token)
                    } catch {
                        // Handle failure.
                        print("decoding Token failed")
                    }
                case .failure(let error):
                    let err = self.getError(response: response)
                    self.handleFailure(error: err)
                    failure(error, err.message)
            }
        })
    }
    
    func inviteUser(contact: CNContact, success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
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
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success:
                    success()
                case .failure(let error):
                    let err = self.getError(response: response)
                    self.handleFailure(error: err)
                    failure(error, err.message)
                }
        })
    }
    
    func getUser(success: @escaping (User) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users"
        let headers = getAuthHeaders()
        af?.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    do {
                        let user = try value.decoded() as User
                        success(user)
                    } catch {
                        // Handle failure.
                        print("decoding User failed")
                    }
                case .failure(let error):
                    let err = self.getError(response: response)
                    self.handleFailure(error: err)
                    failure(error, err.message)
                }
            })
    }
    
    func deleteUser(success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users"
        let headers = getAuthHeaders()
        af?.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        .validate()
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success:
                    success()
                case .failure(let error):
                    let err = self.getError(response: response)
                    self.handleFailure(error: err)
                    failure(error, err.message)
                }
            })
    }
    
    func getFriend(success: @escaping (User?) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/friends?active=true"
        let headers = getAuthHeaders()
        af?.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    do {
                        let user = try value.decoded() as User
                        success(user)
                    } catch {
                        // Handle failure.
                        print("decoding Friend failed")
                        success(nil)
                    }
                case .failure(let error):
                    let err = self.getError(response: response)
                    self.handleFailure(error: err)
                    failure(error, err.message)
                }
            })
    }
    
    func getFriends(success: @escaping ([User]) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/friends"
        let headers = getAuthHeaders()
        af?.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    do {
                        let users = try value.decoded() as [User]
                        success(users)
                    } catch {
                        // Handle failure.
                        print("decoding Friends failed")
                    }
                case .failure(let error):
                    let err = self.getError(response: response)
                    self.handleFailure(error: err)
                    failure(error, err.message)
                }
            })
    }
    
    private func getAuthHeaders() -> [String : String] {
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
    
    private func getError(response: DataResponse<Data>) -> ApiError {
        if let data = response.data {
            do {
                let err = try data.decoded() as ApiError
                return err
            } catch {
                // Handle error.
                print("decoding ApiError failed")
                return ApiError(code: "decode_error", message: "Failed to decode API error.")
            }
        }
        return ApiError(code: "unknown_error", message: "No response from server.")
    }
}
