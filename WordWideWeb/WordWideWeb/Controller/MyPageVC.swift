//
//  MyPageVC.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/17/24.
//

import UIKit
import SnapKit
import FirebaseAuth

class MyPageVC: UIViewController {
    
    // 좌상단 타이틀 : string만 변경해서 공통 사용
    lazy var topLabel = LabelFactory().makeLabel(text: "WWW")
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
        view.backgroundColor = UIColor(named: "bgColor")
        view.showsHorizontalScrollIndicator = false
        view.register(MyPageCollectionViewCell.self, forCellWithReuseIdentifier: "MyPageCollectionViewCell")
        return view
    }()
    
    var wordbookList = [(Wordbook, User)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor")
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupViews()
        collectionSetup()
        addWordBookButton.addTarget(self, action: #selector(addWordBookButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndSetWordbooks() // 뷰가 나타날 때마다 단어장 불러오기
    }
    
    @objc private func addWordBookButtonTapped() {
        let addWordBookVC = AddWordBookVC()
        addWordBookVC.modalPresentationStyle = .formSheet
        present(addWordBookVC, animated: true, completion: nil)
    }
    
    private func setupViews() {
        view.addSubview(topLabel)
        view.addSubview(topLogo)
        view.addSubview(addWordBookButton)
        view.addSubview(collection)
        
        topLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(60)
        }
        
        topLogo.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(20)
            make.centerY.equalTo(topLabel.snp.centerY)
            make.width.height.equalTo(28)
        }
        
        addWordBookButton.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.trailing.equalTo(view).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        collection.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(130)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-190)
        }
    }
    
    // 컬렉션 뷰 설정 함수
    func collectionSetup() {
        collection.delegate = self
        collection.dataSource = self
    }
    
    // 단어장 데이터 가져오기 및 설정
    func fetchAndSetWordbooks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Task {
            do {
                let wordbooks = try await FirestoreManager.shared.fetchFilteredSharedWordbooks(for: userId)
                
                self.wordbookList.removeAll()
                var wordbookSet = Set<String>()
                
                for wordbook in wordbooks {
                    if !wordbookSet.contains(wordbook.id), let user = try await FirestoreManager.shared.fetchUser(uid: wordbook.ownerId) {
                        wordbookSet.insert(wordbook.id)
                        self.wordbookList.append((wordbook, user))
                    }
                }
                
                self.collection.reloadData()
            } catch {
                print("Error fetching wordbooks: \(error)")
            }
        }
    }
}


extension MyPageVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordbookList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(withReuseIdentifier: "MyPageCollectionViewCell", for: indexPath) as? MyPageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let (wordbook, user) = wordbookList[indexPath.row]
        cell.configure(with: wordbook, user: user)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let myPageWordVC = MyPageWordViewController()
        myPageWordVC.bookID = wordbookList[indexPath.row].0.id
        present(myPageWordVC, animated: true, completion: nil)
    }
}
