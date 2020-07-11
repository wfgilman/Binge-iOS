//
//  ViewController.swift
//  Binge
//
//  Created by Will Gilman on 5/21/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import Shuffle_iOS
import SPAlert

enum MatchType {
    case none
    case dish
    case restaurant
}

class DishViewController: UIViewController {
    
    var dishes = [Dish]() {
        didSet {
            dishCardStack.reloadData()
        }
    }
    
    private var likes = [Like]()
    
    private lazy var dishCardStack: SwipeCardStack = {
        let stack = SwipeCardStack()
        stack.delegate = self
        stack.dataSource = self
        return stack
    }()
    
    private let actionSheet = CustomAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureListener()
        configureNavigationBar()
        layoutCardStackView()
        configureBackgroundGradient()
        initializeData()
    }
    
    private func configureListener() {
        NotificationCenter.default.addObserver(forName: .changedFriend, object: nil, queue: .main) { (_) in
            self.getFriendLikes()
        }
    }
    
    private func initializeData() {
        if DataLoader.shared.dishes.count > 0 {
            self.dishes = DataLoader.shared.dishes
        } else {
            getDishes()
        }
        
        if AppVariable.validUser == true {
            if DataLoader.shared.likes.count > 0 {
                self.likes = DataLoader.shared.likes
            } else {
                getFriendLikes()
            }
        }
    }

    private func getDishes() {
        let filter: DishFilter = (AppVariable.validUser == true) ? .none : .noauth
        BingeAPI.sharedClient.getDishes(filter: filter, success: { (dishes) in
            self.dishes = dishes
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
        }
    }
    
    private func getFriendLikes() {
        BingeAPI.sharedClient.getFriendLikes(success: { (likes) in
            self.likes = likes
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.addTextButton(side: .Left, text: "Undo", color: .lightGray, target: self, action: #selector(handleShift(_:)))
        navigationItem.addTextButton(side: .Right, text: "Share", color: .black, target: self, action: #selector(shareBinge))
        navigationItem.title = "Binge"
        if let navBar = navigationController?.navigationBar {
             navBar.setup(titleColor: .black, hasBottomBorder: false, isTranslucent: true)
        }
    }
    
    @objc private func shareBinge() {
        let activity = UIActivityViewController(activityItems: [AppVariable.shareText], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }
    
    private func layoutCardStackView() {
      view.addSubview(dishCardStack)
      dishCardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                       left: view.safeAreaLayoutGuide.leftAnchor,
                       bottom: view.safeAreaLayoutGuide.bottomAnchor,
                       right: view.safeAreaLayoutGuide.rightAnchor)
    }
    
    private func configureBackgroundGradient() {
      let backgroundGray = UIColor(red: 244/255, green: 247/255, blue: 250/255, alpha: 1)
      let gradientLayer = CAGradientLayer()
      gradientLayer.colors = [UIColor.white.cgColor, backgroundGray.cgColor]
      gradientLayer.frame = view.bounds
      view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc private func handleShift(_ sender: UIButton) {
        dishCardStack.undoLastSwipe(animated: true)
    }
}

extension DishViewController: SwipeCardStackDelegate, SwipeCardStackDataSource {
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = SwipeCard()
        card.swipeDirections = [.left, .right, .up]
        for direction in card.swipeDirections {
          card.setOverlay(DishCardOverlay(direction: direction), forDirection: direction)
        }
        
        let dish = dishes[index]
        card.content = DishCardContentView(withDish: dish)
        card.footer = DishCardFooterView(withTitle: dish.name, subtitle: dish.restaurantName)

        return card
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return dishes.count
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        switch direction {
        case .up:
            let dish = dishes[index]
            didLikeDish(dish)
            let alert = self.actionSheet.order(dish: dish)
            self.present(alert, animated: true, completion: nil)
        case .right:
            let dish = dishes[index]
            didLikeDish(dish)
        default:
            break
        }
    }
    
    private func didLikeDish(_ dish: Dish) {
        NotificationCenter.default.post(name: .likedDish, object: dish)
        
        if AppVariable.validUser == true {
            BingeAPI.sharedClient.dishAction(dish: dish, action: .like, success: {
                // Nothing to see here.
            }) { (_, message) in
                guard let message = message else { return }
                print("\(message)")
            }
        } else {
            DataLoader.shared.likedDishes.append(dish)
        }
        
        let match: MatchType = checkMatch(dish)
        
        if match == .dish {
            SPAlert.present(title: "You matched this dish!", preset: .heart)
            tabBarController?.incrementBadgeCount(position: 2)
            PushAPI.shared.send(dish: dish)
            NotificationCenter.default.post(name: .matchedDish, object: dish)
            return
        }
        
        if match == .restaurant {
            SPAlert.present(title: "You matched this restaurant!", preset: .star)
            tabBarController?.incrementBadgeCount(position: 2)
            PushAPI.shared.send(dish: dish)
            NotificationCenter.default.post(name: .matchedDish, object: dish)
            return
        }
    }
    
    private func checkMatch(_ dish: Dish) -> MatchType {
        if self.likes.first(where: { (like) -> Bool in like.dishId == dish.id}) != nil {
            return .dish
        }
        if self.likes.first(where: { (like) -> Bool in like.restaurantId == dish.restaurantId }) != nil {
            return .restaurant
        }
        return .none
    }
}
