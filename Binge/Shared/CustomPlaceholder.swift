//
//  CustomPlaceholder.swift
//  Binge
//
//  Created by Will Gilman on 6/5/20.
//  Copyright © 2020 BGHFM. All rights reserved.
//

import Foundation
import HGPlaceholders

class CustomPlaceholder {
    
    static var commonPlaceholderStyle: PlaceholderStyle = {
        var commonStyle = PlaceholderStyle()
        commonStyle.backgroundColor = .white
        commonStyle.actionBackgroundColor = .purple
        commonStyle.actionTitleColor = .white
        commonStyle.isAnimated = true
        commonStyle.titleFont = UIFont.systemFont(ofSize: 20)
        commonStyle.subtitleFont = UIFont.systemFont(ofSize: 17)
        commonStyle.actionTitleFont = UIFont.systemFont(ofSize: 17)
        return commonStyle
    }()
    
    static var noLikes: PlaceholdersProvider = {
        let loading = Placeholder(data: .loading, style: commonPlaceholderStyle, key: .loadingKey)
        let error = Placeholder(data: .error, style: commonPlaceholderStyle, key: .errorKey)
        let noConn = Placeholder(data: .noConnection, style: commonPlaceholderStyle, key: .noConnectionKey)
        
        var noLikesData: PlaceholderData = .noResults
        noLikesData.image = UIImage(systemName: "hand.thumbsup.fill")
        noLikesData.title = "No likes yet"
        noLikesData.subtitle = "Swipe right on the Discover tab \nto narrow down your options."
        noLikesData.action = "Start Swiping"
        
        let noLikes = Placeholder(data: noLikesData, style: commonPlaceholderStyle, key: .noResultsKey)
        
        let placeholdersProvider = PlaceholdersProvider(loading: loading, error: error, noResults: noLikes, noConnection: noConn)
        
        return placeholdersProvider
    }()
    
    static var noMatches: PlaceholdersProvider = {
        let loading = Placeholder(data: .loading, style: commonPlaceholderStyle, key: .loadingKey)
        let error = Placeholder(data: .error, style: commonPlaceholderStyle, key: .errorKey)
        let noConn = Placeholder(data: .noConnection, style: commonPlaceholderStyle, key: .noConnectionKey)
        
        var noResultsData: PlaceholderData = .noResults
        noResultsData.image = UIImage(systemName: "person.2.fill")
        noResultsData.title = "No love yet"
        noResultsData.subtitle = "Start swiping to start matching 😍"
        noResultsData.action = "Visit Discover"
        
        let noResults = Placeholder(data: noResultsData, style: commonPlaceholderStyle, key: .noResultsKey)
        
        let placeholdersProvider = PlaceholdersProvider(loading: loading, error: error, noResults: noResults, noConnection: noConn)
        
        return placeholdersProvider
    }()
    
    static var signupToMatch: PlaceholdersProvider = {
        let loading = Placeholder(data: .loading, style: commonPlaceholderStyle, key: .loadingKey)
        let error = Placeholder(data: .error, style: commonPlaceholderStyle, key: .errorKey)
        let noConn = Placeholder(data: .noConnection, style: commonPlaceholderStyle, key: .noConnectionKey)
        
        var noResultsData: PlaceholderData = .noResults
        noResultsData.image = UIImage(systemName: "person.2.fill")
        noResultsData.title = "Invite a friend"
        noResultsData.subtitle = "Find out what you're both \nhanckering for 🤤"
        noResultsData.action = "Get Started"
        
        let noResults = Placeholder(data: noResultsData, style: commonPlaceholderStyle, key: .noResultsKey)
        
        let placeholdersProvider = PlaceholdersProvider(loading: loading, error: error, noResults: noResults, noConnection: noConn)
        
        return placeholdersProvider
    }()
    
    static var createAccount: PlaceholdersProvider = {
        let loading = Placeholder(data: .loading, style: commonPlaceholderStyle, key: .loadingKey)
        let error = Placeholder(data: .error, style: commonPlaceholderStyle, key: .errorKey)
        let noConn = Placeholder(data: .noConnection, style: commonPlaceholderStyle, key: .noConnectionKey)
        
        var noResultsData: PlaceholderData = .noResults
        noResultsData.image = UIImage(systemName: "person.fill")
        noResultsData.title = "Access food features"
        noResultsData.subtitle = "Sign up to filter your \"feed\" \nand match with friends."
        noResultsData.action = "Get Started"
        
        let noResults = Placeholder(data: noResultsData, style: commonPlaceholderStyle, key: .noResultsKey)
        
        let placeholdersProvider = PlaceholdersProvider(loading: loading, error: error, noResults: noResults, noConnection: noConn)
        
        return placeholdersProvider
    }()
}
