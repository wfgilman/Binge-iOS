//
//  Contact.swift
//  Binge
//
//  Created by Will Gilman on 6/8/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import Contacts

class ContactAPI: NSObject {
    static let sharedClient = ContactAPI()
    var store = CNContactStore()
    
    func getContacts(success: @escaping ([CNContact]) -> (), failure: @escaping (String?) -> ()) {
        var contacts = [CNContact]()
        checkAccess(success: { (granted) in
            if granted == true {
                DispatchQueue.main.async {
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                    let request = CNContactFetchRequest(keysToFetch: keys)
                    request.unifyResults = true
                    request.sortOrder = .givenName
                    do {
                        try self.store.enumerateContacts(with: request, usingBlock: { (contact, stop) in
                            if contact.phoneNumbers.count > 0 && contact.givenName.count > 0 {
                                contacts.append(contact)
                            }
                        })
                    } catch {
                        failure("Failed to get contacts.")
                    }
                    success(contacts)
                }
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func searchContacts(name: String, success: @escaping ([CNContact]) -> (), failure: @escaping (String?) -> ()) {
        var contacts = [CNContact]()
        checkAccess(success: { (granted) in
            if granted == true {
                DispatchQueue.main.async {
                    let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: name)
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                    do {
                        let results = try self.store.unifiedContacts(matching: predicate, keysToFetch: keys)
                        contacts.append(contentsOf: results)
                    } catch {
                        failure("Failed to search contacts.")
                    }
                    success(contacts)
                }
            }
        }) { (error) in
            failure(error)
        }
    }
    
    private func checkAccess(success: @escaping (_ granted: Bool) -> (), failure: @escaping (_ error: String) -> ()) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            success(true)
        case .denied, .notDetermined:
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { (granted, _) in
                if granted == true {
                    success(true)
                } else {
                    failure("User denied access to contacts.")
                }
            }
        default:
            success(false)
        }
    }
}
