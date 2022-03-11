//
//  ChatMessagesTableViewCell.swift
//  Firebase Chat
//
//  Created by Admin on 23/2/22.
//

import UIKit

class ChatMessagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatMessageView: UIView!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var chatMessageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatMessageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatMessageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatMessageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    public func setupChatMessage(userIsSender: Bool, senderName: String, message: String, date: String, time: String, isDateSame: Bool, status: String?) {
        dateView.layer.cornerRadius = 10
        chatMessageView.layer.cornerRadius = 10
        
        senderNameLabel.text = senderName
        messageLabel.text = message
        timeLabel.text = time
        
        if userIsSender {
            senderNameLabel.textColor = .white
            messageLabel.textColor = .white
            timeLabel.textColor = .white
            chatMessageView.backgroundColor = .systemBlue
            
            statusLabel.text = status ?? ""
            
            chatMessageViewLeadingConstraint.isActive = false
            chatMessageViewTrailingConstraint.isActive = true
            
            statusLabel.isHidden = false
            chatMessageViewBottomConstraint.constant = 31
        }
        else {
            senderNameLabel.textColor = .black
            messageLabel.textColor = .black
            timeLabel.textColor = .black
            chatMessageView.backgroundColor = UIColor(cgColor: CGColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0))
            
            chatMessageViewLeadingConstraint.isActive = true
            chatMessageViewTrailingConstraint.isActive = false
            
            statusLabel.isHidden = true
            chatMessageViewBottomConstraint.constant = 5
        }
        
        if isDateSame {
            dateView.isHidden = true
            dateLabel.isHidden = true
            chatMessageViewTopConstraint.constant = 5
        }
        else {
            dateView.isHidden = false
            dateLabel.isHidden = false
            dateLabel.text = date
            chatMessageViewTopConstraint.constant = 51
        }
    }

}
