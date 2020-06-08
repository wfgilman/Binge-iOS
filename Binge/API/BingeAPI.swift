//
//  BingeAPI.swift
//  Binge
//
//  Created by Will Gilman on 5/22/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation
import Alamofire

enum DishAction {
    case like
    case unlike
}

class BingeAPI: NSObject {
    static let sharedClient = BingeAPI(baseURL: AppVariable.baseURL)
    var baseURL: String
    let headers = ["content-type": "application/json"]
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
                }
            case .failure(let error):
                let message = self.getErrorMessage(error: error, response: response)
                failure(error, message)
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
                }
            case .failure(let error):
                let message = self.getErrorMessage(error: error, response: response)
                failure(error, message)
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
                let message = self.getErrorMessage(error: error, response: response)
                failure(error, message)
            }
        })
    }
    
    func createUser(name: String, phone: String, success: @escaping (User) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users"
        let params: Parameters = ["first_name": name, "phone": phone, "status": "signed_up"]
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
                }
                
            case .failure(let error):
                let message = self.getErrorMessage(error: error, response: response)
                failure(error, message)
            }
        })
    }
    
    func generateCode(success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/action"
        guard let userId: Int = AppVariable.userId else { return }
        let params: Parameters = ["user_id": userId, "type": "sms"]
        af?.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseData(completionHandler: { (response) in
            switch response.result {
            case .success:
                success()
            case .failure(let error):
                let message = self.getErrorMessage(error: error, response: response)
                failure(error, message)
            }
        })
    }
    
    func verifyCode(code: String, success: @escaping (Token) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/users/action"
        guard let userId: Int = AppVariable.userId else { return }
        let params: Parameters = ["user_id": userId, "code": code]
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
                }
                
            case .failure(let error):
                let message = self.getErrorMessage(error: error, response: response)
                failure(error, message)
            }
        })
    }
    
    private func getErrorMessage(error: Error, response: DataResponse<Data>) -> String? {
        if let data = response.data {
            do {
                let err = try data.decoded() as ApiError
                print(err)
                return err.message
            } catch {
                // Handle error.
            }
        }
        return "An error occurred."
    }
}
//
