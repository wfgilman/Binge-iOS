//
//  BingeAPI.swift
//  Binge
//
//  Created by Will Gilman on 5/22/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation
import Alamofire

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
