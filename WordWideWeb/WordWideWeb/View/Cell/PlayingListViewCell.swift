//
//  PlayingListViewCell.swift
//  WordWideWeb
//
//  Created by 신지연 on 2024/05/21.
//

import UIKit
import FirebaseAuth

class PlayingListViewCell: UITableViewCell {
    
    private var height = 80
    private var cellCount = 1
    var wordList: [String] = ["a"]
    var listview = ListViewCell()
    var nowPplNum = 5
    var pplNum = 100
    var wordbookId = ""

    private let wordViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        return layout
    }()
    
    lazy var wordView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: wordViewFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    var pplImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "person.2")
        view.tintColor = .black
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var pplLabel: UILabel = {
        let view = UILabel()
        view.text = "\(nowPplNum)  /  \(pplNum)"
        view.font = UIFont.pretendard(size: 16, weight: .regular)
        return view
    }()
    
    var joinButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Join", for: .normal)
        btn.titleLabel?.font = .pretendard(size: 16, weight: .regular)
        btn.titleLabel?.textColor = .white
        btn.backgroundColor = UIColor(named: "mainBtn")
        btn.layer.cornerRadius = 6
        return btn
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        wordView.register(BlockCell.self, forCellWithReuseIdentifier: "BlockCell")
        self.customComponent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            setSelectedUI()
            updatePplLabel()
        } else {
            setUnselectedUI()
        }
    }
    
    private func updatePplLabel() {
        pplLabel.text = "\(nowPplNum) / \(pplNum)"
    }
    
    private func customComponent(){
        listview.imageLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.width.equalTo(50)
            make.leading.equalToSuperview().offset(20)
        }
        listview.titleLabel.snp.makeConstraints { make in
            make.width.equalTo(170)
        }
        listview.dateLabel.snp.makeConstraints { make in
            make.width.equalTo(80)
        }
        listview.imageLabel.backgroundColor = .gray
        listview.dateLabel.text = "2024,01.01 PM 7:00"
        listview.titleLabel.text = "제목"
    }
    
    private func setUI(){
        self.backgroundColor = .clear
        
        self.contentView.addSubview(listview)
        listview.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
            make.width.equalToSuperview()
        }
        
        listview.imageLabel.layer.cornerRadius = 25
    }

    private func setSelectedUI(){
        self.backgroundColor = .clear
        if wordList.count != 0 {
            self.contentView.addSubview(wordView)
            wordView.snp.makeConstraints { make in
                make.top.equalTo(listview.snp.bottom).offset(5)
                make.height.equalTo(30)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
            }
        }
        
        self.contentView.addSubview(joinButton)
        joinButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(30)
            make.width.equalTo(150)
            make.trailing.equalToSuperview().offset(-30)
        }
        
        self.contentView.addSubview(pplImageView)
        pplImageView.snp.makeConstraints { make in
            //make.top.equalToSuperview().offset(40)
            make.centerY.equalTo(joinButton.snp.centerY)
            make.height.width.equalTo(25)
            make.leading.equalToSuperview().offset(60)
        }
        
        self.contentView.addSubview(pplLabel)
        pplLabel.snp.makeConstraints { make in
            //make.top.equalTo(wordView.snp.bottom).offset(10)
            make.centerY.equalTo(joinButton.snp.centerY)
            make.leading.equalTo(pplImageView.snp.trailing).offset(10)
        }
    }
    
    private func setUnselectedUI(){
        wordView.removeFromSuperview()
        joinButton.removeFromSuperview()
        pplImageView.removeFromSuperview()
        pplLabel.removeFromSuperview()
    }
    
}
extension PlayingListViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var words = Array(wordList.prefix(cellCount)).joined(separator: " ")
        let wordsfont = UIFont.systemFont(ofSize: 14)
        var wordsWidth = words.size(withAttributes: [NSAttributedString.Key.font: wordsfont]).width
        
        while wordsWidth < 300 && cellCount < wordList.count{
            self.cellCount += 1
            words = Array(wordList.prefix(cellCount)).joined(separator: " ")
            wordsWidth = words.size(withAttributes: [NSAttributedString.Key.font: wordsfont]).width + 20 + CGFloat(20 * (cellCount - 1))
        }
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlockCell", for: indexPath) as! BlockCell
        cell.bind(text: wordList[indexPath.row])
        cell.term.font = UIFont.pretendard(size: 14, weight: .semibold)
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = wordList[indexPath.row]
        let font = UIFont.systemFont(ofSize: 14)
        let textWidth = text.size(withAttributes: [NSAttributedString.Key.font: font]).width
        let cellWidth = textWidth + 20
        return CGSize(width: cellWidth, height: 28)
    }
    
}
