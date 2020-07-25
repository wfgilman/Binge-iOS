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
import PARTagPicker

enum MatchType {
    case none
    case dish
    case restaurant
}

enum FilterAction {
    case add
    case remove
}

class DishViewController: UIViewController {
    
    var dishes = [Dish]() {
        didSet {
            filteredDishes = dishes
            dishCardStack.reloadData()
        }
    }
    
    private var hiddenDishes = [Dish]()
    private var filteredDishes = [Dish]()
    
    private var chosenFilters = [String]()
    
    private var likes = [Like]()
    
    private lazy var dishCardStack: SwipeCardStack = {
        let stack = SwipeCardStack()
        stack.delegate = self
        stack.dataSource = self
        return stack
    }()
    
    private lazy var tagController: PARTagPickerViewController = {
        let tag = PARTagPickerViewController()
        tag.delegate = self
        tag.placeholderText = "Add a Filter"
        tag.allTags = ["Breakfast", "Lunch", "Dinner", "American", "Chinese", "Mexican", "Indian"]
        tag.allowsNewTags = true
        tag.view.backgroundColor = .white
        tag.textfieldRegularTextColor = .purple
        tag.font = UIFont.systemFont(ofSize: 17)
        let colors = PARTagColorReference()
        colors?.defaultTagTextColor = .purple
        colors?.defaultTagBorderColor = .purple
        colors?.defaultTagBackgroundColor = .white
        colors?.chosenTagTextColor = .white
        colors?.chosenTagBorderColor = .purple
        colors?.chosenTagBackgroundColor = .purple
        colors?.highlightedTagTextColor = .white
        colors?.highlightedTagBorderColor = .purple
        colors?.highlightedTagBackgroundColor = .purple
        tag.tagColorRef = colors
        return tag
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch: UITouch = touches.first else { return }
        if touch.view != tagController.view {
            view.endEditing(true)
        }
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
//        navigationItem.addTextButton(side: .Left, text: "Undo", color: .lightGray, target: self, action: #selector(handleShift(_:)))
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
        addChild(tagController)
        view.addSubview(tagController.view)
        tagController.view.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                  left: view.safeAreaLayoutGuide.leftAnchor,
                                  right: view.safeAreaLayoutGuide.rightAnchor,
                                  height: COLLECTION_VIEW_HEIGHT)
//        tagController.view.frame = CGRect(x: 0, y: 88, width: view.bounds.width, height: COLLECTION_VIEW_HEIGHT)
        view.addSubview(dishCardStack)
        dishCardStack.anchor(top: tagController.view.bottomAnchor,
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
        
        let dish = filteredDishes[index]
        card.content = DishCardContentView(withDish: dish)
        card.footer = DishCardFooterView(withTitle: dish.name, subtitle: dish.restaurantName)

        return card
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return filteredDishes.count
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        let dish = filteredDishes[index]
        switch direction {
        case .up:
            didLikeDish(dish)
            let alert = self.actionSheet.order(dish: dish)
            self.present(alert, animated: true, completion: nil)
        case .right:
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

extension DishViewController: PARTagPickerDelegate {
    
    func tagPicker(_ tagPicker: PARTagPickerViewController!, visibilityChangedTo state: PARTagPickerVisibilityState) {
        var newHeight: CGFloat = 0
        if state == .topAndBottom {
            newHeight = 2 * COLLECTION_VIEW_HEIGHT
        } else if state == .topOnly {
            newHeight = COLLECTION_VIEW_HEIGHT
        }

        var frame = tagPicker.view.frame
        frame.size.height = newHeight

        UIView.animate(withDuration: 0.3) {
            tagPicker.view.frame = frame
            self.tagController.view.layoutIfNeeded()
        }
    }
    
    func chosenTagsWereUpdated(inTagPicker tagPicker: PARTagPickerViewController!) {
        let (action, filter) = selectedFilter()
        
        switch action {
        case .add:
            let dishesToHide = filteredDishes.filter { $0.category != filter }
            hideDishes(dishesToHide)
        case .remove:
            let dishesToShow = hiddenDishes.filter { $0.category != filter }
            showDishes(dishesToShow)
        }
    }
    
    private func selectedFilter() -> (FilterAction, String) {
        var action: FilterAction!
        var changedFilters = [String]()
        let chosenTags = tagController.chosenTags as! [String]
        let changes = chosenFilters.difference(from: chosenTags)
        chosenFilters = chosenTags
        
        let addedFilters = changes.insertions.compactMap { (change) -> String? in
            guard case let .insert(_, element, _) = change else { return nil }
            action = .remove
            return element
        }
        let removedFilters = changes.removals.compactMap { (change) -> String? in
            guard case let .remove(_, element, _) = change else { return nil }
            action = .add
            return element
        }
        
        changedFilters.append(contentsOf: addedFilters)
        changedFilters.append(contentsOf: removedFilters)
        
        return (action, changedFilters.first!)
    }
    
    private func hideDishes(_ dishes: [Dish]) {
        for dish in dishes {
            filteredDishes.removeAll { $0.id == dish.id }
        }
        hiddenDishes.append(contentsOf: dishes)
        dishCardStack.reloadData()
    }
    
    private func showDishes(_ dishes: [Dish]) {
        for dish in dishes {
            hiddenDishes.removeAll { $0.id == dish.id }
        }
        filteredDishes.append(contentsOf: dishes)
        dishCardStack.reloadData()
    }
}
