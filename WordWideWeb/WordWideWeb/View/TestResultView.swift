//
//  TestResultView.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/20/24.
//

import UIKit
import SnapKit

class TestResultView: UIView {
    
    // MARK: - properties
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
    
    private let bodyView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let resultimageLabel: UIImageView = {
        let label = UIImageView()
        label.image = UIImage.smileFace
        label.tintColor = .black
        label.contentMode = .scaleToFill
        return label
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 20, weight: .heavy)
        label.text = "Congratulations"
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var testResStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [quizStackView, rightStackView, wrongStackView])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var quizStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [quizNumLabel, quizLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    var quizNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 20, weight: .heavy)
        label.text = "10"
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private let quizLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 20, weight: .heavy)
        label.text = "quizs"
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var rightStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [rightNumLabel, rightLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private var rightNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 20, weight: .heavy)
        label.text = "10"
        label.textColor = .blue
        label.numberOfLines = 1
        return label
    }()
    
    private let rightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 20, weight: .heavy)
        label.text = "right"
        label.textColor = .blue
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var wrongStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [wrongNumLabel, wrongLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private var wrongNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 20, weight: .heavy)
        label.text = "10"
        label.textColor = .red
        label.numberOfLines = 1
        return label
    }()
    
    private let wrongLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 20, weight: .heavy)
        label.text = "wrong"
        label.textColor = .red
        label.numberOfLines = 1
        return label
    }()
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        return layout
    }()
    
    private let wrongword: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 16, weight: .semibold)
        label.text = "Wrong words"
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    lazy var wrongwordLabel: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let footerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let okBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainBtn
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.tintColor = .white
        button.setTitle("OK", for: .normal)
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
    
    private func setUI(){
        self.backgroundColor = .bg
        
        self.addSubview(topImageLabel)
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
        
        self.addSubview(bodyView)
        bodyView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(440)
            make.width.equalTo(310)
        }
        
        self.bodyView.addSubview(resultimageLabel)
        resultimageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
            make.height.width.equalTo(100)
        }
        
        self.bodyView.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(resultimageLabel.snp.bottom).offset(20)
        }
        
        self.bodyView.addSubview(testResStackView)
        testResStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(resultLabel.snp.bottom).offset(40)
            make.width.equalToSuperview().offset(-30)
            make.height.equalTo(100)
        }
        
        self.bodyView.addSubview(wrongword)
        wrongword.snp.makeConstraints { make in
            make.top.equalTo(testResStackView.snp.bottom).offset(20)
            make.leading.equalTo(testResStackView.snp.leading).offset(10)
            make.height.equalTo(30)
        }
        
        self.bodyView.addSubview(wrongwordLabel)
        wrongwordLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(wrongword.snp.bottom).offset(5)
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(30)
        }
        
        self.addSubview(okBtn)
        okBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
            make.width.equalTo(343)
            make.height.equalTo(53)
        }
    }
    
    func bind(quizNum: Int, rightNum: Int, wrongNum: Int){
        quizNumLabel.text = String(quizNum)
        rightNumLabel.text = String(rightNum)
        wrongNumLabel.text = String(wrongNum)
    }
}
