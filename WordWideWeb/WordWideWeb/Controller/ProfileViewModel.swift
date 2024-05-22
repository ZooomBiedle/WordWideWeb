//
//  ProfileViewModel.swift
//  WordWideWeb
//
//  Created by David Jang on 5/19/24.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var photoURL: URL?
    @Published var socialMediaLink: String? = nil
    
    var user: User?

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchUserInfo()
        observeUserUpdates()
    }

    func fetchUserInfo() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
        userRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let document = document, document.exists {
                self.user = try? document.data(as: User.self)
                self.updatePublishedValues()
            } else {
                print("Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func observeUserUpdates() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
        userRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let snapshot = snapshot, snapshot.exists {
                self.user = try? snapshot.data(as: User.self)
                self.updatePublishedValues()
            } else {
                print("Error observing user updates: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func updatePublishedValues() {
        guard let user = user else { return }
        self.displayName = user.displayName ?? ""
        self.photoURL = URL(string: user.photoURL ?? "")
        self.socialMediaLink = user.socialMediaLink ?? ""
        
        NotificationCenter.default.post(name: .userProfileUpdated, object: nil)
    }

    func updateUserProfile(displayName: String?, photoURL: URL?, socialMediaLink: String?) async {
        guard let currentUser = Auth.auth().currentUser else { return }

        var updateData: [String: Any] = [:]
        if let displayName = displayName {
            updateData["displayName"] = displayName
        }
        if let photoURL = photoURL {
            updateData["photoURL"] = photoURL.absoluteString
        }
        if let socialMediaLink = socialMediaLink {
            updateData["socialMediaLink"] = socialMediaLink
        }

        let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
        do {
            try await userRef.updateData(updateData)
        } catch {
            print("Error updating user: \(error.localizedDescription)")
        }
    }
}


