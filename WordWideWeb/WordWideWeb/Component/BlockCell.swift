//
//  BlockCell.swift
//  WordWideWeb
//
//  Created by 신지연 on 2024/05/16.
//
import UIKit
import SnapKit

import UIKit

class BlockCell: UICollectionViewCell {
    static let identifier = "BlockCell"
    
    let term: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 14, weight: .regular)
        label.textColor = .black
        label.backgroundColor = .white
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(term)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        
        term.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(text: String) {
        term.text = text
    }
}
