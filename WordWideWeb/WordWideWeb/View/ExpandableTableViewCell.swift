//
//  ExpandableTableViewCell.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import UIKit

class ExpandableTableViewCell: UITableViewCell {
    
    static let identfier = "ExpandableTableViewCell"
    
    var wordLabels: [UILabel] = []
    var labelStackview: UIStackView = {
        let stv = UIStackView()
        stv.axis = .horizontal
        stv.distribution = .equalSpacing
        stv.spacing = 16
        return stv
    }()
    
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
    
    var rejectButtonAction: (() -> Void) = {}
    var acceptButtonAction: (() -> Void) = {}
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor(named: "bgColor")
        setupLabels()
        setConstraints()
        rejectButton.addTarget(self, action: #selector(rejectButtonTapped), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabels() {
        for _ in 1...5 {
            let label = UILabel()
            label.backgroundColor = .white
            label.layer.cornerRadius = 8
            label.font = .pretendard(size: 12, weight: .regular)
            setWidth(label: label)
            wordLabels.append(label)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        rejectButtonAction = {}
        acceptButtonAction = {}
    }
    
    func setConstraints() {
        wordLabels.forEach { label in
            labelStackview.addArrangedSubview(label)
            label.snp.makeConstraints { make in
                make.height.equalTo(28)
            }
        }
        
        [labelStackview, rejectButton, acceptButton].forEach {
            contentView.addSubview($0)
        }
        
        labelStackview.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.greaterThanOrEqualToSuperview().inset(20)
        }
        
        rejectButton.snp.makeConstraints { make in
            make.top.equalTo(labelStackview.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(acceptButton.snp.leading).offset(-20)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(30)
        }
        
        acceptButton.snp.makeConstraints { make in
            make.top.equalTo(labelStackview.snp.bottom).offset(10)
            make.centerY.equalTo(rejectButton.snp.centerY)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(rejectButton.snp.width)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(30)
        }

    }
    
    func bindExpandedView(words: [String]) {
        for (label, word) in zip(wordLabels, words) {
            label.text = word
        }
    }
    
    @objc func rejectButtonTapped() {
        rejectButtonAction()
    }
    
    @objc func acceptButtonTapped() {
        acceptButtonAction()
    }
    
    private func setWidth(label: UILabel) {
        guard let text = label.text else { return }
        let font = UIFont.systemFont(ofSize: 14)
        let textWidth = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width
        let cellWidth = textWidth + 20
        label.frame.size =  CGSize(width: cellWidth, height: 28)
    }
}
