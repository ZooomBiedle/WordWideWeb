//
//  ExpandableTableViewCell.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import UIKit
import SDWebImage

class ExpandableTableViewCell: UITableViewCell {
    
    static let identifier = "ExpandableTableViewCell"
    
    var profileImageView = UIImageView()
    var wordCollectionView: UICollectionView!
    
    var rejectButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Reject", for: .normal)
        btn.titleLabel?.font = .pretendard(size: 18, weight: .regular)
        btn.titleLabel?.textColor = .white
        btn.backgroundColor = UIColor(named: "pointRed")
        btn.layer.cornerRadius = 6
        return btn
    }()
    
    var acceptButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Accept", for: .normal)
        btn.titleLabel?.font = .pretendard(size: 18, weight: .regular)
        btn.titleLabel?.textColor = .white
        btn.backgroundColor = UIColor(named: "mainBtn")
        btn.layer.cornerRadius = 6
        return btn
    }()
    
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

    var rejectButtonAction: (() -> Void)?
    var acceptButtonAction: (() -> Void)?
    
    var isExpanded = false {
        didSet {
            toggleExpansion(isExpanded)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCollectionView()
        contentView.backgroundColor = UIColor(named: "bgColor")
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(wordCollectionView)
        contentView.addSubview(rejectButton)
        contentView.addSubview(acceptButton)
        
        setConstraints()
        
        rejectButton.addTarget(self, action: #selector(rejectButtonTapped), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        
        toggleExpansion(isExpanded)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        wordCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        wordCollectionView.register(BlockCell.self, forCellWithReuseIdentifier: BlockCell.identifier)
        wordCollectionView.dataSource = self
        wordCollectionView.delegate = self
        wordCollectionView.isHidden = true
        wordCollectionView.backgroundColor = .yellow
    }
    
    var words: [String] = [] {
        didSet {
            wordCollectionView.reloadData()
        }
    }
    
    func setConstraints() {
        
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(60)
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
        
        wordCollectionView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(0)
        }
        
        rejectButton.snp.makeConstraints { make in
            make.top.equalTo(wordCollectionView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(acceptButton.snp.leading).offset(-20)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(0)
        }
        
        acceptButton.snp.makeConstraints { make in
            make.top.equalTo(wordCollectionView.snp.bottom).offset(10)
            make.centerY.equalTo(rejectButton.snp.centerY)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(rejectButton.snp.width)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(0)
        }
    
    }
    
    func toggleExpansion(_ expand: Bool) {
        let wordCollectionHeight: CGFloat = expand ? 80 : 0
        let buttonHeight: CGFloat = expand ? 30 : 0
        
        wordCollectionView.snp.updateConstraints { make in
            make.height.equalTo(wordCollectionHeight)
        }
        
        rejectButton.snp.updateConstraints { make in
            make.height.equalTo(buttonHeight)
        }
        
        acceptButton.snp.updateConstraints { make in
            make.height.equalTo(buttonHeight)
        }
        
        wordCollectionView.isHidden = !expand
        rejectButton.isHidden = !expand
        acceptButton.isHidden = !expand
    }
    
    func bindExpandedView(words: [String]) {
        self.words = words
        wordCollectionView.reloadData()
        toggleExpansion(true)
    }

    func clearExpandedView() {
        toggleExpansion(false)
    }
    
    @objc func rejectButtonTapped() {
        rejectButtonAction?()
    }
    
    @objc func acceptButtonTapped() {
        acceptButtonAction?()
    }
    
    func configure(title: String, date: String, imageURL: URL?) {
        titleLabel.text = title
        dateLabel.text = date.replacingOccurrences(of: " ", with: "\n")
        profileImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(systemName: "person.circle"))
        wordCollectionView.isHidden = true
        rejectButton.isHidden = true
        acceptButton.isHidden = true
    }
}

extension ExpandableTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BlockCell.identifier, for: indexPath) as! BlockCell
        cell.bind(text: words[indexPath.row])
        cell.backgroundColor = .red
        return cell
    }
}

