//
//  SignInWithAppleHelper.swift
//  WordWideWeb
//
//  Created by David Jang on 5/16/24.
//

import Foundation
import CryptoKit
import AuthenticationServices
import UIKit

struct SignInWithAppleResult {
    let token: String
    let nonce: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let nickName: String?
    
    var fullName: String? {
        if let firstName, let lastName {
            return firstName + " " + lastName
        } else if let firstName {
            return firstName
        } else if let lastName {
            return lastName
        }
        return nil
    }
    
    var displayName: String? {
        fullName ?? nickName
    }
    
    init?(authorization: ASAuthorization, nonce: String) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let token = String(data: appleIDToken, encoding: .utf8)
        else {
            print("Failed to get Apple ID token")
            return nil
        }
        
        self.token = token
        self.nonce = nonce
        self.email = appleIDCredential.email
        self.firstName = appleIDCredential.fullName?.givenName
        self.lastName = appleIDCredential.fullName?.familyName
        self.nickName = appleIDCredential.fullName?.nickname
    }
}

final class SignInAppleHelper: NSObject {
    
    private var currentNonce: String? = nil
    private var continuation: CheckedContinuation<SignInWithAppleResult, Error>?
    
    @MainActor
    func startSignInWithAppleFlow(viewController: UIViewController? = nil) async throws -> SignInWithAppleResult {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.startSignInWithAppleFlow(viewController: viewController)
        }
    }
    
    @MainActor
    private func startSignInWithAppleFlow(viewController: UIViewController? = nil) {
        guard let topVC = viewController ?? Utilities.shared.topViewController() else {
            continuation?.resume(throwing: SignInWithAppleError.noViewController)
            return
        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        showOSPrompt(nonce: nonce, on: topVC)
    }
}

// MARK: PRIVATE
private extension SignInAppleHelper {
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func showOSPrompt(nonce: String, on viewController: UIViewController) {
        print("Starting Apple sign-in process...")
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = viewController
        
        authorizationController.performRequests()
    }
    
    private enum SignInWithAppleError: LocalizedError {
        case noViewController
        case invalidCredential
        case badResponse
        case unableToFindNonce
        
        var errorDescription: String? {
            switch self {
                case .noViewController:
                    return "Could not find top view controller."
                case .invalidCredential:
                    return "Invalid sign in credential."
                case .badResponse:
                    return "Apple Sign In had a bad response."
                case .unableToFindNonce:
                    return "Apple Sign In token expired."
            }
        }
    }
    
}

extension SignInAppleHelper: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        do {
            guard let currentNonce else {
                throw SignInWithAppleError.unableToFindNonce
            }
            
            guard let result = SignInWithAppleResult(authorization: authorization, nonce: currentNonce) else {
                throw SignInWithAppleError.badResponse
            }
            
            // 저장할 사용자 정보 UserDefaults에 저장
            UserDefaults.standard.appleEmail = result.email
            UserDefaults.standard.appleDisplayName = result.displayName
            
            print("Apple sign-in successful: \(result)")
            continuation?.resume(returning: result)
        } catch {
            print("Apple sign-in failed with error: \(error)")
            continuation?.resume(throwing: error)
            return
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple sign-in failed with error: \(error)")
        continuation?.resume(throwing: error)
        return
    }
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
