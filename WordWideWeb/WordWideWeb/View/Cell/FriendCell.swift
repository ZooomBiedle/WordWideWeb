//
//  FriendCell.swift
//  WordWideWeb
//
//  Created by David Jang on 5/17/24.
//

import UIKit
import SDWebImage
import SnapKit

class FriendCell: UITableViewCell {
    
    static let identifier = "FriendCell"
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let cellBottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(selectButton)
        contentView.addSubview(cellBottomLine)
        
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(32)
            make.centerY.equalToSuperview()
        }
        
        selectButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        cellBottomLine.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func configure(with user: User) {
        nameLabel.text = user.displayName
        if let photoURL = URL(string: user.photoURL ?? ""), !user.photoURL!.isEmpty {
            profileImageView.sd_setImage(with: photoURL, completed: nil)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
        }
    }
}

