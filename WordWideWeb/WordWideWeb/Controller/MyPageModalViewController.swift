//
//  MyPageModelViewController.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import UIKit
import SnapKit

class MyPageModalViewController: UIViewController {

    var term: String = ""
  
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    lazy var wordLabel: UILabel = {
        let label = UILabel()
        label.text = term
        label.textColor = .white
        label.font = UIFont.pretendard(size: 32, weight: .semibold)
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    lazy var stackview: UIStackView = {
        let stv = UIStackView()
        stv.axis = .vertical
        stv.spacing = 0
        return stv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "mainBtn")
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        NetworkManager.shared.fetchAPIExactWord(query: term) { item in
            self.setStackView(item: item)
        }
        setupViews()
        
        closeButton.addTarget(self, action: #selector(returnWord), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .modalDismissed, object: nil)
    }
    
    @objc func returnWord() {
        self.dismiss(animated: true)
    }
    
    func setupViews() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.height.equalTo(closeButton.snp.width).multipliedBy(1 / 1)
            
        }
        view.addSubview(wordLabel)
        wordLabel.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(48)
        }

        view.addSubview(stackview)
        stackview.snp.makeConstraints { make in
            make.top.equalTo(wordLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            //make.bottom.greaterThanOrEqualTo(view.safeAreaLayoutGuide).inset(70)
        }
    }

    private func setStackView(item: Item) {
        item.sense.forEach { senseElement in
            let label = UILabel()
            label.numberOfLines = 1
            label.text = "\(senseElement.senseOrder). \(item.pos)  \(senseElement.transWord)"
            label.textAlignment = .left
            label.textColor = .white
            
            stackview.addArrangedSubview(label)
            print("label: ", stackview)
        }
    }
    
}

