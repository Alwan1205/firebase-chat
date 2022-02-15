//
//  DatabaseManager.swift
//  Firebase Chat
//
//  Created by Admin on 16/12/21.
//

import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database(url: "https://fir-chat-73aef-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
}

extension DatabaseManager {
    
    // INSERT USER
    public func insertUser(user: ChatAppUser, completion: @escaping (Bool) -> Void ) {
        
        // SET USER VALUE ON DATABASE
        database.child(user.uid).setValue(
        [
            "email": user.email,
            "first_name": user.firstName,
            "last_name": user.lastName,
            "profile_picture": user.profilePicture
        ],
        withCompletionBlock: { error, _ in
            
            guard error == nil
            else {
                if let error = error {
                    print("Failed to add user to database error: \(error.localizedDescription)")
                }
                
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in

                // check if users exists and set usersCollection
                if var usersCollection = snapshot.value as? [[String: String]] {

                    // append new element to usersCollection
                    let newElement: [String: String] =
                        [
                            "name": "\(user.firstName) \(user.lastName)",
//                            "email": user.email
                            "uid": "\(user.uid)"
                        ]
                    usersCollection.append(newElement)

                    // set usersCollection to the users database
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil
                        else {
                            if let error = error {
                                print("Error: \(error.localizedDescription)")
                            }

                            completion(false)
                            return
                        }

                        completion(true)
                    })
                }
                // check if users doesn't exists
                else {

                    // create newCollection for uesrs
                    let newCollection: [[String: String]] =
                        [[
                            "name": "\(user.firstName) \(user.lastName)",
//                            "email": user.email
                            "uid": "\(user.uid)"
                        ]]

                    // set newCollection to the users database
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil
                        else {
                            print("Error: \(error?.localizedDescription)")
                            completion(false)
                            return
                        }

                        completion(true)
                    })
                }
            })
            
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").getData { error, snapshot in
            guard error == nil
            else {
                print("Get all users error: \(error)")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            guard let snapshotValue = snapshot.value as? [[String: String]]
            else {
                print("Get all users error: snapshotValue not found")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            print("Get all users snapshotValue: \(snapshotValue)")
            completion(.success(snapshotValue))
        }
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
    public func getProfilePicture(uid: String, completion: @escaping (String) -> Void) {
        
        self.database.child(uid).getData(completion: { error, snapshot in
            
            guard error == nil
            else {
                print("Get profile picture error: \(error?.localizedDescription)")
                completion("")
                return
            }
            
            guard let snapshotValue = snapshot.value as? [String: Any]
            else {
                print("snapshotValue not found")
                completion("")
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                print("getProfilePicture - snapshotValue = \(snapshotValue)")
            }
            
            guard let profilePictureString = snapshotValue["profile_picture"] as? String
            else{
                print("profilePictureString not found")
                completion("")
                return
            }
            
            completion(profilePictureString)
            
        })
        
    }
    
}

extension DatabaseManager {
    
    public func createNewConversation(with otherUserUID: String, firstMessage: TestMessage, name: String, completion: @escaping (Bool) -> Void) {
        guard let currentUID = UserDefaults.standard.value(forKey: "uid") as? String
        else {
            return
        }
        
        let ref = database.child(currentUID)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var snapshotValue = snapshot.value as? [String: Any]
            else {
                print("snapshotValue not found")
                completion(false)
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_uid": otherUserUID,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            if var conversations = snapshotValue["conversations"] as? [[String: Any]] {
                conversations.append(newConversationData)
                snapshotValue["conversations"] = conversations
                print("snapshotValue = \(snapshotValue)")
                ref.setValue(snapshotValue, withCompletionBlock: { [weak self] error, _ in
                    guard let strongSelf = self
                    else {
                        return
                    }
                    
                    guard error == nil
                    else {
                        completion(false)
                        return
                    }
                    
                    strongSelf.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                })
            }
            else {
                snapshotValue["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(snapshotValue, withCompletionBlock: { [weak self] error, _ in
                    guard let strongSelf = self
                    else {
                        return
                    }
                    
                    guard error == nil
                    else {
                        completion(false)
                        return
                    }
                    
                    strongSelf.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                })
            }
        })
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: TestMessage, completion: @escaping (Bool) -> Void) {
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserUID = UserDefaults.standard.value(forKey: "uid")
        else {
            completion(false)
            return
        }
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_uid": currentUserUID,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding conversation: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil
            else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    public func getAllConversations(for uid: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(uid)/conversations").observe(.value, with: { snapshot in
            guard let snapshotValue = snapshot.value as? [[String: Any]]
            else {
                print("snapshotValue not found")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = snapshotValue.compactMap({ dictionary in
                guard let conversationID = dictionary["id"] as? String, let name = dictionary["name"] as? String, let otherUserUID = dictionary["other_user_uid"] as? String, let latestMessage = dictionary["latest_message"] as? [String: Any], let date = latestMessage["date"] as? Date, let text = latestMessage["message"] as? String, let isRead = latestMessage["is_read"] as? Bool
                else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: text, isRead: isRead)
                let conversationObject = Conversation(id: conversationID, name: name, otherUserUID: otherUserUID, latestMessage: latestMessageObject)
                
                return conversationObject
            })
            
            completion(.success(conversations))
        })
    }
    
    public func getAllConversationMessages(with uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    public func sendMessage(to conversation: String, message: String, completion: @escaping (Bool) -> Void) {
        
    }
}

// USER MODEL
struct ChatAppUser {
    let uid: String
    let firstName: String
    let lastName: String
    let email: String
    let profilePicture: String
}
