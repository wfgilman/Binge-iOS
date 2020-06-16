//
//  MatchViewController.swift
//  Binge
//
//  Created by Will Gilman on 6/4/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import SwipeCellKit
import HGPlaceholders

class MatchViewController: UIViewController {
    
    private var dishes = [Dish](){
        didSet {
            table.reloadData()
        }
    }
    
    private var friend: User? {
        didSet {
            guard let friend = friend else { return }
            configureNavigationBar(title: "Matching with \(friend.firstName)")
            configureEmptyState()
        }
    }
    
    private let table = TableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.register(DishCell.self, forCellReuseIdentifier: DishCell.identifier)
        table.placeholderDelegate = self
        configureListener()
        configureNavigationBar()
        layoutTableView()
        configureEmptyState()
        getFriend()
    }
    
//    private func getLikedDishes() {
//         BingeAPI.sharedClient.getLikedDishes(success: { (dishes) in
//             self.dishes = dishes
//         }) { (_, message) in
//            guard let message: String = message else { return }
//             print(message)
//         }
//     }
    
    private func configureListener() {
        NotificationCenter.default.addObserver(forName: .createdUser, object: nil, queue: .main) { (_) in
            self.configureEmptyState()
        }
        NotificationCenter.default.addObserver(forName: .deletedUser, object: nil, queue: .main) { (_) in
            self.configureNavigationBar()
            self.configureEmptyState()
        }
        NotificationCenter.default.addObserver(forName: .addedFriend, object: nil, queue: .main) { (_) in
            self.getFriend()
        }
        NotificationCenter.default.addObserver(forName: .changedFriend, object: nil, queue: .main) { (_) in
            self.getFriend()
        }
    }
    
    private func configureNavigationBar(title: String? = nil) {
        navigationItem.title = title ?? "Binge"
        if let navBar = navigationController?.navigationBar {
             navBar.setup(titleColor: .black, hasBottomBorder: false, isTranslucent: true)
        }
    }
    
    private func getFriend() {
        if User.exists() {
            BingeAPI.sharedClient.getFriend(success: { (friend) in
                self.friend = friend
            }) { (_, message) in
                guard let message: String = message else { return }
                print(message)
            }
        }
    }
    
    private func layoutTableView() {
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        table.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     left: view.safeAreaLayoutGuide.leftAnchor,
                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                     right: view.safeAreaLayoutGuide.rightAnchor,
                     paddingLeft: 20,
                     paddingRight: 20)
        table.rowHeight = view.bounds.height / 4
        table.separatorStyle = .none
    }
    
    private func configureEmptyState() {
        if User.exists() == true && friend != nil {
            table.placeholdersProvider = CustomPlaceholder.noMatches
        } else {
            table.placeholdersProvider = CustomPlaceholder.signupToMatch
        }
        table.reloadData()
    }
}

extension MatchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dishes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dish = dishes[indexPath.section]
        let cell = table.dequeueReusableCell(withIdentifier: DishCell.identifier, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.backgroundView = DishCardContentView(withDish: dish, bevelAmount: 10, hasShadow: true)
        return cell
    }
}

extension MatchViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "👎") { (action, indexPath) in
            BingeAPI.sharedClient.dishAction(dish: self.dishes[indexPath.section], action: .unlike, success: {
                self.dishes.remove(at: indexPath.section)
            }) { (_, message) in
                guard let message = message else { return }
                print("\(message)")
            }
        }
        
        deleteAction.backgroundColor = .white
        deleteAction.font = UIFont.systemFont(ofSize: 52)
        
        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        options.transitionStyle = .drag
        return options
    }
}

extension MatchViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        if User.exists() == true && friend != nil {
            if let tabBar: UITabBarController = tabBarController {
                tabBar.selectedIndex = 0
            }
        } else if User.exists() == true && friend == nil {
            let storyboard = UIStoryboard(name: "Invite", bundle: nil)
            guard let contactsVC = storyboard.instantiateInitialViewController() else { return }
            self.present(contactsVC, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "Onboard", bundle: nil)
            guard let signupVC = storyboard.instantiateInitialViewController() else { return }
            self.present(signupVC, animated: true, completion: nil)
        }
    }
}
