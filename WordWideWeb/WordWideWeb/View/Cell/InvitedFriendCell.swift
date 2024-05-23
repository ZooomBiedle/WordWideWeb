//
//  InvitedFriendCell.swift
//  WordWideWeb
//
//  Created by David Jang on 5/21/24.
//

import UIKit
import SDWebImage

class InvitedFriendCell: UICollectionViewCell {
    
    static let identifier = "InvitedFriendCell"
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(60)
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with user: User) {
        if let photoURL = URL(string: user.photoURL ?? ""), !user.photoURL!.isEmpty {
            profileImageView.sd_setImage(with: photoURL, completed: nil)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
        }
    }
}
