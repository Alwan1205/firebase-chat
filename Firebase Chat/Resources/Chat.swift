//
//  Chats.swift
//  Firebase Chat
//
//  Created by Admin on 27/1/22.
//

import FirebaseFirestore

// disimpan ke local data
struct Chat {
    static var rooms = [ChatRoom]()
    static var lastUpdated = String()
    static var chatRoomsListener: ListenerRegistration?
    static var chatMessagesListener: ListenerRegistration?
    static var firestoreChatVC: FirestoreChatViewController?
    static var firestoreChatMessagesVC: FirestoreChatMessagesViewController?
    
    static var usersUID = [String]()
    static var roomIDs = [String]()
}
