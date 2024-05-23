//
//  SignUpVC.swift
//  WordWideWeb
//
//  Created by David Jang on 5/14/24.
//

import UIKit
import SnapKit
import FirebaseAuth

class SignUpVC: UIViewController {
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.pretendard(size: 18, weight: .regular)
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your name"
        textField.layer.cornerRadius = 10
        textField.backgroundColor = UIColor.white
        textField.setLeftPaddingPoints(10)
        return textField
    }()
    
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
    
    private let emailCheckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Check Duplication", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = 10
        return button
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
    
    private let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm Password"
        label.font = UIFont.pretendard(size: 18, weight: .regular)
        return label
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "confirm password"
        textField.borderStyle = .none
        textField.layer.cornerRadius = 10
        textField.backgroundColor = UIColor.white
        textField.isSecureTextEntry = true
        textField.setLeftPaddingPoints(10)
        return textField
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = UIColor(named: "mainBtn")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.pretendard(size: 14, weight: .bold)
        return button
    }()
    
    private var emailChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor")
        setupNavigationBar()
        setupViews()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetEmailCheckState()
    }
    
    private func setupNavigationBar() {
        title = "Sign Up"
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
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(emailCheckButton)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordLabel)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(registerButton)
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(view).offset(24)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(48)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.left.equalTo(view).offset(24)
            make.top.equalTo(nameTextField.snp.bottom).offset(16)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(48)
        }
        
        emailCheckButton.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(34)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.left.equalTo(view).offset(32)
            make.top.equalTo(emailCheckButton.snp.bottom).offset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(8)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(48)
        }
        
        confirmPasswordLabel.snp.makeConstraints { make in
            make.left.equalTo(view).offset(32)
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
        }
        
        confirmPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordLabel.snp.bottom).offset(8)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(48)
        }
        
        registerButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(52)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        emailCheckButton.addTarget(self, action: #selector(checkEmailTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }
    
    private func setupObservers() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        let isFormValid = isFormValid()
        registerButton.isEnabled = isFormValid && emailChecked // 이메일 확인 후에만 활성화
        
        // 이메일 형식이 올바른지 확인하고, 확인되지 않은 상태에서만 이메일 체크 버튼을 활성화
        if let email = emailTextField.text, isValidEmail(email) {
            if !emailChecked {
                emailCheckButton.isEnabled = true
                emailCheckButton.backgroundColor = UIColor(named: "lightBtn")
            }
        } else {
            emailCheckButton.isEnabled = false
            emailCheckButton.backgroundColor = .lightGray
        }
    }
    
    private func isFormValid() -> Bool {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty,
              let name = nameTextField.text, !name.isEmpty else {
            return false
        }
        
        return password == confirmPassword
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @objc private func checkEmailTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            print("Invalid email")
            return
        }
        
        Task {
            let emailExists = await AuthenticationManager.shared.checkEmailExists(email: email)
            if emailExists {
                showAlert(title: "Error", message: "이미 가입된 이메일 입니다.")
                clearOtherFields() // 중복된 이메일일 경우 다른 필드의 입력값을 모두 지움
                emailChecked = false // 이메일 검증 상태를 초기화
                emailTextField.isEnabled = true // 이메일 필드를 다시 활성화
            } else {
                showAlert(title: "Success", message: "입력한 이메일 주소로 가입이 가능합니다.")
                emailCheckButton.isEnabled = false // 이메일 확인 후 비활성화
                emailTextField.isEnabled = false // 이메일 필드를 비활성화
                emailCheckButton.backgroundColor = .lightGray // 비활성화 색상
                emailChecked = true // 이메일이 확인되었음을 표시
            }
        }
    }
    
    private func clearOtherFields() {
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
    }
    
    private func resetEmailCheckState() {
        emailChecked = false
        textFieldDidChange()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func registerTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let name = nameTextField.text, !name.isEmpty else {
            print("Invalid input")
            return
        }
        
        Task {
            do {
                // 이메일이 이미 검증된 경우에만 등록.
                if emailChecked {
                    let user = try await AuthenticationManager.shared.createUser(email: email, password: password, displayName: name)
                    print("Registered user: \(user.uid)")
                    
                    // 성공적으로 등록 후 ViewController로 이동
                    navigateToMainViewController()
                } else {
                    // 이메일 검증이 되지 않은 경우 사용자에게 알림
                    showAlert(title: "Check Required", message: "Please check the email for validation first.")
                }
            } catch {
                print("Error registering: \(error.localizedDescription)")
                if let authError = error as NSError?, AuthErrorCode.Code(rawValue: authError.code) == .emailAlreadyInUse {
                    // 이미 사용 중인 이메일일 때 오류 처리
                    showAlert(title: "Registration Failed", message: "This email address is already in use.")
                } else {
                    // 다른 종류의 오류 처리
                    showAlert(title: "Registration Failed", message: "An unexpected error occurred. Please try again.")
                }
            }
        }
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
