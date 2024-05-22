//
//  UserDefaults.swift
//  WordWideWeb
//
//  Created by David Jang on 5/16/24.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Equatable {
    let uid: String
    let email: String
    let displayName: String?
    var photoURL: String?
    var socialMediaLink: String?
    let authProvider: AuthProviderOption
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}

struct Wordbook: Codable, Hashable {
    let id: String
    let ownerId: String
    let title: String
    let isPublic: Bool
    let dueDate: Timestamp?
    let createdAt: Timestamp
    let attendees: [String]
    let sharedWith: [String]?
    let colorCover: String
    var wordCount: Int
    var words: [Word]
    
    static func == (lhs: Wordbook, rhs: Wordbook) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Word: Codable {
    let id: String
    let term: String
    let definition: String
}

struct Invitation: Codable {
    let id: String
    let from: String
    let to: String
    let wordbookId: String
    let title: String
    let timestamp: Timestamp
    let dueDate: Timestamp?
}


extension UserDefaults {
    private enum Keys {
        static let isLoggedIn = "isLoggedIn"
        static let isAutoLoginEnabled = "isAutoLoginEnabled"
        static let googleIDToken = "googleIDToken"
        static let googleAccessToken = "googleAccessToken"
        static let appleIDToken = "appleIDToken"
        static let appleNonce = "appleNonce"
        static let appleEmail = "appleEmail"
        static let appleDisplayName = "appleDisplayName"
    }
    
    var isLoggedIn: Bool {
        get { return bool(forKey: Keys.isLoggedIn) }
        set { set(newValue, forKey: Keys.isLoggedIn) }
    }
    
    var isAutoLoginEnabled: Bool {
        get { return bool(forKey: Keys.isAutoLoginEnabled) }
        set { set(newValue, forKey: Keys.isAutoLoginEnabled) }
    }
    
    var googleIDToken: String? {
        get { return string(forKey: Keys.googleIDToken) }
        set { set(newValue, forKey: Keys.googleIDToken) }
    }
    
    var googleAccessToken: String? {
        get { return string(forKey: Keys.googleAccessToken) }
        set { set(newValue, forKey: Keys.googleAccessToken) }
    }
    
    var appleIDToken: String? {
        get { return string(forKey: Keys.appleIDToken) }
        set { set(newValue, forKey: Keys.appleIDToken) }
    }
    
    var appleNonce: String? {
        get { return string(forKey: Keys.appleNonce) }
        set { set(newValue, forKey: Keys.appleNonce) }
    }
    
    var appleEmail: String? { // 추가
        get { return string(forKey: Keys.appleEmail) }
        set { set(newValue, forKey: Keys.appleEmail) }
    }
    
    var appleDisplayName: String? { // 추가
        get { return string(forKey: Keys.appleDisplayName) }
        set { set(newValue, forKey: Keys.appleDisplayName) }
    }
}

