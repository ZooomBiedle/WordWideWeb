//
//  AuthenticationManager.swift
//  WordWideWeb
//
//  Created by David Jang on 5/14/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let displayName: String?
    let photoURL: String?
    var socialMediaLink: String?
    let authProvider: AuthProviderOption
    
    init(user: FirebaseAuth.User, authProvider: AuthProviderOption) {
        self.uid = user.uid
        self.email = user.email
        self.displayName = user.displayName
        self.photoURL = user.photoURL?.absoluteString
        self.socialMediaLink = nil
        self.authProvider = authProvider
    }
}

enum AuthProviderOption: String, Codable {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() {}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        // authProvider를 포함하여 초기화
        let providerData = user.providerData
        var authProvider: AuthProviderOption = .email // 기본값 설정
        for provider in providerData {
            if let providerType = AuthProviderOption(rawValue: provider.providerID) {
                authProvider = providerType
                break
            }
        }
        return AuthDataResultModel(user: user, authProvider: authProvider)
    }

    // 변경된 이메일 중복 확인 메서드
    func checkEmailExists(email: String) async -> Bool {
        do {
            _ = try await Auth.auth().createUser(withEmail: email, password: "temporaryPassword")
            // 임시 사용자가 생성되면 삭제
            let user = Auth.auth().currentUser
            try await user?.delete()
            return false
        } catch let error as NSError {
            if let errorCode = AuthErrorCode.Code(rawValue: error.code), errorCode == .emailAlreadyInUse {
                return true
            } else {
                // 다른 에러 발생 시 false 반환
                return false
            }
        }
    }
    
    func saveUserToFirestore(uid: String, email: String, displayName: String?, photoURL: String?, authProvider: AuthProviderOption) async throws {
        let user = User(uid: uid, email: email, displayName: displayName, photoURL: photoURL, socialMediaLink: nil, authProvider: authProvider, blockCount: 0)
        try await FirestoreManager.shared.saveOrUpdateUser(user: user)
    }

    @discardableResult
    func createUser(email: String, password: String, displayName: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = AuthDataResultModel(user: authDataResult.user, authProvider: .email)
        
        let changeRequest = authDataResult.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
        
        try await saveUserToFirestore(uid: user.uid, email: user.email!, displayName: displayName, photoURL: user.photoURL, authProvider: .email)
        return user
    }

    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = AuthDataResultModel(user: authDataResult.user, authProvider: .email)
        try await saveUserToFirestore(uid: user.uid, email: user.email!, displayName: user.displayName, photoURL: user.photoURL, authProvider: .email)
        return user
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}

// MARK: SIGN IN SSO
extension AuthenticationManager {
    
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        let authDataResult = try await signIn(credential: credential)
        
        let user = User(uid: authDataResult.uid, email: tokens.email ?? "", displayName: tokens.name, photoURL: tokens.photoURL, authProvider: .google, blockCount: 0)
        print("Google sign-in user: \(user)")
        try await FirestoreManager.shared.saveOrUpdateUser(user: user)
        
        try await updateUserProfileFromFirestore()
        
        return authDataResult
    }
        
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokens.token, rawNonce: tokens.nonce)
        let authDataResult = try await signIn(credential: credential)
        
        var email = tokens.email
        var displayName = tokens.fullName
        
        if let appleEmail = UserDefaults.standard.appleEmail, let appleDisplayName = UserDefaults.standard.appleDisplayName {
            email = email?.isEmpty == false ? email : appleEmail
            displayName = displayName?.isEmpty == false ? displayName : appleDisplayName
        } else {
            UserDefaults.standard.appleEmail = email
            UserDefaults.standard.appleDisplayName = displayName
        }

        let user = User(uid: authDataResult.uid, email: email ?? "", displayName: displayName, photoURL: nil, authProvider: .apple, blockCount: 0)
        print("Apple sign-in user: \(user)")
        try await FirestoreManager.shared.saveOrUpdateUser(user: user)
        
        try await updateUserProfileFromFirestore()
        
        return authDataResult
    }

    private func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        let providerData = authDataResult.user.providerData
        var authProvider: AuthProviderOption = .email // 기본값 설정
        for provider in providerData {
            if let providerType = AuthProviderOption(rawValue: provider.providerID) {
                authProvider = providerType
                break
            }
        }
        return AuthDataResultModel(user: authDataResult.user, authProvider: authProvider)
    }
    
    func updateUserProfileFromFirestore() async throws {
        guard let user = Auth.auth().currentUser else { return }
        let userRef = Firestore.firestore().collection("users").document(user.uid)
        let document = try await userRef.getDocument()
        guard let data = document.data() else { return }
        let displayName = data["displayName"] as? String
        let photoURL = data["photoURL"] as? String
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        changeRequest.photoURL = URL(string: photoURL ?? "")
        try await changeRequest.commitChanges()
    }
}
