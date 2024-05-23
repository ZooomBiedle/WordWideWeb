//
//  AuthenticationVC.swift
//  WordWideWeb
//
//  Created by David Jang on 5/14/24.
//

import UIKit
import SnapKit
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import AuthenticationServices

class AuthenticationVC: UIViewController {
    
    // 이미지 추가해야함 애니메이션? 회의로 결정하기
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome!"
        label.font = UIFont.pretendard(size: 18, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let signInDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your email to sign up for this app"
        label.font = UIFont.pretendard(size: 14, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = UIColor(named: "mainBtn")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.pretendard(size: 14, weight: .bold)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up with email", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let orContinueLabel: UILabel = {
        let label = UILabel()
        label.text = "or continue with"
        label.font = UIFont.pretendard(size: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    private let googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.colorScheme = .light
        button.style = .wide
        return button
    }()
    
    private let appleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        button.cornerRadius = 10
        return button
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        let text = "By clicking continue, you agree to our Terms of Service and Privacy Policy"
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.foregroundColor, value: UIColor.black, range: (text as NSString).range(of: "Terms of Service"))
        attributedText.addAttribute(.foregroundColor, value: UIColor.black, range: (text as NSString).range(of: "Privacy Policy"))
        label.attributedText = attributedText
        label.font = UIFont.pretendard(size: 12, weight: .regular)
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor")
        setupViews()
        setupNotificationObservers()
        
        // 앱 시작 시 로그인 상태 확인
        if UserDefaults.standard.isLoggedIn && UserDefaults.standard.isAutoLoginEnabled {
            navigateToMainViewController()
        }
    }
    
    private func setupViews() {
        view.addSubview(welcomeLabel)
        view.addSubview(signInDescriptionLabel)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(orContinueLabel)
        view.addSubview(googleSignInButton)
        view.addSubview(appleSignInButton)
        view.addSubview(termsLabel)
        
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(320)
            make.centerX.equalTo(view)
        }
        
        signInDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(8)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(signInDescriptionLabel.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(44)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(10)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(44)
        }
        
        orContinueLabel.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(20)
            make.centerX.equalTo(view)
        }
        
        googleSignInButton.snp.makeConstraints { make in
            make.top.equalTo(orContinueLabel.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(44)
        }
        
        appleSignInButton.snp.makeConstraints { make in
            make.top.equalTo(googleSignInButton.snp.bottom).offset(10)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(44)
        }
        
        termsLabel.snp.makeConstraints { make in
            make.top.equalTo(appleSignInButton.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
        }
        
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserLogout), name: .userDidLogout, object: nil)
    }
    
    @objc private func signInTapped() {
        let signInVC = SignInVC()
        navigationController?.pushViewController(signInVC, animated: true)
    }
    
    @objc private func signUpTapped() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc private func googleSignInTapped() {
        Task {
            do {
                let signInResult = try await SignInGoogleHelper().signIn(viewController: self)
                print("Google Sign-In successful: \(signInResult)")
                try await authenticateWithFirebase(using: signInResult)
                UserDefaults.standard.isLoggedIn = true // 로그인 상태 저장
                UserDefaults.standard.isAutoLoginEnabled = true // 자동 로그인 상태 저장
                navigateToMainViewController()
            } catch {
                print("Google Sign-In failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func authenticateWithFirebase(using googleSignInResult: GoogleSignInResultModel) async throws {
        let credential = GoogleAuthProvider.credential(withIDToken: googleSignInResult.idToken, accessToken: googleSignInResult.accessToken)
        _ = try await Auth.auth().signIn(with: credential)
        
        if let user = Auth.auth().currentUser {
            let userModel = User(uid: user.uid, email: googleSignInResult.email ?? "", displayName: googleSignInResult.name, photoURL: googleSignInResult.photoURL, authProvider: .google, blockCount: 0)
            try await FirestoreManager.shared.saveOrUpdateUser(user: userModel)
        }
    }
    
    @objc private func appleSignInTapped() {
        Task {
            do {
                let helper = SignInAppleHelper()
                let signInResult = try await helper.startSignInWithAppleFlow(viewController: self)
                
                print("Apple Sign-In successful: \(signInResult)")
                try await authenticateWithFirebase(using: signInResult)
                UserDefaults.standard.isLoggedIn = true // 로그인 상태 저장
                UserDefaults.standard.isAutoLoginEnabled = true // 자동 로그인 상태 저장
                UserDefaults.standard.appleIDToken = signInResult.token
                UserDefaults.standard.appleNonce = signInResult.nonce
                navigateToMainViewController()
            } catch {
                print("Apple Sign-In failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func authenticateWithFirebase(using appleSignInResult: SignInWithAppleResult) async throws {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: appleSignInResult.token, rawNonce: appleSignInResult.nonce)
        _ = try await Auth.auth().signIn(with: credential)
        
        if let user = Auth.auth().currentUser {
            let userModel = User(uid: user.uid, email: appleSignInResult.email ?? "", displayName: appleSignInResult.displayName, photoURL: nil, authProvider: .apple, blockCount: 0)
            try await FirestoreManager.shared.saveOrUpdateUser(user: userModel)
        }
    }
    
    private func navigateToMainViewController() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil)
    }
    
    @objc private func handleUserLogout() {
        // 로그아웃 후 AuthenticationVC 다시 생성
        UserDefaults.standard.isLoggedIn = false
        UserDefaults.standard.isAutoLoginEnabled = false
        let authVC = AuthenticationVC()
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true, completion: nil)
    }
}

extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}
