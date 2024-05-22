//
//  MyPageVC.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/17/24.
//

import UIKit
import SnapKit

class MyPageVC: UIViewController {
    
    // 좌상단 타이틀 : string만 변경해서 공통 사용
    lazy var topLabel = LabelFactory().makeLabel(text: "WordWideWeb")
    // 좌상단 로고 : 공통 사용
    lazy var topLogo = ImageFactory().makeImage()
    // 우하단 버튼 : 공통 사용
    
    lazy var addWordBookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .pointGreen
        button.backgroundColor = UIColor(named: "mainBtn")
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowRadius = 10
        return button
    }()

    
    // 단어장 카드 collectionView
    var collection: UICollectionView = {
        let layout = CarouselLayout()
        
        layout.itemSize = CGSize(width: 297, height: 450)
        layout.sideItemScale = 175/251
        layout.spacing = -175
        layout.isPagingEnabled = true
        layout.sideItemAlpha = 0.5
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
     //  view.showsHorizontalScrollIndicator = false  // 자동으로 horizontal인것을 꺼주기
        
        view.backgroundColor = UIColor(named: "bgColor")
        view.register(MyPageCollectionViewCell.self, forCellWithReuseIdentifier: "MyPageCollectionViewCell")
        return view
    }()
    
    // 홈 화면 단어 카드에 들어가는 정보 Array
    var myPageList = [MyPage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor")
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupViews()
        collecctionSetup()
        
        //더미 데이터 생성
        makeDummy(count: 5)
        
        addWordBookButton.addTarget(self, action: #selector(addWordBookButtonTapped), for: .touchUpInside)
        
      
        }
    @objc private func addWordBookButtonTapped() {
        let addWordBookVC = AddWordBookVC()
        addWordBookVC.modalPresentationStyle = .formSheet
        present(addWordBookVC, animated: true, completion: nil)
    }
    
    

    func makeDummy(count: Int) {
        for _ in 0...count-1 {
            let dummy = MyPage(word: ["let"], title: "개발자 필수 영단어", name: "jiyeon", image: "cross")
            myPageList.append(dummy)
        }
    }
    
    func setupViews() {
        view.addSubview(topLabel)
        view.addSubview(topLogo)
        view.addSubview(addWordBookButton)
        view.addSubview(collection)
  
        topLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(63)
        }
        
        topLogo.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(62)
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalTo(topLabel.snp.leading).offset(-2)
            make.bottom.equalToSuperview().offset(-745)
        }
        
        addWordBookButton.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.trailing.equalTo(view).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        collection.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(130)
            make.leading.equalToSuperview().offset(45)
            make.trailing.equalToSuperview().offset(-45)
            make.bottom.equalToSuperview().offset(-190)
        }
    }
}

