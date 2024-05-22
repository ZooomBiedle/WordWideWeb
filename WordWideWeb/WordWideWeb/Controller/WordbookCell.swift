//
//  WordbookCell.swift
//  WordWideWeb
//
//  Created by David Jang on 5/20/24.
//

import UIKit

class WordbookCell: UICollectionViewCell {
    
    // UI elements
    private let titleLabel = UILabel()
    private let wordCountLabel = UILabel()
    private let trashButton = UIButton(type: .system)
    
    
    var onDelete: (() -> Void)?
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // Setup views
    private func setupViews() {
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        titleLabel.font = UIFont.pretendard(size: 18, weight: .regular)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        
        wordCountLabel.font = UIFont.pretendard(size: 48, weight: .heavy)
        wordCountLabel.textColor = .black
        contentView.addSubview(wordCountLabel)
        
        trashButton.setImage(UIImage(systemName: "trash"), for: .normal)
        trashButton.tintColor = .black
        trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
        contentView.addSubview(trashButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
        }
        
        wordCountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(contentView).offset(16)
            make.bottom.equalTo(contentView).offset(-16)
//            make.trailing.equalTo(contentView).offset(-8)
        }
        
        trashButton.snp.makeConstraints { make in
            make.bottom.equalTo(contentView).offset(-16)
            make.trailing.equalTo(contentView).offset(-16)
            make.width.height.equalTo(20)
        }
    }
    
    @objc private func trashButtonTapped() {
        onDelete?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        wordCountLabel.text = nil
        contentView.backgroundColor = nil
        trashButton.isHidden = true
    }
    
    // Configure cell
    func configure(with wordbook: Wordbook) {
        titleLabel.text = wordbook.title
        wordCountLabel.text = "\(wordbook.wordCount)"
        contentView.backgroundColor = UIColor(hex: wordbook.colorCover)
        
        trashButton.isHidden = wordbook.isPublic
    }
}


