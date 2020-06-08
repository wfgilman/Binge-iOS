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
    
    var dishes = [Dish]() {
        didSet {
            table.reloadData()
        }
    }
    
    private let table = TableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.register(DishCell.self, forCellReuseIdentifier: DishCell.identifier)
        table.placeholdersProvider = CustomPlaceholder.noLikes
        configureNavigationBar()
        configureListener()
        layoutTableView()
        getLikedDishes()
    }
    
    private func configureListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.likedDish, object: nil, queue: .main) { (notification) in
            guard let dish: Dish = notification.object as? Dish else { return }
            self.dishes.append(dish)
            self.table.reloadData()
        }
    }
    
    private func getLikedDishes() {
        BingeAPI.sharedClient.getLikedDishes(success: { (dishes) in
            self.dishes = dishes
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
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
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        options.transitionStyle = .drag
        return options
    }
    
}
