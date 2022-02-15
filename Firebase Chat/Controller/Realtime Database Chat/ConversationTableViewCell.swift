//
//  ConversationTableViewCell.swift
//  Firebase Chat
//
//  Created by Admin on 10/1/22.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {

    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let userImageView = UIImageView()
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 50
        userImageView.layer.masksToBounds = true
        
        return userImageView
    }()
    
    private let userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        
        return userNameLabel
    }()
    
    private let userMessageLabel: UILabel = {
        let userMessageLabel = UILabel()
        userMessageLabel.font = .systemFont(ofSize: 21, weight: .regular)
        userMessageLabel.numberOfLines = 0
        
        return userMessageLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        userNameLabel.frame = CGRect(x: userImageView.right + 10, y: 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height - 20) / 2)
        userMessageLabel.frame = CGRect(x: userImageView.right + 10, y: userNameLabel.bottom + 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height - 20) / 2)
    }
    
    public func configure(model: Conversation) {
        self.userMessageLabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
        
        DatabaseManager.shared.getProfilePicture(uid: model.otherUserUID, completion: { profilePictureString in
            
            if profilePictureString != "" && profilePictureString != "" {
                guard let profilePictureData: Data = Data(base64Encoded: profilePictureString, options: .ignoreUnknownCharacters)
                else {
                    print("profilePictureData not found")
                    return
                }

                let profilePicture = UIImage(data: profilePictureData)
                
                self.userImageView.image = profilePicture
            }
            else {
                print("profilePictureString not found")
            }
            
        })
    }

}
