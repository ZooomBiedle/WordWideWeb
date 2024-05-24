//
//  ProfileVC.swift
//  WordWideWeb
//
//  Created by David Jang on 5/19/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SnapKit
import SDWebImage
import Combine
import AuthenticationServices
import FirebaseCore
import GoogleSignIn

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
//        imageView.layer.borderWidth = 2
//        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private let editImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pencil.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        imageView.layer.cornerRadius = 15
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "User Name"
        label.font = UIFont.pretendard(size: 14, weight: .regular)
        return label
    }()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Edit your name"
        textField.layer.cornerRadius = 10
        textField.backgroundColor = UIColor.white
        textField.setLeftPaddingPoints(10)
        textField.isEnabled = false
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray.cgColor
        return textField
    }()
    
    private let nicknameEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let socialMediaLabel: UILabel = {
        let label = UILabel()
        label.text = "Social"
        label.font = UIFont.pretendard(size: 14, weight: .regular)
        return label
    }()
    
    private let socialMediaTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "https://"
        textField.layer.cornerRadius = 10
        textField.backgroundColor = UIColor.white
        textField.setLeftPaddingPoints(10)
        textField.isEnabled = false
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray.cgColor
        return textField
    }()
    
    private let socialMediaEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.backgroundColor = UIColor(named: "mainBtn")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Account & Sign Out", for: .normal)
        button.setTitleColor(UIColor(named: "pointRed"), for: .normal)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var viewModel = ProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var selectedImage: UIImage?
    private var isUploading = false
    private var authProvider: AuthProviderOption?
    private var signInAppleHelper = SignInAppleHelper()
    private var signInGoogleHelper = SignInGoogleHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor")
        setupViews()
        loadUserInfo()
        bindViewModel()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editImageTapped))
        editImageView.addGestureRecognizer(tapGestureRecognizer)
        
        if let user = try? AuthenticationManager.shared.getAuthenticatedUser(), user.authProvider != .email {
            nicknameTextField.isEnabled = false
            editImageView.isUserInteractionEnabled = false
            nicknameEditButton.isHidden = true
            editImageView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func bindViewModel() {
        viewModel.$displayName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayName in
                self?.nicknameTextField.text = displayName
                // authProvider에 따라 텍스트 필드 비활성화
                if self?.viewModel.user?.authProvider == .google || self?.viewModel.user?.authProvider == .apple {
                    self?.nicknameTextField.isUserInteractionEnabled = false
                    self?.nicknameEditButton.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        viewModel.$photoURL
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                guard let self = self else { return }
                if let url = url {
                    self.profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle"))
                } else {
                    self.profileImageView.image = UIImage(systemName: "person.crop.circle")
                }
                // authProvider에 따라 이미지 뷰 비활성화
                if self.viewModel.user?.authProvider == .google || self.viewModel.user?.authProvider == .apple {
                    self.editImageView.isUserInteractionEnabled = false
                    self.editImageView.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        viewModel.$socialMediaLink
            .receive(on: DispatchQueue.main)
            .sink { [weak self] socialMediaLink in
                self?.socialMediaTextField.text = socialMediaLink
            }
            .store(in: &cancellables)
    }

    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(editImageView)
        view.addSubview(nicknameLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(nicknameEditButton)
        view.addSubview(socialMediaLabel)
        view.addSubview(socialMediaTextField)
        view.addSubview(socialMediaEditButton)
        view.addSubview(doneButton)
        view.addSubview(closeButton)
        view.addSubview(deleteAccountButton)
        view.addSubview(activityIndicator)
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(36)
            make.centerX.equalTo(view)
            make.width.height.equalTo(100)
        }
        
        editImageView.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView.snp.bottom).offset(-4)
            make.right.equalTo(profileImageView.snp.right).offset(-4)
            make.width.height.equalTo(30)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(32)
            make.left.equalTo(view).offset(24)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(48)
        }
        
        nicknameEditButton.snp.makeConstraints { make in
            make.centerY.equalTo(nicknameTextField.snp.centerY)
            make.left.equalTo(nicknameTextField.snp.right).offset(-32)
            make.width.height.equalTo(24)
        }
        
        socialMediaLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(24)
            make.left.equalTo(view).offset(24)
        }
        
        socialMediaTextField.snp.makeConstraints { make in
            make.top.equalTo(socialMediaLabel.snp.bottom).offset(10)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(48)
        }
        
        socialMediaEditButton.snp.makeConstraints { make in
            make.centerY.equalTo(socialMediaTextField.snp.centerY)
            make.left.equalTo(socialMediaTextField.snp.right).offset(-32)
            make.width.height.equalTo(24)
        }
        
        doneButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(52)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.left.equalTo(view).offset(16)
        }
        
        deleteAccountButton.snp.makeConstraints { make in
            make.top.equalTo(socialMediaTextField.snp.bottom).offset(24)
            make.centerX.equalTo(view)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
        
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        nicknameEditButton.addTarget(self, action: #selector(nicknameEditTapped), for: .touchUpInside)
        socialMediaEditButton.addTarget(self, action: #selector(socialMediaEditTapped), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
    }
    
    private func loadUserInfo() {
        if let user = Auth.auth().currentUser {
            nicknameTextField.text = user.displayName
            
            if let photoURL = user.photoURL {
                profileImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(systemName: "person.crop.circle"))
            } else {
                profileImageView.image = UIImage(systemName: "person.crop.circle")
            }
        }
    }

    private func updateUIForAuthProvider() {
        guard let authProvider = authProvider else { return }
        
        if authProvider == .email {
            nicknameTextField.isEnabled = true
            editImageView.isUserInteractionEnabled = true
        } else {
            nicknameTextField.isEnabled = false
            editImageView.isUserInteractionEnabled = false
        }
    }
    
    @objc private func doneTapped() {
        let nickname = nicknameTextField.text ?? ""
        let socialMediaLink = socialMediaTextField.text ?? ""
        
        activityIndicator.startAnimating()

        Task {
            do {
                if let selectedImage = selectedImage, !isUploading {
                    isUploading = true
                    let url = try await FirestoreManager.shared.uploadProfileImage(selectedImage, for: Auth.auth().currentUser!.uid)
                    try await FirestoreManager.shared.updateUserProfile(displayName: nickname, photoURL: url, socialMediaLink: socialMediaLink)
                    isUploading = false
                } else {
                    try await FirestoreManager.shared.updateUserProfile(displayName: nickname, photoURL: nil, socialMediaLink: socialMediaLink)
                }
                NotificationCenter.default.post(name: .userProfileUpdated, object: nil)
                
                // **UI 리프레시**
                self.viewModel.fetchUserInfo()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.activityIndicator.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                }
                
            } catch {
                print("Error uploading image: \(error.localizedDescription)")
                isUploading = false
                activityIndicator.stopAnimating()
            }
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func editImageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true) {
            DispatchQueue.main.async {
                self.profileImageView.layer.borderWidth = 2
                self.profileImageView.layer.borderColor = UIColor.systemBlue.cgColor
            }
        }
    }

    
    @objc private func nicknameEditTapped() {
        nicknameTextField.isEnabled = true
        nicknameTextField.becomeFirstResponder()
    }
    
    @objc private func socialMediaEditTapped() {
        socialMediaTextField.isEnabled = true
        socialMediaTextField.becomeFirstResponder()
    }
    
    @objc private func deleteAccountTapped() {
        // 재인증 확인 대화 상자 표시
        let alertController = UIAlertController(title: "Bye", message: "You have been logged out. \n See you next time!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            self.activityIndicator.startAnimating()
            self.reauthenticateAndDeleteAccount()
        }))
        present(alertController, animated: true, completion: nil)
    }

    private func reauthenticateAndDeleteAccount() {
        guard let user = Auth.auth().currentUser else { return }

        if user.providerData.first?.providerID == AuthProviderOption.apple.rawValue {
            reauthenticateWithApple(user: user)
        } else if user.providerData.first?.providerID == AuthProviderOption.google.rawValue {
            reauthenticateWithGoogle(user: user)
        } else {
            reauthenticateWithEmail(user: user)
        }
    }
    
    private func reauthenticateWithEmail(user: FirebaseAuth.User) {
        let alertController = UIAlertController(title: "Reauthenticate", message: "Please enter your password to continue", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            guard let password = alertController.textFields?.first?.text else { return }
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: password)
            user.reauthenticate(with: credential) { result, error in
                if let error = error {
                    print("Error re-authenticating: \(error.localizedDescription)")
                    self.activityIndicator.stopAnimating()
                    return
                }
                self.deleteUserAccount(user: user)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func reauthenticateWithGoogle(user: FirebaseAuth.User) {
        Task {
            do {
                let result = try await signInGoogleHelper.signIn(viewController: self)
                let credential = GoogleAuthProvider.credential(withIDToken: result.idToken, accessToken: result.accessToken)
                try await user.reauthenticate(with: credential)
                self.deleteUserAccount(user: user)
            } catch {
                print("Error during Google re-authentication: \(error.localizedDescription)")
                self.activityIndicator.stopAnimating()
            }
        }
    }

    private func reauthenticateWithApple(user: FirebaseAuth.User) {
        Task {
            do {
                let result = try await signInAppleHelper.startSignInWithAppleFlow(viewController: self)
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: result.token, rawNonce: result.nonce)
                try await user.reauthenticate(with: credential)
                self.deleteUserAccount(user: user)
            } catch {
                print("Error during Apple re-authentication: \(error.localizedDescription)")
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func deleteUserAccount(user: FirebaseAuth.User) {
        Task {
            do {
                let uid = user.uid
                try await FirestoreManager.shared.deleteUser(uid: uid)
                try await user.delete()
                UserDefaults.standard.isLoggedIn = false
                UserDefaults.standard.isAutoLoginEnabled = false
                NotificationCenter.default.post(name: .userDidLogout, object: nil)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.navigateToAuthenticationVC()
                }
            } catch {
                print("Error deleting account: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func navigateToAuthenticationVC() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else { return }
        sceneDelegate.setRootViewController()
    }

    
    // MARK: 이미지피커
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        profileImageView.image = selectedImage
        self.selectedImage = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

private extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
