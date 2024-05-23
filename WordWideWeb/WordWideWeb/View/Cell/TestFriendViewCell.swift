//
//  TestFriendViewCell.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/20/24.
//

import UIKit

class TestFriendViewCell: UICollectionViewCell {
    
    let friendImage: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.backgroundColor = .systemGray2
        image.layer.cornerRadius = 30
        return image
    }()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setUI(){
        self.contentView.addSubview(friendImage)
        friendImage.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
    }
    
    private func bind(imageData: Data?){
        if let image = imageData {
            friendImage.image = UIImage(data: image)
        }
    }
}

