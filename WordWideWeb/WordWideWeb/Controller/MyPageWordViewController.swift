//
//  MyPageWordViewController.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import UIKit
import SnapKit

// 단어카드 다음페이지 : 단어 리스트 페이지
class MyPageWordViewController: UIViewController, UIViewControllerTransitioningDelegate {

    var bookID: String = ""
    var wordsList: [Word] = []
    
    private let wordViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 30
        return layout
    }()
    
    lazy var wordsCollecView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: wordViewFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor")
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    private func fetchData() {
        Task {
            do {
                let words = try await FirestoreManager.shared.fetchWords(for: bookID)
                self.wordsList.removeAll()
                self.wordsList.append(contentsOf: words)
                wordsCollecView.reloadData()
            } catch {
                print("Error fetching words")
            }
        }
    }
    
    private func setCollectionView() {
        wordsCollecView.register(BlockCell.self, forCellWithReuseIdentifier: "BlockCell")

        self.view.addSubview(wordsCollecView)
        wordsCollecView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(100)
            make.horizontalEdges.equalToSuperview().inset(25)
            make.bottom.equalToSuperview()
        }
    }
}

extension MyPageWordViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlockCell", for: indexPath) as! BlockCell
        let text = wordsList[indexPath.item].term
        cell.bind(text: text)   // 내가 클릭한 단어장의 단어 불러와야
        cell.term.font = UIFont.pretendard(size: 14, weight: .semibold)
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = wordsList[indexPath.item].term
        let font = UIFont.systemFont(ofSize: 14)
        let textWidth = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width
        let cellWidth = textWidth + 20
        return CGSize(width: cellWidth, height: 28)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlockCell", for: indexPath) as! BlockCell
        cell.backgroundColor = .black
        cell.term.textColor = .white
        
        let myPageModalVC = MyPageModalViewController()
        let text = wordsList[indexPath.item].term
    
        myPageModalVC.term = text
        myPageModalVC.modalPresentationStyle = .formSheet
        if let sheet = myPageModalVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        self.present(myPageModalVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BlockCell else { return }
        cell.backgroundColor = .white
        cell.term.textColor = .black
    }
    
}
                
