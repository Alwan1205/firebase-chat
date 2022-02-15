//
//  FirestoreChatMessagesTableViewCell.swift
//  Firebase Chat
//
//  Created by Admin on 18/1/22.
//

import UIKit

class FirestoreChatMessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var chatTextLabel: UILabel!
    @IBOutlet weak var dateStringLabel: UILabel!
    @IBOutlet weak var chatMessageView: UIView!
    @IBOutlet weak var cellContentView: UIView!
    
    @IBOutlet weak var senderLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var senderLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTextLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTextLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateStringLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateStringLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatMessageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatMessageViewTrailingConstraint: NSLayoutConstraint!
    
    func setupChatMessage(userUID: String, senderUID: String, participantsNames: [String: String], content: String, dateString: String, isGroup: Bool, chatName: String) {
        
        print("setupChatMessage - content = \(content)")
        
        chatMessageView.layer.cornerRadius = 10
        
        chatTextLabel.text = content
        dateStringLabel.text = dateString
        
        chatTextLabel.sizeToFit()
        dateStringLabel.sizeToFit()
        
        if userUID == senderUID {
            senderLabel.text = "Anda"
            senderLabel.textColor = .white
            senderLabel.textAlignment = .right
//            senderLabelLeadingConstraint.constant = 0
//            senderLabelTrailingConstraint.constant = 0

            chatTextLabel.textColor = .white
            chatTextLabel.textAlignment = .right
//            chatTextLabelLeadingConstraint.constant = 0
//            chatTextLabelTrailingConstraint.constant = 0

            dateStringLabel.textColor = .white
            dateStringLabel.textAlignment = .right
//            dateStringLabelLeadingConstraint.constant = 0
//            dateStringLabelTrailingConstraint.constant = 0

            chatMessageView.backgroundColor = .systemBlue
            chatMessageViewLeadingConstraint.isActive = false
            chatMessageViewTrailingConstraint.isActive = true
        }
        else {
            if isGroup {
                let senderName = participantsNames[senderUID] as? String ?? ""
                senderLabel.text = senderName
            }
            else {
                senderLabel.text = chatName
            }

            senderLabel.textAlignment = .left
            senderLabel.textColor = .black
//            senderLabelLeadingConstraint.constant = 0
//            senderLabelTrailingConstraint.constant = 0

            chatTextLabel.textColor = .black
            chatTextLabel.textAlignment = .left
//            chatTextLabelLeadingConstraint.constant = 0
//            chatTextLabelTrailingConstraint.constant = 0

            dateStringLabel.textColor = .black
            dateStringLabel.textAlignment = .left
//            dateStringLabelLeadingConstraint.constant = 0
//            dateStringLabelTrailingConstraint.constant = 0

            chatMessageView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            chatMessageViewTrailingConstraint.isActive = false
            chatMessageViewLeadingConstraint.isActive = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
