//
//  MyPageCollectionViewCell.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import UIKit
import SnapKit
import SDWebImage


class MyPageCollectionViewCell: UICollectionViewCell {
    
    private lazy var coverView: UIView = {
        let bgView = UIView()
        bgView.layer.cornerRadius = 20
        bgView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return bgView
    }()
    
    private lazy var whiteView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 20
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        return bgView
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [coverView, whiteView])
        stackView.axis = .vertical
        return stackView
    }()

    
    lazy var wordButton: UIButton = {
        let button = UIButton()
        button.setTitle("word", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.setTitleColor(.black, for: .normal)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
       // button.addTarget(self, action: #selector(modalPageTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.pretendard(size: 24, weight: .semibold)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.pretendard(size: 14, weight: .semibold)
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var profileImage: UIImageView = {
        let profileImage = UIImageView()
        profileImage.backgroundColor = .black
        profileImage.layer.cornerRadius = 13
        profileImage.clipsToBounds = true
        return profileImage
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        self.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        coverView.snp.makeConstraints { make in
            make.height.equalTo(vStackView.snp.height).multipliedBy(0.6)
        }
        
        whiteView.snp.makeConstraints { make in
            make.height.equalTo(vStackView.snp.height).multipliedBy(0.4)
        }

        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(290)
            make.leading.equalToSuperview().offset(20)
        }

        self.addSubview(profileImage) // 위치 + "크기"
        profileImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(333)
            make.leading.equalToSuperview().offset(20)
            make.height.width.equalTo(26)
        }
        
        self.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImage.snp.centerY)
            //make.top.equalToSuperview().offset(335)
            make.leading.equalToSuperview().offset(55)
        }
    }
    
    func configure(with wordbook: Wordbook, user: User) {
        titleLabel.text = wordbook.title
        nameLabel.text = user.displayName
        if let photoURL = URL(string: user.photoURL ?? "") {
            profileImage.sd_setImage(with: photoURL, completed: nil)
        }
        coverView.backgroundColor = UIColor(hex: wordbook.colorCover)
    }
}
