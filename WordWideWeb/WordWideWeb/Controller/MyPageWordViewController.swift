//
//  MyPageWordViewController.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import UIKit
import SnapKit

// 단어카드 다음페이지 : 단어 리스트 페이지
class MyPageWordViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(returnMain), for: .touchUpInside)
        return button
    }()
    @objc func returnMain() {
//        self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    lazy var wordButton: UIButton = {
        let button = UIButton()
        button.setTitle("word", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.setTitleColor(.black, for: .normal)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.addTarget(self, action: #selector(modalPageTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func modalPageTapped() {
        let myPageModalVC = MyPageModalViewController()
        myPageModalVC.modalPresentationStyle = .formSheet
        if let sheet = myPageModalVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        self.present(myPageModalVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor")
        layout()
    }
 
    private func layout() {
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.left.equalTo(view).offset(16)
        }
        
        view.addSubview(wordButton)
        wordButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(120)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(55)
//            make.trailing.equalToSuperview().offset(-270)
//            make.bottom.equalToSuperview().offset(-700)
        }
    }
}
