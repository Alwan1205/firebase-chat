//
//  FirestoreChatRoomsTableViewCell.swift
//  Firebase Chat
//
//  Created by Admin on 17/1/22.
//

import UIKit

class FirestoreChatRoomsTableViewCell: UITableViewCell {

    @IBOutlet weak var roomPictureImageView: UIImageView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateStringLabel: UILabel!
    @IBOutlet weak var newMessageImageView: UIImageView!
    @IBOutlet weak var chatRoomView: UIView!
    
    func setupChatRoom(picture: String?, chatName: String, lastMessage: String, dateString: String, isRead: Bool) {
        
        print("setupChatRoom - chatName = \(chatName)")
        
        roomNameLabel.text = chatName
        lastMessageLabel.text = lastMessage
        dateStringLabel.text = dateString
        
        chatRoomView.layer.cornerRadius = 10
        chatRoomView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        if isRead {
            lastMessageLabel.font = UIFont.systemFont(ofSize: 17)
            newMessageImageView.isHidden = true
        }
        else {
            lastMessageLabel.font = UIFont.boldSystemFont(ofSize: 17)
            newMessageImageView.isHidden = false
        }
    }

}
