//
//  DefaultTableViewCell.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import UIKit
import SDWebImage

class DefaultTableViewCell: UITableViewCell {
    
    static let identifier = "DefaultTableViewCell"
    
    var profileImageView = UIImageView()

    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 16, weight: .semibold)
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 14, weight: .regular)
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(named: "bgColor")
        contentView.addSubview(profileImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConstraints() {
    
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(60)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
            profileImageView.layer.cornerRadius = 30
            profileImageView.clipsToBounds = true
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(20)
            make.centerY.equalTo(profileImageView.snp.centerY)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(profileImageView.snp.centerY)
        }
    }
    
    func configure(title: String, date: String, imageURL: URL?) {
        titleLabel.text = title
        dateLabel.text = date.replacingOccurrences(of: " ", with: "\n")
        profileImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(systemName: "person.circle"))
    }
}


