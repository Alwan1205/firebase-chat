//
//  NewMessageChooseUserTableViewCell.swift
//  Firebase Chat
//
//  Created by Admin on 4/3/22.
//

import UIKit

class NewMessageChooseUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var userProfilePictureimageView: UIImageView!
    
    public func setupCell(userName: String, userID: String) {
        userNameLabel.text = userName
        userIDLabel.text = "ID: \(userID)"
    }

}
