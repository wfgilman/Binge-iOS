//
//  LikesViewController.swift
//  Binge
//
//  Created by Will Gilman on 5/30/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import SwipeCellKit
import HGPlaceholders

class LikesViewController: UIViewController {
    
    private var dishes = [Dish]() {
        didSet {
            table.reload()
        }
    }
    
    private lazy var table: TableView = {
        let tableView = TableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DishCell.self, forCellReuseIdentifier: DishCell.identifier)
        tableView.placeholdersProvider = CustomPlaceholder.noLikes
        tableView.placeholderDelegate = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureListener()
        layoutTableView()
        initializeData()
    }
    
    private func configureListener() {
        NotificationCenter.default.addObserver(forName: .likedDish, object: nil, queue: .main) { (notification) in
            guard let dish: Dish = notification.object as? Dish else { return }
            self.dishes.append(dish)
            self.table.reload()
        }
        NotificationCenter.default.addObserver(forName: .unlikedDish, object: nil, queue: .main) { (notification) in
            guard let dish: Dish = notification.object as? Dish else { return }
            self.dishes.removeAll { (d) -> Bool in
                d.id == dish.id
            }
            self.table.reload()
        }
    }
    
    private func initializeData() {
        if DataLoader.shared.likedDishes.count > 0 {
            self.dishes.append(contentsOf: DataLoader.shared.likedDishes)
        } else {
            getLikedDishes()
        }
    }
    
    private func getLikedDishes() {
        if User.exists() == true {
            BingeAPI.sharedClient.getDishes(filter: .like, success: { (dishes) in
                self.dishes.append(contentsOf: dishes)
            }) { (_, message) in
                guard let message: String = message else { return }
                print(message)
            }
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Binge"
        if let navBar = navigationController?.navigationBar {
             navBar.setup(titleColor: .black, hasBottomBorder: false, isTranslucent: true)
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
}

extension LikesViewController: UITableViewDataSource, UITableViewDelegate {
    
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

extension LikesViewController: SwipeTableViewCellDelegate {
    
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

extension LikesViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        if let tabBar: UITabBarController = tabBarController {
            tabBar.selectedIndex = 0
        }
    }
    
    
}
