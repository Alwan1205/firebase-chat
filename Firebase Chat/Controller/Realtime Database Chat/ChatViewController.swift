//
//  ChatViewController.swift
//  Firebase Chat
//
//  Created by Admin on 20/12/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct TestMessage: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    public var photoUrl: String
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {

    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public let otherUserUID: String
    public var isNewConversation = false
    
    private var messages = [TestMessage]()
    private var selfSender: Sender? {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String
        else {
            return nil
        }
        
        return Sender(photoUrl: "",
               senderId: uid,
               displayName: "Joe Smith")
    }
    
    init(with uid: String) {
        self.otherUserUID = uid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello")))
        
        view.backgroundColor = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageID = createMessageID()
        else {
            return
        }
        
        print("Sending: \(text)")
        
        if isNewConversation {
            let message = TestMessage(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserUID, firstMessage: message, name: self.title ?? "User", completion: { success in
                if success {
                    print("Message sent")
                }
                else {
                    print("Failed to send message")
                }
            })
        }
        else {
            print("isNewConversation = false")
        }
    }
    
    private func createMessageID() -> String? {
        guard let currentUserUID = UserDefaults.standard.value(forKey: "uid")
        else {
            return nil
        }
        
        let dateString = ChatViewController.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserUID)_\(currentUserUID)_\(dateString)"
        print("Created Message ID: \(newIdentifier)")
        
        return newIdentifier
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        
        fatalError("Self sender is nil, uid should be cached")
        return Sender(photoUrl: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
