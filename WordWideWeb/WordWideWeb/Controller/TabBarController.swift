//
//  TabBarController.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/17/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarItems()
        NotificationCenter.default.addObserver(self, selector: #selector(showPage(_:)), name: NSNotification.Name("showPage"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            // Adjust the height of the tab bar
            var tabFrame = self.tabBar.frame
            tabFrame.size.height = 90 // 원하는 높이로 설정
            tabFrame.origin.y = self.view.frame.size.height - 90 // 탭바가 화면 하단에 위치하도록 조정
            self.tabBar.frame = tabFrame
        }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("showPage"), object: nil)
    }
    
    @objc func showPage(_ notification:Notification) {
        guard let userInfo = notification.userInfo, let wordbook = userInfo["wordbook"] as? Wordbook else { return }
        
        let testIntroViewController = TestIntroViewController()
        testIntroViewController.modalPresentationStyle = .fullScreen
        testIntroViewController.testWordBook = wordbook
        self.present(testIntroViewController, animated: true)
        
    }
  
    private func setupTabBarItems() {
        let mypageVC = MyPageVC()
        mypageVC.tabBarItem.image = UIImage(systemName: "house.circle")
        //mypageVC.tabBarItem.selectedImage = UIImage(named: "globe.fill")
        mypageVC.tabBarItem.imageInsets = UIEdgeInsets(top: -10, left: 20, bottom: 10, right: -20)
        
        let playingListVC = PlayingListVC()
        playingListVC.tabBarItem.image = UIImage(systemName: "magnifyingglass.circle")
        playingListVC.tabBarItem.imageInsets = UIEdgeInsets(top: -10, left: 20, bottom: 10, right: -20)
        
        let dictionaryVC = DictionaryVC()
        dictionaryVC.tabBarItem.image = UIImage(systemName: "plus.circle")
        dictionaryVC.tabBarItem.imageInsets = UIEdgeInsets(top: -10, left: 0, bottom: 10, right: 0)
        
        let invitingVC = InvitingVC()
        invitingVC.tabBarItem.image = UIImage(systemName: "envelope.circle")
        invitingVC.tabBarItem.imageInsets = UIEdgeInsets(top: -10, left: -20, bottom: 10, right: 20)
        
        let myInfoVC = MyInfoVC()
        myInfoVC.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        myInfoVC.tabBarItem.imageInsets = UIEdgeInsets(top: -10, left: -20, bottom: 10, right: 20)
        
        self.tabBar.items?.forEach {
            $0.imageInsets = UIEdgeInsets(top: 15, left: 0, bottom: -15, right: 0)
        }
        
        self.viewControllers = [mypageVC, playingListVC, dictionaryVC, invitingVC, myInfoVC]
        self.tabBar.items?.forEach({ $0.title = nil })
        self.tabBar.backgroundColor = .white
        tabBar.tintColor = .mainBtn
        tabBar.unselectedItemTintColor = .lightGray
        tabBar.layer.cornerRadius = 34
        tabBar.itemPositioning = .centered
        self.selectedIndex = 0
    }
    
}

