//
//  ContactsViewController.swift
//  Binge
//
//  Created by Will Gilman on 6/8/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import Contacts

class ContactsViewController: UIViewController {
    
    private var contacts = [CNContact]()
    
    private var filteredContacts = [CNContact]() {
        didSet {
            table.reloadData()
        }
    }
    
    private lazy var table: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactCell.self, forCellReuseIdentifier: ContactCell.identifier)
        return tableView
    }()
    
    private lazy var search: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = self
        searchBar.backgroundColor = .white
        searchBar.barTintColor = .white
        searchBar.tintColor = .purple
        searchBar.setImage(UIImage(), for: .clear, state: .normal)
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        layoutTableView()
        getContacts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is InviteViewController {
            let inviteVC = segue.destination as! InviteViewController
            inviteVC.contact = sender as? CNContact
        }
    }
    
    private func getContacts() {
        ContactAPI.sharedClient.getContacts(success: { (contacts) in
            self.contacts = contacts
            self.filteredContacts = contacts
        }) { (message) in
            guard let message: String = message else { return }
            print(message)
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Invite a friend"
        navigationItem.addBackButton()
    }
    
    private func layoutTableView() {
        view.addSubview(search)
        search.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                      left: view.safeAreaLayoutGuide.leftAnchor,
                      right: view.safeAreaLayoutGuide.rightAnchor,
                      height: 44)
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        table.anchor(top: search.bottomAnchor,
                     left: view.safeAreaLayoutGuide.leftAnchor,
                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                     right: view.safeAreaLayoutGuide.rightAnchor)
        table.rowHeight = 72
        table.tableFooterView = UIView()
    }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = filteredContacts[indexPath.row]
        let cell = table.dequeueReusableCell(withIdentifier: ContactCell.identifier, for: indexPath) as! ContactCell
        cell.contact = contact
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        let contact = filteredContacts[indexPath.row]
        performSegue(withIdentifier: "showInviteViewController", sender: contact)
    }
    
}

extension ContactsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == false {
            ContactAPI.sharedClient.searchContacts(name: searchText, success: { (contacts) in
                self.filteredContacts = contacts
            }) { (message) in
                guard let message: String = message else { return }
                print(message)
            }
        } else {
            self.filteredContacts = self.contacts
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        search.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search.showsCancelButton = false
        searchBar.text = ""
        filteredContacts = contacts
        searchBar.resignFirstResponder()
    }
}
