//
//  SignInVC.swift
//  WordWideWeb
//
//  Created by David Jang on 5/14/24.
//

import UIKit
import SnapKit

class SignInVC: UIViewController {
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.pretendard(size: 18, weight: .regular)
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "abc@google.com"
        textField.layer.cornerRadius = 10
        textField.backgroundColor = UIColor.white
        textField.clearButtonMode = .whileEditing
        textField.setLeftPaddingPoints(10)
        return textField
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = UIFont.pretendard(size: 18, weight: .regular)
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "password"
        textField.borderStyle = .none
        textField.layer.cornerRadius = 10
        textField.backgroundColor = UIColor.white
        textField.isSecureTextEntry = true
        textField.setLeftPaddingPoints(10)
        return textField
    }()
    
    private let autoLoginToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = UserDefaults.standard.isAutoLoginEnabled
        toggle.onTintColor = UIColor(named: "mainBtn")
        return toggle
    }()
    
    private let autoLoginLabel: UILabel = {
        let label = UILabel()
        label.text = "Automatic login"
        label.font = UIFont.pretendard(size: 18, weight: .regular)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor")
        setupNavigationBar()
        setupViews()
    }
    
    private func setupNavigationBar() {
        title = "Sign in"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "pointGreen") as Any,
            .font: UIFont.pretendard(size: 18, weight: .regular)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationController?.navigationBar.tintColor = UIColor(named: "pointGreen")
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupViews() {
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(autoLoginLabel)
        view.addSubview(autoLoginToggle)
        view.addSubview(signInButton)
        
        emailLabel.snp.makeConstraints { make in
            make.left.equalTo(view).offset(24)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(48)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.left.equalTo(view).offset(32)
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(8)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(48)
        }
        
        autoLoginLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.left.equalTo(view).offset(24)
        }
        
        autoLoginToggle.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.right.equalTo(view).offset(-20)
        }
        
        signInButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(52)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        autoLoginToggle.addTarget(self, action: #selector(autoLoginToggled(_:)), for: .valueChanged)
    }
    
    @objc private func signInTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Invalid input")
            return
        }
        
        Task {
            do {
                let user = try await AuthenticationManager.shared.signInUser(email: email, password: password)
                print("Signed in user: \(user.uid)")
                if autoLoginToggle.isOn {
                    UserDefaults.standard.isLoggedIn = true
                }
                UserDefaults.standard.isAutoLoginEnabled = autoLoginToggle.isOn
                navigateToMainViewController()
            } catch {
                print("Error signing in: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func autoLoginToggled(_ sender: UISwitch) {
        UserDefaults.standard.isAutoLoginEnabled = sender.isOn
    }
    
    private func navigateToMainViewController() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil)
    }
}

private extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
