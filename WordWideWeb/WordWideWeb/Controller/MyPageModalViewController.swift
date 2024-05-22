//
//  MyPageModelViewController.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import UIKit
import SnapKit

class MyPageModalViewController: UIViewController {
    
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(returnWord), for: .touchUpInside)
        return button
    }()
    
    @objc func returnWord() {
        self.dismiss(animated: true)
    }
    
    lazy var wordLabel: UILabel = {
        let label = UILabel()
        label.text = "World"
        label.textColor = .white
        label.font = UIFont.pretendard(size: 32, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    lazy var pronunciationLabel: UILabel = {
        let label = UILabel()
        label.text = "미국식 [ wɜːrld ] 영국식 [ wɜːld ]"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    lazy var meaningLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 명사 세계"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "mainBtn")
        setupViews()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupViews() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.left.equalTo(view).offset(16)
            
        }
        view.addSubview(wordLabel)
        wordLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.leading.equalToSuperview().offset(20)
        }
        view.addSubview(pronunciationLabel)
        pronunciationLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(120)
        }
        view.addSubview(meaningLabel)
        meaningLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(127)
            make.leading.equalToSuperview().offset(20)
        }
    }
}

