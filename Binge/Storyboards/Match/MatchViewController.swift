//
//  MatchViewController.swift
//  Binge
//
//  Created by Will Gilman on 6/4/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import HGPlaceholders

class MatchViewController: UIViewController {
    
    private var dishes = [Dish](){
        didSet {
            collection.reloadData()
        }
    }
    
    private var friend: User? {
        didSet {
            guard let friend = friend else { return }
            configureNavigationBar(title: "Matches with \(friend.firstName)")
            configureEmptyState()
        }
    }
    
    private var flowLayout = UICollectionViewFlowLayout()
    private var flowPadding: CGFloat = 16
    
    private lazy var collection: CollectionView = {
        let collectionView = CollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MatchTile.self, forCellWithReuseIdentifier: MatchTile.identifier)
        collectionView.placeholdersProvider = CustomPlaceholder.noLikes
        collectionView.placeholderDelegate = self
        return collectionView
    }()
    
    private lazy var refresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadMatchedDishes), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureListener()
        configureNavigationBar()
        layoutCollectionView()
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
        if AppVariable.validUser == true {
            BingeAPI.sharedClient.getDishes(filter: .match, success: { (dishes) in
                self.dishes.append(contentsOf: dishes)
            }) { (_, message) in
                guard let message: String = message else { return }
                 print(message)
            }
        }
    }
    
    @objc
    private func reloadMatchedDishes() {
        if AppVariable.validUser == true {
            BingeAPI.sharedClient.getDishes(filter: .match, success: { (dishes) in
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
    
    private func getFriend() {
        if AppVariable.validUser == true {
            BingeAPI.sharedClient.getFriend(success: { (friend) in
                self.friend = friend
            }) { (_, message) in
                guard let message: String = message else { return }
                print(message)
            }
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
    
    private func configureEmptyState() {
        if AppVariable.validUser == true && friend != nil {
            collection.placeholdersProvider = CustomPlaceholder.noMatches
        } else {
            collection.placeholdersProvider = CustomPlaceholder.signupToMatch
        }
        collection.reloadData()
    }
}

extension MatchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dishes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dish = dishes[indexPath.row]
        let tile = collection.dequeueReusableCell(withReuseIdentifier: MatchTile.identifier, for: indexPath) as! MatchTile
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
        
        let likeTypeView = UILabel(frame: .zero)
        likeTypeView.text = dish.match == true ? "🍽" : "🎉"
        likeTypeView.font = UIFont(name: "ArialRoundedMTBold", size: 48)
        tile.backgroundView?.addSubview(likeTypeView)
        likeTypeView.anchor(left: tile.backgroundView?.safeAreaLayoutGuide.leftAnchor,
                            bottom: tile.backgroundView?.safeAreaLayoutGuide.bottomAnchor,
                            paddingLeft: 8,
                            paddingBottom: 8)
        
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

extension MatchViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        if AppVariable.validUser == true && friend != nil {
            if let tabBar: UITabBarController = tabBarController {
                tabBar.selectedIndex = 0
            }
        } else if AppVariable.validUser == true && friend == nil {
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
