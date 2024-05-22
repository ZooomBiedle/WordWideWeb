//
//  RadioButton.swift
//  WordWideWeb
//
//  Created by David Jang on 5/20/24.
//

import UIKit

class RadioButton: UIButton {

    private let circleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.backgroundColor = .clear
        return view
    }()
    
    private let checkmarkView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.sizeToFit()
        imageView.tintColor = .white
        imageView.isHidden = true
        return imageView
    }()
        
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
        setTitleColor(.black, for: .selected)
        titleLabel?.font = UIFont.pretendard(size: 14, weight: .regular)
        backgroundColor = .clear
        addSubview(circleView)
        addSubview(checkmarkView)
        
        circleView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.leading.centerY.equalToSuperview()
        }
        
        checkmarkView.snp.makeConstraints { make in
            make.center.equalTo(circleView)
        }
        
        titleLabel?.snp.makeConstraints { make in
            make.leading.equalTo(circleView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        
        snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        updateAppearance()
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapButton() {
        isSelected = !isSelected
        sendActions(for: .valueChanged)
    }
    
    private func updateAppearance() {
        if isSelected {
            circleView.layer.borderColor = UIColor.systemBlue.cgColor
            circleView.backgroundColor = UIColor(named: "pointGreen")
            checkmarkView.isHidden = false
        } else {
            circleView.layer.borderColor = UIColor.lightGray.cgColor
            circleView.backgroundColor = .clear
            checkmarkView.isHidden = true
        }
    }
}

