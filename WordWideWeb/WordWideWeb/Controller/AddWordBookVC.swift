//
//  AddWordBookVC.swift
//  WordWideWeb
//
//  Created by David Jang on 5/20/24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class AddWordBookVC: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let coverColorLabel = UILabel()
    private let colorButtons: [UIButton] = {
        let colors = ["#E25337", "#EEDC64", "#344C26", "#D0CAAE", "#76AA51", "#6D5E15"]
        return colors.map { hex in
            let button = UIButton()
            button.backgroundColor = UIColor(hex: hex)
            button.layer.cornerRadius = 15
            button.layer.borderWidth = 4
            button.layer.borderColor = UIColor.clear.cgColor
            return button
        }
    }()
    
    private let titleLabel = UILabel()
    private let titleTextField = UITextField()
    private let setTimePeriodLabel = UILabel()
    private let timePeriodYesButton = RadioButton(title: "YES")
    private let timePeriodNoButton = RadioButton(title: "NO")
    private let deadlineLabel = UILabel()
    private let deadlineDatePicker = UIDatePicker()
    private let privateButton = RadioButton(title: "Private")
    private let publicButton = RadioButton(title: "Public")
    private let attendeesLabel = UILabel()
    private let attendeesStepper = UIStepper()
    private let attendeesCountLabel = UILabel()
    private let inviteLabel = UILabel()
    private let inviteButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let pushNotificationHelper = PushNotificationHelper.shared
    
    // State variables
    private var isUploading = false
    private var selectedColorButton: UIButton?
    private var selectedCoverColor: String?
    private var selectedAttendees: Int = 1
    
    private let invitedFriendsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(InvitedFriendCell.self, forCellWithReuseIdentifier: InvitedFriendCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private var invitedFriends: [User] = []
    private let maxAttendees = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor")
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    private func setupViews() {
        // UI elements initialization
        coverColorLabel.text = "Cover Color"
        coverColorLabel.font = UIFont.pretendard(size: 14, weight: .regular)
        
        titleLabel.text = "Title"
        titleLabel.font = UIFont.pretendard(size: 14, weight: .regular)
        
        titleTextField.placeholder = "Word Book Name"
        titleTextField.layer.cornerRadius = 10
        titleTextField.backgroundColor = UIColor.white
        titleTextField.setLeftPaddingPoints(10)
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor.systemGray.cgColor
        titleTextField.delegate = self
        
        setTimePeriodLabel.text = "Set Time Period"
        setTimePeriodLabel.font = UIFont.pretendard(size: 14, weight: .regular)
        
        deadlineLabel.text = "Deadline"
        deadlineLabel.font = UIFont.pretendard(size: 14, weight: .regular)
        deadlineDatePicker.datePickerMode = .dateAndTime
        deadlineDatePicker.preferredDatePickerStyle = .compact
        deadlineDatePicker.setValue(UIColor.black, forKey: "textColor")
        deadlineDatePicker.isEnabled = true
        
        attendeesLabel.text = "Attendees"
        attendeesLabel.font = UIFont.pretendard(size: 14, weight: .regular)
        
        attendeesStepper.minimumValue = 1
        attendeesStepper.maximumValue = Double(maxAttendees)
        attendeesStepper.value = 1
        attendeesStepper.isEnabled = false
        
        attendeesCountLabel.text = "1"
        attendeesCountLabel.font = UIFont.pretendard(size: 14, weight: .regular)
        
        inviteLabel.text = "Invite"
        inviteLabel.font = UIFont.pretendard(size: 14, weight: .regular)
        
        inviteButton.setImage(UIImage(systemName: "plus"), for: .normal)
        inviteButton.tintColor = .white
        inviteButton.backgroundColor = .white
        inviteButton.layer.cornerRadius = 30
        inviteButton.layer.shadowColor = UIColor.black.cgColor
        inviteButton.layer.shadowOpacity = 0.3
        inviteButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        inviteButton.layer.shadowRadius = 10
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = UIColor(named: "mainBtn")
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 10
        doneButton.isEnabled = false
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        
        invitedFriendsCollectionView.delegate = self
        invitedFriendsCollectionView.dataSource = self
        
        view.addSubview(coverColorLabel)
        colorButtons.forEach { view.addSubview($0) }
        view.addSubview(titleLabel)
        view.addSubview(titleTextField)
        view.addSubview(setTimePeriodLabel)
        view.addSubview(timePeriodYesButton)
        view.addSubview(timePeriodNoButton)
        view.addSubview(deadlineLabel)
        view.addSubview(deadlineDatePicker)
        view.addSubview(publicButton)
        view.addSubview(privateButton)
        view.addSubview(attendeesLabel)
        view.addSubview(attendeesStepper)
        view.addSubview(attendeesCountLabel)
        view.addSubview(inviteLabel)
        view.addSubview(inviteButton)
        view.addSubview(doneButton)
        view.addSubview(closeButton)
        view.addSubview(activityIndicator)
        view.addSubview(invitedFriendsCollectionView)
        
        setElementsState(isTimePeriodEnabled: false, isPublicEnabled: false)
    }
    
    private func setupConstraints() {
        coverColorLabel.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(24)
            make.leading.equalTo(view).offset(20)
        }
        
        for (index, button) in colorButtons.enumerated() {
            button.snp.makeConstraints { make in
                make.top.equalTo(coverColorLabel.snp.bottom).offset(16)
                make.leading.equalTo(view).offset(20 + index * 44)
                make.width.height.equalTo(30)
            }
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(colorButtons[0].snp.bottom).offset(24)
            make.leading.equalTo(view).offset(20)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(view).inset(20)
            make.height.equalTo(48)
        }
        
        setTimePeriodLabel.snp.makeConstraints { make in
            make.top.equalTo(attendeesLabel.snp.bottom).offset(36)
            make.leading.equalTo(view).offset(20)
        }
        
        timePeriodYesButton.snp.makeConstraints { make in
            make.leading.equalTo(publicButton.snp.leading)
            make.centerY.equalTo(setTimePeriodLabel)
        }
        
        timePeriodNoButton.snp.makeConstraints { make in
            make.leading.equalTo(privateButton.snp.leading)
            make.centerY.equalTo(setTimePeriodLabel)
        }
        
        deadlineLabel.snp.makeConstraints { make in
            make.top.equalTo(setTimePeriodLabel.snp.bottom).offset(36)
            make.leading.equalTo(view).offset(20)
        }
        
        deadlineDatePicker.snp.makeConstraints { make in
            make.leading.equalTo(timePeriodYesButton.snp.leading)
            make.centerY.equalTo(deadlineLabel)
        }
        
        publicButton.snp.makeConstraints { make in
            make.leading.equalTo(attendeesLabel.snp.trailing).offset(60)
            make.centerY.equalTo(attendeesLabel)
        }
        
        privateButton.snp.makeConstraints { make in
            make.leading.equalTo(publicButton.snp.trailing).offset(24)
            make.centerY.equalTo(attendeesLabel)
        }
        
        attendeesLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(36)
            make.leading.equalTo(view).offset(20)
        }
        
        attendeesStepper.snp.makeConstraints { make in
            make.centerY.equalTo(inviteLabel.snp.centerY)
            make.trailing.equalTo(view).offset(-24)
        }
        
        attendeesCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(attendeesStepper.snp.leading).offset(-36)
            make.centerY.equalTo(attendeesStepper)
        }
        
        inviteLabel.snp.makeConstraints { make in
            make.top.equalTo(deadlineLabel.snp.bottom).offset(36)
            make.leading.equalTo(view).offset(20)
        }
        
        inviteButton.snp.makeConstraints { make in
            make.top.equalTo(inviteLabel.snp.bottom).offset(16)
            make.leading.equalTo(view).offset(20)
            make.width.height.equalTo(60)
        }
        
        invitedFriendsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(inviteButton.snp.bottom).offset(16)
            make.leading.trailing.equalTo(view).inset(20)
            make.height.equalTo(70)
        }
        
        doneButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(52)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.left.equalTo(view).offset(20)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
    
    
    private func setupActions() {
        timePeriodYesButton.addTarget(self, action: #selector(timePeriodButtonTapped), for: .touchUpInside)
        timePeriodNoButton.addTarget(self, action: #selector(timePeriodButtonTapped), for: .touchUpInside)
        publicButton.addTarget(self, action: #selector(visibilityButtonTapped), for: .touchUpInside)
        privateButton.addTarget(self, action: #selector(visibilityButtonTapped), for: .touchUpInside)
        colorButtons.forEach { $0.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside) }
        inviteButton.addTarget(self, action: #selector(inviteTapped), for: .touchUpInside)
        attendeesStepper.addTarget(self, action: #selector(attendeesStepperChanged), for: .valueChanged)
        titleTextField.delegate = self
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside) // Ensure doneTapped is connected
        // Enable Done button when all required fields are filled
        titleTextField.addTarget(self, action: #selector(updateDoneButtonState), for: .editingChanged)
    }
    
    private func setElementsState(isTimePeriodEnabled: Bool, isPublicEnabled: Bool) {
        let enabledColor = UIColor.black
        let disabledColor = UIColor.lightGray
        
        deadlineLabel.textColor = isTimePeriodEnabled ? enabledColor : disabledColor
        deadlineDatePicker.isEnabled = isTimePeriodEnabled
        
        attendeesLabel.textColor = isPublicEnabled ? enabledColor : disabledColor
        attendeesStepper.isEnabled = isPublicEnabled
        attendeesCountLabel.text = "\(Int(attendeesStepper.value))"
        
        inviteLabel.textColor = isPublicEnabled ? enabledColor : disabledColor
        updateInviteButtonState()
        
        // 비공개 버튼을 비활성화하는 로직 추가
        privateButton.isEnabled = invitedFriends.isEmpty
        privateButton.alpha = invitedFriends.isEmpty ? 1.0 : 0.4
    }
    
    private func updateInvitedFriendsView() {
        invitedFriendsCollectionView.reloadData()
    }
    
    private func updateInviteButtonState() {
        let maxAttendees = Int(attendeesStepper.value)
        let currentAttendees = invitedFriends.count + 1 // 본인
        inviteButton.isEnabled = maxAttendees > currentAttendees
        inviteButton.backgroundColor = inviteButton.isEnabled ? UIColor(named: "pointGreen") : .lightGray
        inviteButton.alpha = inviteButton.isEnabled ? 1.0 : 0.4
        
        // 초대 이후 비공개버튼 비활성
        privateButton.isEnabled = invitedFriends.isEmpty
        privateButton.alpha = invitedFriends.isEmpty ? 1.0 : 0.4
    }
    
    @objc private func timePeriodButtonTapped(sender: RadioButton) {
        if sender == timePeriodYesButton {
            timePeriodYesButton.isSelected = true
            timePeriodNoButton.isSelected = false
            setElementsState(isTimePeriodEnabled: true, isPublicEnabled: publicButton.isSelected)
        } else if sender == timePeriodNoButton {
            timePeriodYesButton.isSelected = false
            timePeriodNoButton.isSelected = true
            setElementsState(isTimePeriodEnabled: false, isPublicEnabled: publicButton.isSelected)
        }
        updateDoneButtonState()
    }
    
    @objc private func visibilityButtonTapped(sender: RadioButton) {
        if sender == publicButton {
            publicButton.isSelected = true
            privateButton.isSelected = false
            setElementsState(isTimePeriodEnabled: timePeriodYesButton.isSelected, isPublicEnabled: true)
        } else if sender == privateButton {
            // 이미 초대한 참석자가 있을 경우 비공개로 전환할 수 없음
            if invitedFriends.isEmpty {
                publicButton.isSelected = false
                privateButton.isSelected = true
                setElementsState(isTimePeriodEnabled: timePeriodYesButton.isSelected, isPublicEnabled: false)
                attendeesStepper.value = 1
                attendeesCountLabel.text = "1"
                updateInviteButtonState()
            }
        }
        updateDoneButtonState()
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        selectedColorButton?.layer.borderColor = UIColor.clear.cgColor
        sender.layer.borderColor = UIColor.white.cgColor
        selectedColorButton = sender
        selectedCoverColor = sender.backgroundColor?.hexString
        updateDoneButtonState()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func inviteTapped() {
        let searchFriendsVC = SearchFriendsVC()
        searchFriendsVC.maxInvitesAllowed = Int(attendeesStepper.value)
        searchFriendsVC.selectedFriends = invitedFriends // 이미 초대한 친구들 전달
        searchFriendsVC.onFriendsSelected = { [weak self] selectedFriends in
            Task {
                do {
                    // 선택된 친구들의 정보를 Firestore에서 가져옴
                    let users = try await FirestoreManager.shared.fetchUsers(uids: selectedFriends.map { $0.uid })
                    DispatchQueue.main.async {
                        self?.invitedFriends = users
                        self?.updateInvitedFriendsView()
                        self?.updateInviteButtonState()
                    }
                } catch {
                    print("Error fetching users: \(error.localizedDescription)")
                }
            }
        }
        present(searchFriendsVC, animated: true, completion: nil)
    }
    
    @objc private func attendeesStepperChanged() {
        let maxAttendees = Int(attendeesStepper.value)
        let currentAttendees = invitedFriends.count + 1
        attendeesCountLabel.text = "\(maxAttendees)"
        
        inviteButton.isEnabled = maxAttendees > currentAttendees
        inviteButton.backgroundColor = inviteButton.isEnabled ? UIColor(named: "pointGreen") : .lightGray
        inviteButton.alpha = inviteButton.isEnabled ? 1.0 : 0.4
        
        // 비공개 버튼을 비활성화하는 로직 추가
        privateButton.isEnabled = invitedFriends.isEmpty
        privateButton.alpha = invitedFriends.isEmpty ? 1.0 : 0.4
    }
    
    @objc private func updateDoneButtonState() {
        let isFormFilled = !(titleTextField.text?.isEmpty ?? true) && (timePeriodYesButton.isSelected || timePeriodNoButton.isSelected) && (publicButton.isSelected || privateButton.isSelected)
        doneButton.isEnabled = isFormFilled
    }
    
    @objc private func doneTapped() {
        guard let title = titleTextField.text,
              let coverColor = selectedCoverColor,
              timePeriodYesButton.isSelected || timePeriodNoButton.isSelected,
              publicButton.isSelected || privateButton.isSelected else {
            return
        }
        
        let isPublic = publicButton.isSelected
        let dueDate: Timestamp? = timePeriodYesButton.isSelected ? Timestamp(date: deadlineDatePicker.date) : nil
        var attendees: [String] = [Auth.auth().currentUser!.uid]
        attendees.append(contentsOf: invitedFriends.map { $0.uid })
        
        let maxAttendees = Int(attendeesStepper.value)
        
        let id = UUID().uuidString
        
        let wordbook = Wordbook(
            id: id,
            ownerId: Auth.auth().currentUser!.uid,
            title: title,
            isPublic: isPublic,
            dueDate: dueDate,
            createdAt: Timestamp(date: Date()),
            attendees: attendees,
            sharedWith: isPublic ? [] : attendees,
            colorCover: coverColor,
            wordCount: 0,
            words: [],
            maxAttendees: maxAttendees
        )
        
        activityIndicator.startAnimating()
        
        guard let dueDateComponents = convertToDateComponents(from: dueDate) else { return  }
        pushNotificationHelper.pushNotification(test: title, time: dueDateComponents, identifier: "\(id)")
        
        Task {
            do {
                try await FirestoreManager.shared.createWordbook(wordbook: wordbook)
                print("Wordbook created successfully")
                
                // 초대장 전송
                for friend in invitedFriends {
                    try await FirestoreManager.shared.sendInvitation(
                        to: friend.uid,
                        wordbookId: wordbook.id,
                        title: title,
                        dueDate: dueDate
                    )
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.activityIndicator.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                }
            } catch {
                print("Error creating wordbook: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func convertToDateComponents(from timestamp: Timestamp?) -> DateComponents? {
        guard let timestamp = timestamp else { return nil }
        
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        return components
    }
    
    // MARK: z컬렉션뷰
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return invitedFriends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InvitedFriendCell.identifier, for: indexPath) as! InvitedFriendCell
        let friend = invitedFriends[indexPath.row]
        cell.configure(with: friend)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
}

private extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}


