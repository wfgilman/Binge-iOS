//
//  CustomActionSheet.swift
//  Binge
//
//  Created by Will Gilman on 6/24/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit

class CustomActionSheet {
    
    func new(dish: Dish) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let doordash = UIAlertAction(title: "Doordash", style: .default) { (_) in
            if let url = URL(string: dish.doordashUrl) {
                UIApplication.shared.open(url)
            }
        }
        alert.addAction(doordash)
        
        if let uberEatsUrl = dish.uberEatsUrl {
            let uberEats = UIAlertAction(title: "Uber Eats", style: .default) { (_) in
                if let url = URL(string: uberEatsUrl) {
                    UIApplication.shared.open(url)
                }
            }
            alert.addAction(uberEats)
        }
        
        if let websiteUrl = dish.websiteUrl {
            let web = UIAlertAction(title: "Visit Website", style: .default) { (_) in
                if let url = URL(string: websiteUrl) {
                    UIApplication.shared.open(url)
                }
            }
            alert.addAction(web)
        }
        
        if let phone = dish.phone {
            let number = UIAlertAction(title: "Call \(phone)", style: .default) { (_) in
                if let url = URL(string: "tel://\(phone)") {
                    UIApplication.shared.open(url)
                }
            }
            alert.addAction(number)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        return alert
    }
}
