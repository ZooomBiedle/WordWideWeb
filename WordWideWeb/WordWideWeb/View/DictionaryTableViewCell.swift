//
//  DictionaryTableViewCell.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/17/24.
//

import UIKit
import SnapKit

class DictionaryTableViewCell: UITableViewCell {
    
    static let identifier = "DictionaryTableViewCell"
    
    var wordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 16, weight: .semibold)
        return label
    }()
    
    let addButton: UIButton = {
        let image = UIImage(systemName: "plus.circle.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let highlightedImage = UIImage(systemName: "minus.circle.fill")?.withTintColor(UIColor(red: 244/255, green: 179/255, blue: 179/255, alpha: 1.0), renderingMode: .alwaysOriginal)
        
        let btn = UIButton(type: .custom)
        btn.setImage(image, for: .normal)
        btn.setImage(highlightedImage, for: .highlighted)
        btn.clipsToBounds = true
        return btn
    }()
    
    let stackview: UIStackView = {
        let stv = UIStackView()
        stv.axis = .vertical
        return stv
    }()
    
    var addButtonAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor(named: "bgColor")
        setConstraints()
        setAddButton(addButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addButton.layer.cornerRadius = addButton.frame.size.height / 2
    }
    
    func setConstraints() {
        [wordLabel, addButton, stackview].forEach {
            contentView.addSubview($0)
        }
        
        wordLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(wordLabel)
            make.height.equalTo(wordLabel)
            make.width.equalTo(wordLabel.snp.height)
            make.trailing.equalToSuperview().inset(20)
        }
        
        stackview.snp.makeConstraints { make in
            make.top.equalTo(wordLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        wordLabel.text = nil
        // StackView의 모든 하위 뷰 제거
        for subview in stackview.arrangedSubviews {
            stackview.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
    
    // MARK: - translated word가 쌓이는 stacview 만들기
    func setStackView(item: Item) {
        item.sense.forEach { senseElement in
            let label = UILabel()
            label.numberOfLines = 0
            label.text = "\(senseElement.senseOrder). \(item.pos)  \(senseElement.transWord)"
            
            stackview.addArrangedSubview(label)
        }
    }
    
    // MARK: - addButton
    func setAddButton(_ button: UIButton) {
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addButtonTapped() {
        addButtonAction?()
    }
}


