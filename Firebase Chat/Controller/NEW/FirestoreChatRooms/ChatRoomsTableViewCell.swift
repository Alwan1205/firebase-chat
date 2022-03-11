//
//  ChatRoomsTableViewCell.swift
//  Firebase Chat
//
//  Created by Admin on 21/2/22.
//

import UIKit

class ChatRoomsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatPictureImageView: UIImageView!
    @IBOutlet weak var chatNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var newMessageImageView: UIImageView!
    
    public func setupChatRoom(chatName: String, lastMessage: String, dateTime: String, isRead: Bool, isGroup: Bool) {
        chatNameLabel.text = chatName
        lastMessageLabel.text = lastMessage
        dateAndTimeLabel.text = dateTime
        
        if isRead {
            lastMessageLabel.font = UIFont.systemFont(ofSize: 17)
            newMessageImageView.isHidden = true
        }
        else {
            lastMessageLabel.font = UIFont.boldSystemFont(ofSize: 17)
            newMessageImageView.isHidden = false
        }
        
        if isGroup {
            chatPictureImageView.image = UIImage(named: "default_group_picture")
        }
        else {
            chatPictureImageView.image = UIImage(named: "default_profile_picture")
        }
    }

}
