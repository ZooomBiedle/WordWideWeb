//
//  TestView.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/20/24.
//

import Foundation
import SnapKit
import UIKit

class TestView: UIView {
    
    // MARK: - properties
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let topImageLabel: UIImageView = {
        let label = UIImageView()
        label.image = UIImage(systemName: "globe.asia.australia.fill")
        label.contentMode = .scaleAspectFit
        label.tintColor = .black
        return label
    }()
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 20, weight: .semibold)
        label.text = "Test"
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    lazy var friendView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayoutForFriend())
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.contentInset = .zero
        view.clipsToBounds = true
        view.alwaysBounceHorizontal = false
        view.alwaysBounceVertical = false
        return view
    }()
    
    lazy var questionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = .white
        return view
    }()
    
    let nextBtn: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(UIImage(systemName: "greaterthan"), for: .normal)
        return button
    }()
    
    let beforeBtn: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(UIImage(systemName: "lessthan"), for: .normal)
        return button
    }()
    
    private lazy var pageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentPageLabel, totalPageLabel])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var currentPageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 17, weight: .regular)
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    let totalPageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 17, weight: .regular)
        label.text = " of 6"
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private let timeImageView: UIImageView = {
        let label = UIImageView()
        label.image = UIImage(systemName: "clock")
        label.tintColor = .black
        label.contentMode = .scaleToFill
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 17, weight: .regular)
        //label.text = "00:27"
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private let quizLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 18, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 5
        return label
    }()
    
    private lazy var answerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [answerLabel, submitBtn])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let answerLabel: UITextField = {
        let label = UITextField()
        label.font = UIFont.pretendard(size: 17, weight: .regular)
        label.layer.cornerRadius = 10
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.pointGreen.cgColor
        label.textColor = .black
        label.placeholder = "write the answer"
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.image = UIImage(named: "pencil")
        imageView.tintColor = .pointGreen
        
        label.addLeftPadding()
        return label
    }()
    
    let submitBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainBtn
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.tintColor = .white
        button.setTitle("Submit", for: .normal)
        return button
    }()

    // MARK: - methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLayoutForFriend() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
                                                            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60.0), heightDimension: .absolute(60.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(60.0), heightDimension: .absolute(60.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            //let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(30.0)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 20.0
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30)
            
            return section
        }
        return layout
    }
    
    func bindQ(page: Int, definition: String){
        currentPageLabel.text = String(page)
        quizLabel.text = definition
    }

    private func setUI(){
        self.backgroundColor = .bg
        self.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }
        
        self.topView.addSubview(topImageLabel)
        topImageLabel.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(20)
            make.height.width.equalTo(28)
        }
        
        self.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(topImageLabel.snp.trailing).offset(3)
            make.height.equalTo(28)
            make.width.equalTo(100)
        }
        
        self.addSubview(friendView)
        friendView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalToSuperview()
        }
        
        self.addSubview(questionView)
        questionView.snp.makeConstraints { make in
            make.top.equalTo(friendView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(400)
            make.width.equalTo(310)
        }
        
        self.questionView.addSubview(pageStackView)
        pageStackView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(20)
        }
 
        self.questionView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        self.questionView.addSubview(timeImageView)
        timeImageView.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel.snp.centerY)
            make.trailing.equalTo(timeLabel.snp.leading).offset(-5)
            make.height.equalTo(timeLabel.snp.height)
            make.width.equalTo(timeLabel.snp.height)
        }
        
        self.questionView.addSubview(quizLabel)
        quizLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(120)
            make.width.equalTo(260)
        }
        
        self.questionView.addSubview(answerStackView)
        answerStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(260)
            make.height.equalTo(130)
        }
        
        self.addSubview(nextBtn)
        nextBtn.snp.makeConstraints { make in
            make.centerY.equalTo(questionView.snp.centerY)
            make.leading.equalTo(questionView.snp.trailing).offset(5)
        }
        
        self.addSubview(beforeBtn)
        beforeBtn.snp.makeConstraints { make in
            make.centerY.equalTo(questionView.snp.centerY)
            make.trailing.equalTo(questionView.snp.leading).offset(-5)
        }
    }
}
