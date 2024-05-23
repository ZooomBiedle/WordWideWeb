//
//  TestIntroView.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/20/24.
//

import Foundation
import SnapKit
import UIKit

class TestIntroView: UIView {
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 32, weight: .heavy)
        label.text = "titletitletitle"
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var testInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [quizStackView, timeStackView])
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
    
    private let quizNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 20, weight: .heavy)
        label.text = "50"
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
    
    private lazy var timeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timeNumLabel, timeLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let timeNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 20, weight: .heavy)
        label.text = "00:30:00"
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(size: 20, weight: .heavy)
        label.text = "time"
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private let footerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let startBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainBtn
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.tintColor = .white
        button.setTitle("Start", for: .normal)
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
            make.top.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(20)
            make.height.width.equalTo(28)
        }
        
        self.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.leading.equalTo(topImageLabel.snp.trailing).offset(12)
            make.height.equalTo(28)
            make.width.equalTo(100)
        }
        
        self.addSubview(bodyView)
        bodyView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(440)
            make.width.equalTo(310)
        }
        
        self.bodyView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(70)
            make.width.equalTo(240)
            make.height.equalTo(100)
        }
        
        self.bodyView.addSubview(testInfoStackView)
        testInfoStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(80)
            make.width.equalTo(240)
            make.height.equalTo(100)
        }
        
        self.addSubview(startBtn)
        startBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
            make.width.equalTo(343)
            make.height.equalTo(53)
        }
    }
    
    func bind(title: String, blockCount: Int) {
        self.titleLabel.text = title
        self.quizNumLabel.text = String(blockCount)
        
        //1문제당 10초
        var dateComponents = DateComponents()
        dateComponents.minute = 0
        dateComponents.second = blockCount * 10
        
        let userCalendar = Calendar.current
        if let specificDate = userCalendar.date(from: dateComponents) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "mm:ss"
            let timeString = dateFormatter.string(from: specificDate)
            self.timeNumLabel.text = timeString
        } else {
            print("날짜를 생성할 수 없다.")
        }
    }
}
