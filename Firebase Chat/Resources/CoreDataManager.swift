//
//  CoreDataManager.swift
//  Firebase Chat
//
//  Created by Admin on 11/2/22.
//

import UIKit
import CoreData

final class CoreDataManager {
    
    static var shared = CoreDataManager()
    
}

extension CoreDataManager {
    
    // NEW
    public func updateChatRoomToCoreData(chatRoom: ChatRoom) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: appDelegate not found")
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "ChatRoomCoreData")
        
        request.predicate = NSPredicate(format: "roomID == %@", chatRoom.roomID)
        
        do {
            let results = try managedContext.fetch(request)
            
            if let chatRoomCoreData = results.first {
                print("File: \(#file) - Function: \(#function) - Line: \(#line) - Updating chat room to ChatRoomCoreData for chat room: \(chatRoom)")
                
                chatRoomCoreData.setValue(chatRoom.chatName, forKey: "chatName")
                chatRoomCoreData.setValue(chatRoom.chatPicture, forKey: "chatPicture")
                chatRoomCoreData.setValue(chatRoom.isGroup, forKey: "isGroup")
                chatRoomCoreData.setValue(chatRoom.participants, forKey: "participants")
                chatRoomCoreData.setValue(chatRoom.participantNames, forKey: "participantNames")
                chatRoomCoreData.setValue(chatRoom.participantFCMTokens, forKey: "participantFCMTokens")
                chatRoomCoreData.setValue(chatRoom.participantLastUpdates, forKey: "participantLastUpdates")
                
                do {
                    try managedContext.save()
                    
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Updated chat room to ChatRoomCoreData saved")
                }
                catch let error as NSError {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: \(error)")
                }
            }
            else {
                print("File: \(#file) - Function: \(#function) - Line: \(#line) - Adding chat room to ChatRoomCoreData for chat room: \(chatRoom)")
                
                let chatRoomCoreData = NSEntityDescription.insertNewObject(forEntityName: "ChatRoomCoreData", into: managedContext)
                
                chatRoomCoreData.setValue(chatRoom.roomID, forKey: "roomID")
                chatRoomCoreData.setValue(chatRoom.chatName, forKey: "chatName")
                chatRoomCoreData.setValue(chatRoom.chatPicture, forKey: "chatPicture")
                chatRoomCoreData.setValue(chatRoom.isGroup, forKey: "isGroup")
                chatRoomCoreData.setValue(chatRoom.participants, forKey: "participants")
                chatRoomCoreData.setValue(chatRoom.participantNames, forKey: "participantNames")
                chatRoomCoreData.setValue(chatRoom.participantFCMTokens, forKey: "participantFCMTokens")
                chatRoomCoreData.setValue(chatRoom.participantLastUpdates, forKey: "participantLastUpdates")
                
                do {
                    try managedContext.save()
                    
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Added chat room to ChatRoomCoreData saved")
                }
                catch let error as NSError {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: \(error)")
                }
            }
        }
        catch let error as NSError {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: \(error)")
        }
        
    }
    
    public func getAllChatRoomCoreData() -> [ChatRoom]? {
        
        print("File: \(#file) - Function: \(#function) - Line: \(#line) - Getting all ChatRoomCoreData")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "ChatRoomCoreData")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(request)
            
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - ChatRoomCoreData results: \(results)")
            
            guard !results.isEmpty else {
                print("File: \(#file) - Function: \(#function) - Line: \(#line) - results is empty")
                return nil
            }
            
            var chatRooms: [ChatRoom] = []
            
            for result in results {
                guard let object = result as? NSManagedObject else { continue }
                
                guard let roomID = object.value(forKey: "roomID") as? String else {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: roomID not found")
                    continue
                }
                
                guard let participants = object.value(forKey: "participants") as? [String] else {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: participants not found")
                    continue
                }
                
                guard let isGroup = object.value(forKey: "isGroup") as? Bool else {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: isGroup not found")
                    continue
                }
                
                guard let chatName = object.value(forKey: "chatName") as? String else {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: chatName not found")
                    continue
                }
                
                var chatPicture: String? = nil
                if let chatPictureTemp = object.value(forKey: "chatPicture") as? String {
                    chatPicture = chatPictureTemp
                }
                
                var participantNames: [String: String] = [:]
                if let participantNamesTemp = object.value(forKey: "participantNames") as? [String: String] {
                    participantNames = participantNamesTemp
                }
                
                var participantFCMTokens: [String: String] = [:]
                if let participantFCMTokensTemp = object.value(forKey: "participantFCMTokens") as? [String: String] {
                    participantFCMTokens = participantFCMTokensTemp
                }
                
                var participantLastUpdates: [String: String] = [:]
                if let participantLastUpdatesTemp = object.value(forKey: "participantLastUpdates") as? [String: String] {
                    participantLastUpdates = participantLastUpdatesTemp
                }
                
                var messages: [ChatMessage]? = nil
                
                let chatRoom = ChatRoom(roomID: roomID, participants: participants, participantNames: participantNames, participantFCMTokens: participantFCMTokens, participantLastUpdates: participantLastUpdates, isGroup: isGroup, chatName: chatName, chatPicture: chatPicture, messages: messages)
                
                chatRooms.append(chatRoom)
            }
            
            return chatRooms
        }
        catch let error as NSError {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: \(error)")
            return nil
        }
        
    }
    
    public func updateChatMessageToCoreData(chatMessage: ChatMessage) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: appDelegate not found")
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "ChatMessageCoreData")
        
        request.predicate = NSPredicate(format: "messageID == %@", chatMessage.messageID)
        
        do {
            let results = try managedContext.fetch(request)
            
            if let coreDataChatMessage = results.first {
                print("File: \(#file) - Function: \(#function) - Line: \(#line) - Updating chat message to ChatMessageCoreData for chat message: \(chatMessage)")
                
                coreDataChatMessage.setValue(chatMessage.content, forKey: "content")
                coreDataChatMessage.setValue(chatMessage.readBy, forKey: "readBy")
                coreDataChatMessage.setValue(chatMessage.roomID, forKey: "roomID")
                coreDataChatMessage.setValue(chatMessage.sender, forKey: "sender")
                coreDataChatMessage.setValue(chatMessage.status, forKey: "status")
                coreDataChatMessage.setValue(chatMessage.timestamp, forKey: "timestamp")
                coreDataChatMessage.setValue(chatMessage.type, forKey: "type")
                
                do {
                    try managedContext.save()
                    
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Updated chat message to ChatMessageCoreData saved")
                }
                catch let error as NSError {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: \(error)")
                }
            }
            else {
                print("File: \(#file) - Function: \(#function) - Line: \(#line) - Adding chat message to ChatMessageCoreData for chat message: \(chatMessage)")
                
                let coreDataChatMessage = NSEntityDescription.insertNewObject(forEntityName: "ChatMessageCoreData", into: managedContext)
                
                coreDataChatMessage.setValue(chatMessage.messageID, forKey: "messageID")
                coreDataChatMessage.setValue(chatMessage.content, forKey: "content")
                coreDataChatMessage.setValue(chatMessage.readBy, forKey: "readBy")
                coreDataChatMessage.setValue(chatMessage.roomID, forKey: "roomID")
                coreDataChatMessage.setValue(chatMessage.sender, forKey: "sender")
                coreDataChatMessage.setValue(chatMessage.status, forKey: "status")
                coreDataChatMessage.setValue(chatMessage.timestamp, forKey: "timestamp")
                coreDataChatMessage.setValue(chatMessage.type, forKey: "type")
                
                do {
                    try managedContext.save()
                    
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Added chat room to ChatRoomCoreData saved")
                }
                catch let error as NSError {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: \(error)")
                }
            }
        }
        catch let error as NSError {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: \(error)")
        }
        
    }
    
    public func getAllChatMessageCoreData() -> [ChatMessage]? {
        
        print("File: \(#file) - Function: \(#function) - Line: \(#line) - Getting all ChatMessageCoreData")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "ChatMessageCoreData")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(request)
            
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - ChatMessageCoreData results: \(results)")
            
            guard !results.isEmpty else {
                print("File: \(#file) - Function: \(#function) - Line: \(#line) - results is empty")
                return nil
            }
            
            var chatMessages: [ChatMessage] = []
            
            for result in results {
                guard let object = result as? NSManagedObject else { continue }
                
                guard let messageID = object.value(forKey: "messageID") as? String else {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: messageID not found")
                    continue
                }
                
                guard let roomID = object.value(forKey: "roomID") as? String else {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: roomID not found")
                    continue
                }
                
                guard let content = object.value(forKey: "content") as? String else {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: content not found")
                    continue
                }
                
                guard let timestamp = object.value(forKey: "timestamp") as? String else {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: timestamp not found")
                    continue
                }
                
                guard let type = object.value(forKey: "type") as? String else {
                    print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: type not found")
                    continue
                }
                
                var readBy: [String]? = nil
                if let readByTemp = object.value(forKey: "readBy") as? [String] {
                    readBy = readByTemp
                }
                
                var sender: String? = nil
                if let senderTemp = object.value(forKey: "sender") as? String {
                    sender = senderTemp
                }
                
                var status: String? = nil
                if let statusTemp = object.value(forKey: "status") as? String {
                    status = statusTemp
                }
                
                let chatMessage = ChatMessage(messageID: messageID, roomID: roomID, content: content, type: type, timestamp: timestamp, sender: sender, readBy: readBy, status: status)
                
                chatMessages.append(chatMessage)
            }
            
            return chatMessages
        }
        catch let error as NSError {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: \(error)")
            return nil
        }
        
    }
    
    public func isValidChatMessageID(messageID: String) -> Bool {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: appDelegate not found")
            return false
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let chatMessageRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatMessageCoreData")
        
        chatMessageRequest.predicate = NSPredicate(format: "messageID == %@", messageID)
        
        do {
            let results = try managedContext.fetch(chatMessageRequest) as? [NSManagedObject]
            
            if results?.count == 0 {
                return true
            }
            else {
                return false
            }
        }
        catch let error as NSError {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: \(error)")
            return false
        }
    }
    
    public func isValidChatRoomID(roomID: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: appDelegate not found")
            return false
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let chatRoomRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatRoomCoreData")
        
        chatRoomRequest.predicate = NSPredicate(format: "roomID == %@", roomID)
        
        do {
            let results = try managedContext.fetch(chatRoomRequest) as? [NSManagedObject]
            
            if results?.count == 0 {
                return true
            }
            else {
                return false
            }
        }
        catch let error as NSError {
            print("File: \(#file) - Function: \(#function) - Line: \(#line) - Error: \(error)")
            return false
        }
    }
    
    // OLD
    
    // alwan current task
    // alwan test start
    public func saveChatRoomToCoreData(chatRoom: ChatRoomOLD) {
        var chatRooms: [NSManagedObject] = []

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "CoreDataChatRoom", in: managedContext)!

        let coreDataChatRoom = NSManagedObject(entity: entity, insertInto: managedContext)

        coreDataChatRoom.setValue(chatRoom.isGroup, forKeyPath: "isGroup")
        coreDataChatRoom.setValue(chatRoom.participants, forKeyPath: "participants")
        coreDataChatRoom.setValue(chatRoom.roomID, forKeyPath: "roomID")
        coreDataChatRoom.setValue(chatRoom.timestamp, forKeyPath: "timestamp")

        do {
            try managedContext.save()
            chatRooms.append(coreDataChatRoom)
        }
        catch let error as NSError {
            print("Could not save, \(error), \(error.userInfo)")
        }
    }

    public func saveChatMessageToCoreData(chatMessage: ChatMessageOLD) {
        // alwan current task
        print("saveChatMessageToCoreData - chatMessage: \(chatMessage)")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        var coreDataChatMessage = NSEntityDescription.insertNewObject(forEntityName: "CoreDataChatMessage", into: managedContext)
        
        coreDataChatMessage.setValue(chatMessage.content, forKey: "content")
        coreDataChatMessage.setValue(chatMessage.messageID, forKey: "messageID")
        coreDataChatMessage.setValue(chatMessage.readBy, forKey: "readBy")
        coreDataChatMessage.setValue(chatMessage.roomID, forKey: "roomID")
        coreDataChatMessage.setValue(chatMessage.senderID, forKey: "senderID")
        coreDataChatMessage.setValue(chatMessage.status, forKey: "status")
        coreDataChatMessage.setValue(chatMessage.timestamp, forKey: "timestamp")
        coreDataChatMessage.setValue(chatMessage.type, forKey: "type")
        
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save CoreDataChatMessages: \(error)")
        }
    }
    
    public func fetchChatRooms() {
        
        print("fetchChatRooms")
        
        Chat.rooms = []
        Chat.roomIDs = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let chatRoomsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CoreDataChatRoom")
        chatRoomsFetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(chatRoomsFetchRequest)
            
            print("results = \(results)")
            
            for result in results {
                guard let object = result as? NSManagedObject else { continue }
                
                guard let roomID = object.value(forKey: "roomID") as? String else {
                    print("roomID not found")
                    return
                }
                
                guard let participants = object.value(forKey: "participants") as? [String] else {
                    print("participants not found")
                    return
                }
                
                guard let isGroup = object.value(forKey: "isGroup") as? Bool else {
                    print("isGroup not found")
                    return
                }
                
                guard let chatName = object.value(forKey: "chatName") as? String else {
                    print("chatName not found")
                    return
                }
                
                var chatPicture: String? = nil
                
                var messages: [ChatMessageOLD]? = nil
                
                guard let participantsNames = object.value(forKey: "participantsNames") as? [String: String] else {
                    print("participantsNames not found")
                    return
                }
                
                guard let lastMessage = object.value(forKey: "lastMessage") as? String else {
                    print("lastMessage not found")
                    return
                }
                
                guard let timestamp = object.value(forKey: "timestamp") as? String else {
                    print("timestamp not found")
                    return
                }
                
                guard let readBy = object.value(forKey: "readBy") as? [String] else {
                    print("readBy not found")
                    return
                }
                
                let chatRoom = ChatRoomOLD(roomID: roomID, participants: participants, isGroup: isGroup, chatName: chatName, chatPicture: chatPicture, messages: messages, participantNames: participantsNames, lastMessage: lastMessage, timestamp: timestamp, readBy: readBy)
                
                Chat.rooms.append(chatRoom)
                print("Chat.rooms = \(Chat.rooms)")
                
                Chat.roomIDs.append(roomID)
                print("Chat.roomIDs = \(Chat.roomIDs)")
                
                Chat.rooms = Chat.rooms.sorted(by: { $0.timestamp > $1.timestamp })
            }
        }
        catch let error as NSError {
            print("Failed to fetch CoreDataChatRoom: \(error)")
        }
    }
    
    public func fetchChatMessages() {
        
        print("fetchChatMessages")
        
        for index in Chat.rooms.indices {
            Chat.rooms[index].messages?.removeAll()
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let chatMessagesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CoreDataChatMessage")
        chatMessagesFetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(chatMessagesFetchRequest)
            
            print("results = \(results)")
            
            for result in results {
                guard let object = result as? NSManagedObject else { continue }
                
                guard let content = object.value(forKey: "content") as? String else {
                    print("content not found")
                    return
                }
                
                guard let messageID = object.value(forKey: "messageID") as? String else {
                    print("messageID not found")
                    return
                }
                
                guard let readBy = object.value(forKey: "readBy") as? [String] else {
                    print("readBy not found")
                    return
                }
                
                guard let roomID = object.value(forKey: "roomID") as? String else {
                    print("roomID not found")
                    return
                }
                
                guard let senderID = object.value(forKey: "senderID") as? String else {
                    print("senderID not found")
                    return
                }
                
                guard let status = object.value(forKey: "status") as? String else {
                    print("status not found")
                    return
                }
                
                guard let timestamp = object.value(forKey: "timestamp") as? String else {
                    print("timestamp not found")
                    return
                }
                
                guard let type = object.value(forKey: "type") as? String else {
                    print("type not found")
                    return
                }
                
                let chatMessage = ChatMessageOLD(messageID: messageID, roomID: roomID, senderID: senderID, timestamp: timestamp, type: type, readBy: readBy, content: content, status: status)
                
                for index in Chat.rooms.indices {
                    if Chat.rooms[index].roomID == roomID {
                        Chat.rooms[index].messages?.append(chatMessage)
                        
                        Chat.rooms[index].messages = Chat.rooms[index].messages?.sorted(by: { $0.timestamp < $1.timestamp })
                        
                        print("Chat messages added to: \(Chat.rooms[index])")
                    }
                }
            }
        }
        catch let error as NSError {
            print("Failed to fetch CoreDataChatMessage: \(error)")
        }
        
    }
    
    public func updateCoreDataChatRoom(chatRoom: ChatRoomOLD) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let chatRoomRequest = NSFetchRequest<NSManagedObject>(entityName: "CoreDataChatRoom")
        chatRoomRequest.predicate = NSPredicate(format: "roomID == %@", chatRoom.roomID)
        
        do {
            let results = try managedContext.fetch(chatRoomRequest)
            
            if let coreDataChatRoom = results.first {
                print("Update CoreDataChatRoom: \(chatRoom)")
                
                coreDataChatRoom.setValue(chatRoom.chatName, forKey: "chatName")
                coreDataChatRoom.setValue(chatRoom.chatPicture, forKey: "chatPicture")
                coreDataChatRoom.setValue(chatRoom.isGroup, forKey: "isGroup")
                coreDataChatRoom.setValue(chatRoom.lastMessage, forKey: "lastMessage")
                coreDataChatRoom.setValue(chatRoom.participants, forKey: "participants")
                coreDataChatRoom.setValue(chatRoom.participantNames, forKey: "participantsNames")
                coreDataChatRoom.setValue(chatRoom.readBy, forKey: "readBy")
                coreDataChatRoom.setValue(chatRoom.timestamp, forKey: "timestamp")
                
                do {
                    try managedContext.save()
                }
                catch let error as NSError {
                    print("Could not save CoreDataChatRoom: \(error)")
                }
            }
            else {
                print("Add CoreDataChatRoom: \(chatRoom)")
                
                let coreDataChatRoom = NSEntityDescription.insertNewObject(forEntityName: "CoreDataChatRoom", into: managedContext)
                
                coreDataChatRoom.setValue(chatRoom.chatName, forKey: "chatName")
                coreDataChatRoom.setValue(chatRoom.chatPicture, forKey: "chatPicture")
                coreDataChatRoom.setValue(chatRoom.isGroup, forKey: "isGroup")
                coreDataChatRoom.setValue(chatRoom.lastMessage, forKey: "lastMessage")
                coreDataChatRoom.setValue(chatRoom.participants, forKey: "participants")
                coreDataChatRoom.setValue(chatRoom.participantNames, forKey: "participantsNames")
                coreDataChatRoom.setValue(chatRoom.readBy, forKey: "readBy")
                coreDataChatRoom.setValue(chatRoom.timestamp, forKey: "timestamp")
                coreDataChatRoom.setValue(chatRoom.roomID, forKey: "roomID")
                
                do {
                    try managedContext.save()
                }
                catch let error as NSError {
                    print("Could not save CoreDataChatRoom: \(error)")
                }
            }
        }
        catch let error as NSError {
            print("Failed to fetch CoreDataChatRoom: \(error)")
        }
    }
    
    public func updateCoreDataChatMessage(chatMessage: ChatMessageOLD) {
        
        print("updateCoreDataChatMessage - chatMessage: \(chatMessage)")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let chatMessageRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataChatMessage")//NSFetchRequest<NSManagedObject>(entityName: "CoreDataChatMessage")
        chatMessageRequest.predicate = NSPredicate(format: "messageID == %@", chatMessage.messageID)
        
        do {
            guard let results = try managedContext.fetch(chatMessageRequest) as? [NSManagedObject] else {
                print("results not found")
                return
            }
            
            if results.count > 0 {
                print("Update CoreDataChatMessage: \(chatMessage)")
                
                results[0].setValue(chatMessage.content, forKey: "content")
                results[0].setValue(chatMessage.readBy, forKey: "readBy")
                results[0].setValue(chatMessage.senderID, forKey: "senderID")
                results[0].setValue(chatMessage.status, forKey: "status")
                results[0].setValue(chatMessage.timestamp, forKey: "timestamp")
                results[0].setValue(chatMessage.type, forKey: "type")
                
                do {
                    try managedContext.save()
                }
                catch let error as NSError {
                    print("Could not save CoreDataChatMessage: \(error)")
                }
            }
            else {
                print("Add CoreDataChatRoom: \(chatMessage)")
                
                let coreDataChatMessage = NSEntityDescription.insertNewObject(forEntityName: "CoreDataChatMessage", into: managedContext)
                
                coreDataChatMessage.setValue(chatMessage.content, forKey: "content")
                coreDataChatMessage.setValue(chatMessage.messageID, forKey: "messageID")
                coreDataChatMessage.setValue(chatMessage.readBy, forKey: "readBy")
                coreDataChatMessage.setValue(chatMessage.roomID, forKey: "roomID")
                coreDataChatMessage.setValue(chatMessage.senderID, forKey: "senderID")
                coreDataChatMessage.setValue(chatMessage.status, forKey: "status")
                coreDataChatMessage.setValue(chatMessage.timestamp, forKey: "timestamp")
                coreDataChatMessage.setValue(chatMessage.type, forKey: "type")
                
                do {
                    try managedContext.save()
                }
                catch let error as NSError {
                    print("Could not save CoreDataChatMessage: \(error)")
                }
            }
        }
        catch let error as NSError {
            print("Failed to fetch CoreDataChatMessage: \(error)")
        }
        
    }
    
    // untuk testing dipanggil di viewTapped FirestoreChatMessagesViewController
    public func deleteAllCoreData(entity: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            for result in results {
                guard let object = result as? NSManagedObject else { continue }
                managedContext.delete(object)
            }
        }
        catch let error as NSError {
            print("Failed to delete core data for entity \(entity): \(error)")
        }
    }
    // alwan test end
    
    public func validateCoreDataChatMessageID(messageID: String) -> Bool {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let chatMessageRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataChatMessage")//NSFetchRequest<NSManagedObject>(entityName: "CoreDataChatMessage")
        chatMessageRequest.predicate = NSPredicate(format: "messageID == %@", messageID)
        
        do {
            guard let results = try managedContext.fetch(chatMessageRequest) as? [NSManagedObject] else {
                print("results not found")
                return false
            }
            
            if results.count == 0 {
                return true
            }
            else {
                return false
            }
        }
        catch let error as NSError {
            print("Failed to fetch CoreDataChatMessage: \(error)")
            return false
        }
    }
    
}
