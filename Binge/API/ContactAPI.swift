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
        checkAccess(completion: { (granted) in
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
        })
    }
    
    func searchContacts(name: String, success: @escaping ([CNContact]) -> (), failure: @escaping (String?) -> ()) {
        var contacts = [CNContact]()
        checkAccess(completion: { (granted) in
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
        })
    }
    
    func requestAccess() {
        checkAccess { (granted) in
            if granted == false {
                if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        DispatchQueue.main.async { UIApplication.shared.open(appSettings) }
                    }
                }
            }
        }
    }
    
    func checkAccess(completion: @escaping (_ granted: Bool) -> ()) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { (granted, _) in
                completion(granted)
            }
        case .denied:
            completion(false)
        default:
            completion(false)
        }
    }
}
