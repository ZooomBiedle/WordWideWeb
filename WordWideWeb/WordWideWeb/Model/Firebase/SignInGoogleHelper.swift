//
//  SignInGoogleHelper.swift
//  FirebaseBootcamp
//
//  Created by David Jang on 5/9/24.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let name: String?
    let email: String?
    let photoURL: String?
}

final class SignInGoogleHelper {
    
    @MainActor
    func signIn(viewController: UIViewController) async throws -> GoogleSignInResultModel {
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        let name = gidSignInResult.user.profile?.name
        let email = gidSignInResult.user.profile?.email
        let photoURL = gidSignInResult.user.profile?.imageURL(withDimension: 200)?.absoluteString // 추가
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, name: name, email: email, photoURL: photoURL)
        return tokens
    }
}
