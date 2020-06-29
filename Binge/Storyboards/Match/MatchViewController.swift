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
            table.reload()
        }
    }
    
    private var friend: User? {
        didSet {
            guard let friend = friend else { return }
            configureNavigationBar(title: "Dining with \(friend.firstName)")
            configureEmptyState()
        }
    }
    
    private lazy var table: TableView = {
        let tableView = TableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DishCell.self, forCellReuseIdentifier: DishCell.identifier)
        tableView.placeholderDelegate = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureListener()
        configureNavigationBar()
        layoutTableView()
        configureEmptyState()
        initializeData()
    }
    
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
            self.dishes = []
            self.getFriend()
            self.getMatchedDishes()
        }
        NotificationCenter.default.addObserver(forName: .matchedDish, object: nil, queue: .main) { (notification) in
            guard let dish: Dish = notification.object as? Dish else { return }
            if self.dishes.first(where: { (d) -> Bool in d.id == dish.id }) == nil {
                self.dishes.append(dish)
                self.table.reload()
            }
        }
        NotificationCenter.default.addObserver(forName: .unlikedDish, object: nil, queue: .main) { (notification) in
            guard let dish: Dish = notification.object as? Dish else { return }
            self.dishes.removeAll { (d) -> Bool in
                d.id == dish.id
            }
            self.table.reload()
        }
    }
    
    private func configureNavigationBar(title: String? = nil) {
        navigationItem.title = title ?? "Binge"
        if let navBar = navigationController?.navigationBar {
             navBar.setup(titleColor: .black, hasBottomBorder: false, isTranslucent: true)
        }
    }
    
    private func initializeData() {
        if DataLoader.shared.matchedDishes.count > 0 {
            self.dishes.append(contentsOf: DataLoader.shared.matchedDishes)
        } else {
            getMatchedDishes()
        }
        if let friend = DataLoader.shared.friend {
            self.friend = friend
        } else {
            getFriend()
        }
    }
    
    private func getMatchedDishes() {
        if User.exists() == true {
            BingeAPI.sharedClient.getDishes(filter: .match, success: { (dishes) in
                self.dishes.append(contentsOf: dishes)
            }) { (_, message) in
                guard let message: String = message else { return }
                 print(message)
            }
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
        table.showsVerticalScrollIndicator = false
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
        table.reload()
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
        let matchLabel = matchTypeLabel(dish: dish)
        cell.addSubview(matchLabel)
        matchLabel.anchor(top: cell.safeAreaLayoutGuide.topAnchor,
                          right: cell.safeAreaLayoutGuide.rightAnchor,
                          paddingTop: 8,
                          paddingRight: 8)
        return cell
    }
    
    private func matchTypeLabel(dish: Dish) -> UIView {
        var title: String
        if dish.match == true {
            title = "DISH"
        } else if dish.restaurantMatch == true {
            title = "RESTAURANT"
        } else {
            return UIView()
        }
        return DishCardOverlayLabelView(withTitle: title, color: .green, rotation: 0)
    }
}

extension MatchViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "👎") { (action, indexPath) in
            let dish = self.dishes[indexPath.section]
            BingeAPI.sharedClient.dishAction(dish: dish, action: .unlike, success: {
                self.dishes.remove(at: indexPath.section)
                NotificationCenter.default.post(name: .unlikedDish, object: dish)
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
