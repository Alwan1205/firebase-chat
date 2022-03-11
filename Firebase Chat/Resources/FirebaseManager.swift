//
//  FirebaseManager.swift
//  Firebase Chat
//
//  Created by Admin on 17/2/22.
//

import FirebaseDatabase

final class FirebaseManager {
    static let shared = FirebaseManager()
    private let database = Database.database(url: "https://fir-chat-73aef-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
}

extension FirebaseManager {
    
    
    
}
