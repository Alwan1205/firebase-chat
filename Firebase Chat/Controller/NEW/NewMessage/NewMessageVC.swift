//
//  NewMessageVC.swift
//  Firebase Chat
//
//  Created by Admin on 2/3/22.
//

import UIKit

class NewMessageVC: UIViewController {

    public var selectedUser: User? = nil
    private var viewTap: UITapGestureRecognizer? = nil
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var chatViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var userProfilePictureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addViewTapGestureRecognizer()
        addKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeViewTapGestureRecognizer()
        removeKeyboardObservers()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseButtonTapped(_ sender: UIButton) {
        goToNewMessageChooseUserVC()
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        if !chatTextView.text.isEmpty {
            createChatRoomIfNeededAndSendChatMessage()
        }
    }
    
}

extension NewMessageVC {
    
    private func setupTextView() {
        chatTextView.delegate = self
        chatTextView.layer.borderWidth = 1
        chatTextView.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    public func setupSelectedUser() {
        if let user = selectedUser {
            userNameLabel.text = selectedUser?.name ?? ""
            userNameLabel.isHidden = false
            userIDLabel.text = "ID: \(selectedUser?.userID ?? "")"
            userIDLabel.isHidden = false
            userProfilePictureImageView.isHidden = false
        }
        else {
            userNameLabel.isHidden = true
            userIDLabel.isHidden = true
            userProfilePictureImageView.isHidden = true
        }
    }
    
    private func addViewTapGestureRecognizer() {
        removeViewTapGestureRecognizer()
        
        viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        
        if let viewTap = viewTap {
            view.addGestureRecognizer(viewTap)
        }
    }
    
    private func removeViewTapGestureRecognizer() {
        if let viewTap = viewTap {
            view.removeGestureRecognizer(viewTap)
            self.viewTap = nil
        }
    }
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: keyboardSize not found")
            return
        }
        
        if chatViewBottomConstraint.constant == 0 {
            var bottomSafeAreaHeight: CGFloat = 0
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.windows[0]
                let safeFrame = window.safeAreaLayoutGuide.layoutFrame
                bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
            }
            
            chatViewBottomConstraint.constant += keyboardSize.height - bottomSafeAreaHeight
        }
    }
    
    @objc private func keyboardWillHide() {
        if chatViewBottomConstraint.constant != 0 {
            chatViewBottomConstraint.constant = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func goToNewMessageChooseUserVC() {
        let storyboard = UIStoryboard(name: "NewMessageChooseUser", bundle: nil)
        
        let newMessageChooseUserVC = storyboard.instantiateViewController(withIdentifier: "NewMessageChooseUser") as! NewMessageChooseUserVC
        
        newMessageChooseUserVC.newMessageVC = self
        
        newMessageChooseUserVC.modalPresentationStyle = .pageSheet
        
        self.present(newMessageChooseUserVC, animated: true, completion: nil)
    }
    
    private func createChatRoomIfNeededAndSendChatMessage() {
        
        guard let userID = UserDefaults.standard.value(forKey: "userID") as? String else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: userID not found)")
            return
        }
        
        guard let otherUserID = selectedUser?.userID else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - otherUserID not found")
            return
        }
        
        guard let otherUserFCMToken = selectedUser?.fcmToken else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - otherUserFCMToken not found")
            return
        }
        
        FirestoreManager.shared.getPersonalChatRoomID(userID: userID, otherUserID: otherUserID, completion: { success, chatRoomID in
            if success {
                
                if let chatRoomID = chatRoomID, !chatRoomID.isEmpty {
                    self.sendChatMessage(userID: userID, roomID: chatRoomID, otherUserFCMToken: otherUserFCMToken)
                }
                else {
                    let participants = [userID, otherUserID]
                    let isGroup = false
                    
                    self.createChatRoom(userID: userID, participants: participants, isGroup: isGroup, groupName: nil) { success, roomID in
                        if success {
                            guard let roomID = roomID else {
                                print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: roomID not found")
                                return
                            }
                            
                            self.sendChatMessage(userID: userID, roomID: roomID, otherUserFCMToken: otherUserFCMToken)
                        }
                    }
                }
                
            }
            
        })
        
    }
    
    private func createChatRoom(userID: String, participants: [String], isGroup: Bool, groupName: String?, completion: @escaping (Bool, String?) -> Void) {
        var roomID = String()
        var isUnique = false
        while isUnique == false {
            let uuid = UUID().uuidString
            roomID = "\(userID)_\(uuid)"
            
            isUnique = CoreDataManager.shared.isValidChatRoomID(roomID: roomID)
        }
        
        FirestoreManager.shared.createChatRoom(roomID: roomID, participants: participants, isGroup: isGroup, groupName: groupName, completion: { success in
            if success {
                completion(true, roomID)
            }
            else {
                completion(false, nil)
            }
        })
    }
    
    private func sendChatMessage(userID: String, roomID: String, otherUserFCMToken: String) {
        
        let content = chatTextView.text ?? ""
        let body = content
        
        let type = "text"
        
        var messageID = String()
        var isUnique = false
        while isUnique == false {
            let uuid = UUID().uuidString
            messageID = "\(userID)_\(uuid)"
            
            isUnique = CoreDataManager.shared.isValidChatMessageID(messageID: messageID)
        }
        
        let timestamp = TimestampManager.shared.getCurrentTimestamp()
        
        chatTextView.text = ""
        view.endEditing(true)
        
        let chatMessage = ChatMessage(messageID: messageID, roomID: roomID, content: content, type: type, timestamp: timestamp, date: nil, time: nil, sender: userID, readBy: [userID], status: "Sending...")
        
        CoreDataManager.shared.updateChatMessageToCoreData(chatMessage: chatMessage)
        
        FirestoreManager.shared.sendChatMessage(userID: userID, chatMessage: chatMessage)
        
        guard let chatRooms = CoreDataManager.shared.getAllChatRoomCoreData() else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: chatRooms not found")
            return
        }
        
//        FirestoreManager.shared.getUserNameAndFCMToken(userID: userID, completion: { name, _ in
//            let title = name ?? ""
            
            let title = UserDefaults.standard.value(forKey: "userName") as? String ?? ""
            
            FCMManager.shared.sendPushNotification(receiverFCMToken: otherUserFCMToken, title: title, body: body)
            
            self.dismiss(animated: true, completion: nil)
//        })
        
    }
    
}

extension NewMessageVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count + text.count <= 500 {
            return true
        }
        else {
            return false
        }
    }
    
}
