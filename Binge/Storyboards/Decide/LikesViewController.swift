//
//  LikesViewController.swift
//  Binge
//
//  Created by Will Gilman on 5/30/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit

class LikesViewController: UIViewController {
    
    var dishes = [Dish]() {
        didSet {
            collection.reloadData()
        }
    }
    private let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.backgroundColor = .white
        collection.delegate = self
        collection.dataSource = self
        collection.register(DishCell.self, forCellWithReuseIdentifier: DishCell.identifier)
        configureNavigationBar()
        configureListener()
        layoutCollectionView()
        getLikedDishes()
    }
    
    private func configureListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.likedDish, object: nil, queue: .main) { (notification) in
            guard let dish: Dish = notification.object as? Dish else { return }
            self.dishes.append(dish)
            self.collection.reloadData()
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
    
    private func layoutCollectionView() {
        collection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collection)
        collection.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left: view.safeAreaLayoutGuide.leftAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.safeAreaLayoutGuide.rightAnchor)
    }
}

extension LikesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dishes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dish = dishes[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DishCell.identifier, for: indexPath) as! DishCell
        cell.backgroundView = DishCardContentView(withDish: dish, bevelAmount: 10, hasShadow: false)
        return cell
    }
}

extension LikesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 40, height: (collectionView.bounds.height - 60) / 3)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
