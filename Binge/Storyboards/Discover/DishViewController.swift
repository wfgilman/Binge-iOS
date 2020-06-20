//
//  ViewController.swift
//  Binge
//
//  Created by Will Gilman on 5/21/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import UIKit
import Shuffle_iOS

class DishViewController: UIViewController {
    
    var dishes = [Dish]() {
        didSet {
            dishCardStack.reloadData()
        }
    }
    private let dishCardStack = SwipeCardStack()

    override func viewDidLoad() {
        super.viewDidLoad()
        dishCardStack.delegate = self
        dishCardStack.dataSource = self
        configureNavigationBar()
        layoutCardStackView()
        configureBackgroundGradient()
        getDishes()
    }

    private func getDishes() {
        let filter: DishFilter = User.exists() == true ? .none : .noauth
        BingeAPI.sharedClient.getDishes(filter: filter, success: { (dishes) in
            self.dishes = dishes
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
        }
    }
    
    private func configureNavigationBar() {
        let backButton = UIBarButtonItem(title: "Undo",
                                       style: .plain,
                                       target: self,
                                       action: #selector(handleShift))
        backButton.tag = 1
        backButton.tintColor = .lightGray
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = "Binge"
        if let navBar = navigationController?.navigationBar {
             navBar.setup(titleColor: .black, hasBottomBorder: false, isTranslucent: true)
        }
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
            if let url = URL(string: dish.doordashUrl) {
                UIApplication.shared.open(url)
            }
        case .right:
            let dish = dishes[index]
            NotificationCenter.default.post(name: .likedDish, object: dish)
            if User.exists() == true {
                self.post(dish, action: .like)
            }
            if dish.match == true {
                // Do visual effect to notify user
                print("you matched!")
                NotificationCenter.default.post(name: .matchedDish, object: dish)
            }
        case .left:
            print("nothing yet")
        case .down:
            print("down swiping not allowed")
        }
    }
    
    private func post(_ dish: Dish, action: DishAction) {
        BingeAPI.sharedClient.dishAction(dish: dish, action: action, success: {
            // Nothing to see here.
        }) { (_, message) in
            guard let message = message else { return }
            print("\(message)")
        }

    }
    
}
