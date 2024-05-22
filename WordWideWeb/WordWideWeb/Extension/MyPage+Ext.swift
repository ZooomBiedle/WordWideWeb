//
//  File.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import UIKit

extension MyPageVC: UICollectionViewDelegate, UICollectionViewDataSource
{
    // 컬렉션 뷰 설정 함수
    func collecctionSetup() {
        // 컬렉션 뷰의 delegate와 dataSource를 self로 설정
        collection.delegate = self
        collection.dataSource = self
    }
    
    // 컬렉션 뷰에 표시할 아이템 개수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // myPageList가 비어있는 경우
        if myPageList.isEmpty {
            collectionView.setEmptyMsg("현재 만들어진 단어장이 없습니다.")
            return 0
        } else {
            // 메시지 제거
            collectionView.restore()
            return myPageList.count
        }
    }
    // 컬렉션 뷰의 섹션 개수 반환
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 컬렉션 뷰 셀 구성 함수
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 재사용 가능한 셀 가져오기
        guard let cell = collection.dequeueReusableCell(withReuseIdentifier: "MyPageCollectionViewCell", for: indexPath) as? MyPageCollectionViewCell else { return UICollectionViewCell() }
        
        // myPageList에서 해당 인덱스의 아이템 가져오기
        let item = myPageList[indexPath.row]
        
     
        cell.wordButton.setTitle(item.word.joined(), for: .normal)  // 임시
        cell.titleLabel.text = item.title // 임시
        
        // 셀 반환
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let myPageWordVC = MyPageWordViewController()
        navigationController?.pushViewController(myPageWordVC, animated: true)
//        myPageWordVC.modalPresentationStyle = .fullScreen
//        self.present(myPageWordVC, animated: true)
    }
    
}



