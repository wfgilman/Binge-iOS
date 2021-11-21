//
//  LikesViewController.swift
//  Binge
//
//  Created by Will Gilman on 5/30/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import HGPlaceholders

class LikesViewController: UIViewController {
    
    private var dishes = [Dish]() {
        didSet {
            collection.reloadData()
        }
    }
    
    private var flowLayout = UICollectionViewFlowLayout()
    private var flowPadding: CGFloat = 16
    
    private lazy var collection: CollectionView = {
        let collectionView = CollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DishTile.self, forCellWithReuseIdentifier: DishTile.identifier)
        collectionView.placeholdersProvider = CustomPlaceholder.noLikes
        collectionView.placeholderDelegate = self
        return collectionView
    }()
    
    private lazy var refresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadLikedDishes), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureListener()
        layoutCollectionView()
        initializeData()
    }
    
    private func configureListener() {
        NotificationCenter.default.addObserver(forName: .likedDish, object: nil, queue: .main) { (notification) in
            guard let dish: Dish = notification.object as? Dish else { return }
            if self.dishes.first(where: { (d) -> Bool in d.id == dish.id }) == nil {
                self.dishes.append(dish)
                self.collection.reloadData()
            }
        }
        NotificationCenter.default.addObserver(forName: .unlikedDish, object: nil, queue: .main) { (notification) in
            guard let dish: Dish = notification.object as? Dish else { return }
            self.dishes.removeAll { (d) -> Bool in
                d.id == dish.id
            }
            self.collection.reloadData()
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
        if AppVariable.validUser == true {
            BingeAPI.sharedClient.getDishes(filter: .like, success: { (dishes) in
                self.dishes.append(contentsOf: dishes)
            }) { (_, message) in
                guard let message: String = message else { return }
                print(message)
            }
        }
    }
    
    @objc
    private func reloadLikedDishes() {
        if AppVariable.validUser == true {
            BingeAPI.sharedClient.getDishes(filter: .like, success: { (dishes) in
                self.dishes = dishes
                self.refresh.endRefreshing()
            }) { (_, message) in
                self.refresh.endRefreshing()
                guard let message: String = message else { return }
                print(message)
            }
        } else {
            self.refresh.endRefreshing()
        }
    }
    
    @objc
    private func didTapRemoveButton(sender: UIButton) {
        let indexPathRow: Int = sender.tag
        let dish = self.dishes[indexPathRow]
        if AppVariable.validUser == true {
            BingeAPI.sharedClient.dishAction(dish: dish, action: .unlike) {
                NotificationCenter.default.post(name: .unlikedDish, object: dish)
            } failure: { _, message in
                guard let message = message else { return }
                print("\(message)")
            }
        } else {
            self.dishes.remove(at: indexPathRow)
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Likes"
        if let navBar = navigationController?.navigationBar {
             navBar.setup(titleColor: .black, hasBottomBorder: false, isTranslucent: true)
        }
    }
    
    private func layoutCollectionView() {
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsVerticalScrollIndicator = false
        view.addSubview(collection)
        collection.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left: view.safeAreaLayoutGuide.leftAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.safeAreaLayoutGuide.rightAnchor,
                          paddingLeft: 0,
                          paddingRight: 0)
        collection.insertSubview(refresh, at: 0)
        flowLayout.scrollDirection = .vertical
    }
}

extension LikesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dishes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dish = dishes[indexPath.row]
        let tile = collection.dequeueReusableCell(withReuseIdentifier: DishTile.identifier, for: indexPath) as! DishTile
        tile.backgroundView = DishCardContentView(withDish: dish, bevelAmount: 10, hasShadow: true)
        
        let removeButton = UIButton(type: .system)
        removeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        removeButton.tintColor = .gray
        removeButton.addTarget(self, action: #selector(didTapRemoveButton(sender:)), for: .touchUpInside)
        removeButton.tag = indexPath.row
        tile.backgroundView?.addSubview(removeButton)
        removeButton.anchor(top: tile.backgroundView?.safeAreaLayoutGuide.topAnchor,
                            right: tile.backgroundView?.safeAreaLayoutGuide.rightAnchor,
                            width: 36,
                            height: 36)
        
        return tile
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collection.bounds.width - flowPadding * 3) / 2
        let itemHeight = itemWidth * 1.2
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: flowPadding, left: flowPadding, bottom: flowPadding, right: flowPadding)
    }
}

extension LikesViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        if let tabBar: UITabBarController = tabBarController {
            tabBar.selectedIndex = 0
        }
    }
}
