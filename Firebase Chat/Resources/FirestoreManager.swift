//
//  FirestoreManager.swift
//  Firebase Chat
//
//  Created by Admin on 12/1/22.
//

import FirebaseFirestore
import CoreData

struct ChatRoom {
    let roomID: String
    let participants: [String]
    let isGroup: Bool
    let chatName: String
    let chatPicture: String? // reference ke firebase storage
    
    var messages: [ChatMessage]?
    var participantsNames: [String: String]?
    
    // untuk testing, aslinya diambil dari chat message
    let lastMessage: String?
    let timestamp: String
    let readBy: [String]?
}

struct ChatMessage {
    let messageID: String
    let roomID: String
    let senderID: String
    let timestamp: String
    let type: String // text / image / video
    
    let readBy: [String?]
    let content: String
    
    // alwan current task
    // alwan test start
    let status: String?
    // alwan test end
}

final class FirestoreManager {
    static let shared = FirestoreManager()
    private var ref: DocumentReference? = nil
    private let database = Firestore.firestore()
    private var getUserNameReturn: String?
    private var getParticipantsNameReturn: [String: String]?
    
}

extension FirestoreManager {
    
    public func setDeviceToken(userUID: String, fcmToken: String) {
        // alwan current task
        // alwan test start
//        database.settings.isPersistenceEnabled = false
        // alwan test end
        
        database.collection("users").document(userUID).setData(
            [
                "fcm_token": fcmToken
            ],
            merge: true,
            completion: { error in
                if let error = error {
                    print("Failed to set device token: \(error)")
                }
                else {
                    print("Success set fcm token for userUID: \(userUID)")
                }
            })
    }
    
    public func addUser(uid: String, email: String, name: String, completion: @escaping (Bool) -> Void) {
        
        database.collection("users").document(uid).setData([
            "email": email,
            "name": name
        ]) { error in
            if let error = error {
                print("Error adding user: \(error)")
                completion(false)
            }
            else {
                print("Success adding user")
                completion(true)
            }
        }
    }
    
    // last_update untuk tiap document di firestore di update-nya bukan lewat client tapi dari back-end dengan cloud function
    // untuk testing chat room di firestore menyimpan timestamp dari last message untuk sorting, aslinya sorting di local data berdasarkan last message-nya dari chat messages
    // aslinya di filter hanya document yang last_updated-nya + x > last_updated di local data
    // last_updated di firestore adalah timestamp saat mengirim ke firestore, sedangkan bisa ada delay saat sampai ke firestore. Fungsi x adalah menentukan untuk timeout saat mengirim chat jika ada delay, sehingga last_updated di firestore + x adalah waktu terlama data tersebut ter-update ke firestore (karena kalau lebih dari x seharusnya timeout dan tidak terkirim ke firestore)
    public func addChatRoomsListener(userUID: String, firestoreChatViewController: FirestoreChatViewController, completion: @escaping () -> Void) {
        
        removeChatRoomsListener()
        
        // untuk query-nya, ditambahkan filter hanya fetch yang last_updated-nya lebih besar dari CoreDataLastUpdating (CoreDataLastUpdating di update tiap read, dan last_updated di update tiap write untuk masing-masing document)
        Chat.chatRoomsListener = database.collection("chat_rooms").whereField("participants", arrayContains: userUID).addSnapshotListener({ querySnapshot, error in
            
            print("\nChat rooms listener called")
            
            if let error = error {
                print("Failed to add chat rooms listener: \(error)")
                completion()
            }
            else {
                guard let querySnapshot = querySnapshot
                else {
                    print("querySnapshot not found")
                    completion()
                    return
                }
                
                // alwan current task
                // alwan comment start
//                Chat.rooms = []
//                Chat.roomIDs = []
                // alwan comment end
                
                for document in querySnapshot.documents {
                    // aslinya begini
//                    let id = document.documentID
                    
                    // untuk testing
                    guard let roomID = document.data()["room_id"] as? String
                    else {
                        print("roomID not found")
                        completion()
                        return
                    }
                    print("roomID = \(roomID)")
                    
                    guard let participants = document.data()["participants"] as? [String]
                    else {
                        print("participants not found")
                        completion()
                        return
                    }
                    
                    guard let isGroup = document.data()["is_group"] as? Bool
                    else {
                        print("isGroup not found")
                        completion()
                        return
                    }
                    
                    var chatName = String()
                    var chatPicture = String() // chatPicture belum dipakai
                    
                    // Kalau group chat
                    if isGroup {
                        //
                        // alwan current task
                        self.getParticipantsNameReturn = [:]
                        self.getParticipantsName(participants: participants, completion: {
                            
                            //
                            guard let groupName = document.data()["group_name"] as? String
                            else {
                                print("groupName not found")
                                completion()
                                return
                            }
                            
                            chatName = groupName
                            
                            var lastMessage: String? = nil
                            if let lastMessageTemp = document.data()["last_message"] as? String {
                                lastMessage = lastMessageTemp
                            }
                            
                            guard let timestamp = document.data()["timestamp"] as? String
                            else {
                                print("timestamp not found")
                                completion()
                                return
                            }
                            
                            var readBy: [String]? = nil
                            if let readByTemp = document.data()["read_by"] as? [String] {
                                readBy = readByTemp
                            }
                            
                            let messages: [ChatMessage]? = nil
                            
                            let participantsNames = self.getParticipantsNameReturn
                            print("participantsNames test = \(String(describing: participantsNames))")
                            
                            let chatRoom = ChatRoom(roomID: roomID, participants: participants, isGroup: isGroup, chatName: chatName, chatPicture: chatPicture, messages: messages, participantsNames: participantsNames, lastMessage: lastMessage, timestamp: timestamp, readBy: readBy)
                            
                            // core data
                            // cek chat room-nya udah ada atau belum di CoreDataChatRoom
                            // kalau ada, di update-, kalau belum di add ke CoreDataChatRoom
                            // CoreDataChatRoom di appen ke Chat.rooms untuk ditampilkan di app
                            // Chat.roomIDs bisa tetap dipakai untuk add listener chat messages
                            
                            // alwan current task start
                            CoreDataManager.shared.updateCoreDataChatRoom(chatRoom: chatRoom)

                            CoreDataManager.shared.fetchChatRooms()
                            // alwan current task end
                            
                            
                            // alwan current task
                            // alwan comment start
//                            Chat.roomIDs.append(roomID)
//                            print("Chat.roomIDs = \(Chat.roomIDs)")
//
//                            Chat.rooms.append(chatRoom)
//                            print("Chat.rooms = \(Chat.rooms)")
//
//                            Chat.rooms = Chat.rooms.sorted(by: { $0.timestamp > $1.timestamp })
                            // alwan comment end
                            
                            // cara aslinya
        //                    if let chatRoomsTableView = Chat.firestoreChatVC?.chatRoomsTableView {
        //                        chatRoomsTableView.reloadData()
        //                    }
                            
                            firestoreChatViewController.chatRoomsTableView.reloadData()
                            // alwan current task
                            // posisi completion-nya salah
                            completion()
                            //
                            
                        })
                        //
                    }
                    
                    // kalau 1on1 chat
                    else {
                        var otherUserUID = String()
                        if userUID == participants[0] {
                            otherUserUID = participants[1]
                        }
                        else {
                            otherUserUID = participants[0]
                        }
                        
                        // cara untuk testing
                        // cara aslinya adalah kalau otherUserUID != userUID, cari nama dari otherUserUID
                        self.getUserName(userUID: otherUserUID, completion: {
                            chatName = self.getUserNameReturn ?? ""
                            
                            var lastMessage: String? = nil
                            if let lastMessageTemp = document.data()["last_message"] as? String {
                                lastMessage = lastMessageTemp
                            }
                            
                            guard let timestamp = document.data()["timestamp"] as? String else {
                                print("timestamp not found")
                                completion()
                                return
                            }
                            
                            var readBy: [String]? = nil
                            if let readByTemp = document.data()["read_by"] as? [String] {
                                readBy = readByTemp
                            }
                            
                            let messages: [ChatMessage]? = nil
                            
                            let participantsNames = self.getParticipantsNameReturn
                            
                            let chatRoom = ChatRoom(roomID: roomID, participants: participants, isGroup: isGroup, chatName: chatName, chatPicture: chatPicture, messages: messages, participantsNames: participantsNames, lastMessage: lastMessage, timestamp: timestamp, readBy: readBy)
                            
                            // core data
                            // cek chat room-nya udah ada atau belum di CoreDataChatRoom
                            // kalau ada, di update-, kalau belum di addke CoreDataChatRoom
                            // CoreDataChatRoom di appen ke Chat.rooms untuk ditampilkan di app
                            // Chat.roomIDs bisa tetap dipakai untuk add listener chat messages
                            
                            // alwan current task
                            // alwan comment start
//                            Chat.roomIDs.append(roomID)
//                            print("Chat,roomIDs = \(Chat.roomIDs)")
//
//                            Chat.rooms.append(chatRoom)
//                            print("Chat.rooms = \(Chat.rooms)")
//
//                            Chat.rooms = Chat.rooms.sorted(by: { $0.timestamp > $1.timestamp })
                            // alwan comment end
                            
                            // alwan test start
                            CoreDataManager.shared.updateCoreDataChatRoom(chatRoom: chatRoom)

                            CoreDataManager.shared.fetchChatRooms()
                            // alwan task end
                            
                            // cara aslinya
        //                    if let chatRoomsTableView = Chat.firestoreChatVC?.chatRoomsTableView {
        //                        chatRoomsTableView.reloadData()
        //                    }
                            
                            firestoreChatViewController.chatRoomsTableView.reloadData()
                            // alwan current task
                            // posisi completion-nya salah
                            completion()
                        })
                    }
                }
            }
            // alwan current task
//            completion()
        })
    }
    
    public func removeChatRoomsListener() {
        if Chat.chatRoomsListener != nil {
            Chat.chatRoomsListener?.remove()
            Chat.chatRoomsListener = nil
        }
    }
    
    // kalau ada satu document yang diambil dengan listener, yang gagal melewati guard, maka document lain juga akan berhenti di fetch
    // function ini harus dipanggil ulang setiap add listener untuk chat room ter-trigger, supaya jika ada perubahan room id yang harus di listen akan ter-update
    // aslinya di filter hanya document yang last_updated-nya > last_updated di local data
    public func addChatMessagesListener(userUID: String) {
        
        removeChatMessagesListener()
        
        guard Chat.roomIDs != [] else {
            print("Chat.roomIDs is empty")
            return
        }
        
        print("Chat.roomIDs = \(Chat.roomIDs)")
        
        print("\nStart listening to messages")
        
        Chat.chatMessagesListener = database.collection("chat_messages").whereField("room_id", in: Chat.roomIDs).addSnapshotListener({ querySnapshot, error in
            if let error = error {
                print("Failed to add chat messages listener: \(error)")
            }
            else {
                guard let querySnapshot = querySnapshot
                else {
                    print("querySnapshot not found")
                    return
                }
                
                for index in Chat.rooms.indices {
                    Chat.rooms[index].messages = []
                }
                
                for document in querySnapshot.documents {
                    guard let messageID = document.data()["message_id"] as? String
                    else {
                        print("messageID not found")
                        return
                    }
                    print("messageID = \(messageID)")
                    
                    guard let roomID = document.data()["room_id"] as? String
                    else {
                        print("roomID not found")
                        return
                    }
                    
                    guard let senderID = document.data()["sender_id"] as? String
                    else {
                        print("senderID not found")
                        return
                    }
                    
                    guard let timestamp = document.data()["timestamp"] as? String
                    else {
                        print("timestamp not found")
                        return
                    }
                    
                    guard let type = document.data()["type"] as? String
                    else {
                        print("type not found")
                        return
                    }
                    
                    guard type == "text" || type == "image" || type == "video"
                    else {
                        print("Unknown message type")
                        return
                    }
                    
                    guard let readBy = document.data()["read_by"] as? [String]
                    else {
                        print("readBy not found")
                        return
                    }
                    
                    guard let content = document.data()["content"] as? String else {
                        print("content not found")
                        return
                    }
                    
                    // alwan current task
                    // alwan test start
                    var status = String()
                    if senderID == userUID {
                        var chatRoom: ChatRoom?
                        for room in Chat.rooms {
                            if room.roomID == roomID {
                                chatRoom = room
                            }
                        }
                        
                        guard let chatRoom = chatRoom else {
                            print("chatRoom not found")
                            return
                        }
                        
                        if chatRoom.isGroup {
                            status = "Read by \(readBy.count)"
                        }
                        else {
                            if readBy.contains(chatRoom.participants[0]) && readBy.contains(chatRoom.participants[1]) {
                                status = "Read"
                            }
                        }
                        
                        status = "Sent"
                    }
                    // alwan test end
                    
                    // alwan current task
                    // alwan test start
                    let chatMessage = ChatMessage(messageID: messageID, roomID: roomID, senderID: senderID, timestamp: timestamp, type: type, readBy: readBy, content: content, status: status)
                    // alwan test end
                    
                    // core data
                    // cek chat message sudah ada atau belum di CoreDataChatMessage
                    // kalau sudah ada, di update, kalau sudah ada di add ke CoreDataChatMessage
                    // CoreDataChatMessage di looping lalu di appen ke Chat.rooms jika room-id nya sama, untuk ditampilkan
                    
                    // alwan current task start
                    print("addChatMessagesListener - chatMessage: \(chatMessage)")

                    CoreDataManager.shared.updateCoreDataChatMessage(chatMessage: chatMessage)

                    CoreDataManager.shared.fetchChatMessages()
                    // alwan current task end
                    
                    // alwan current task
                    // alwan comment start
//                    print("Chat message's room: \(chatMessage.roomID)")
//                    for index in Chat.rooms.indices {
//                        print("Checking room: \(Chat.rooms[index].roomID)")
//                        if Chat.rooms[index].roomID == chatMessage.roomID {
//                            Chat.rooms[index].messages?.append(chatMessage)
//
//                            Chat.rooms[index].messages = Chat.rooms[index].messages?.sorted(by: { $0.timestamp < $1.timestamp })
//                        }
//                    }
                    // alwan comment end
                }
                
                if let firestoreChatMessagesVC = Chat.firestoreChatMessagesVC {
                    for index in Chat.rooms.indices {
                        if Chat.rooms[index].roomID == firestoreChatMessagesVC.chatRoom?.roomID {
                            firestoreChatMessagesVC.chatRoom = Chat.rooms[index]
                        }
                    }
                    
                    firestoreChatMessagesVC.chatMessagesTableView.reloadData()
                    firestoreChatMessagesVC.readMessages()
                }
            }
            
            print("Done listening to messages\n")
        })
    }
    
    public func removeChatMessagesListener() {
        if Chat.chatMessagesListener != nil {
            Chat.chatMessagesListener?.remove()
            Chat.chatMessagesListener = nil
        }
    }
    
    // tambahin update last_updated nya
    public func createChatRoom(userUID: String, participants: [String], isGroup: Bool) {
        
        // room id-nya dibuat di local, depannya pakai user id, lalu validasi dulu di local ngga ada yang id-nya sama, lalu save di local dan kirim ke firestore
        // aslinya document ID dibuat di local, untuk testing masih pakai auto id karena tidak disimpan di local data
//        var roomID = String()
//        var isUniqueID = false
//        while isUniqueID == false {
//            let uuid = UUID().uuidString
//            roomID = "\(userUID)\(uuid)"
//
//            // cek di local data, chat rooms nya ada yang id nya sama atau ngga, kalau ngga ada isUniqueID = true
//        }
        
        var documentReference: DocumentReference?
        documentReference = database.collection("chat_rooms").addDocument(
            data: [
                "participants": participants,
                "is_group": isGroup
                // TAMBAHIN TIMESTAMP
            ],
            completion: { error in
                if let error = error {
                    print("Error creating chat room: \(error)")
                }
                else {
                    guard let documentReference = documentReference
                    else {
                        print("documentReference not found")
                        return
                    }
                    
                    print("Chat room created with ID: \(documentReference.documentID)")
                }
            })
        
    }
    
    // tambahin update last_updated nya
    public func sendChatMessage(userUID: String, room: String, timestamp: String, type: String, content: String) {
        
        // room id-nya dibuat di local, depannya pakai user id, lalu validasi dulu di local ngga ada yang id-nya sama, lalu save di local dan kirim ke firestore
        // aslinya document ID dibuat di local, untuk testing masih pakai auto id karena tidak disimpan di local data
//        var roomID = String()
//        var isUniqueID = false
//        while isUniqueID == false {
//            let uuid = UUID().uuidString
//            roomID = "\(userUID)\(uuid)"
//
//            // cek di local data, chat rooms nya ada yang id nya sama atau ngga, kalau ngga ada isUniqueID = true
//        }
        
        // message id dibuat di local caranya sama seperti room id
        // saat dikirim, disimpan di local dengan status pending, kalau sudah dapat read dari firestore baru status-nya diganti menjadi sent
        //id-nya digenerate locally, dan value id-nya diawali dengan userID yang mengirim message, jadi tidak mungkin sama dengan id yang di generate user lain saat sampai ke firestore
        
//        var messageID = String()
//        var isUniqueID = false
//        while isUniqueID == false {
//            let uuid = UUID().uuidString
//            messageID = "\(userUID)\(uuid)"
//
//            // cek di local data, chat messages nya ada yang id-nya sama atau ngga, kalau ngga ada isUniqueID = true
//        }
        
        // alwan current task start
        var messageID = String()
        var isUnique = false
        while isUnique == false {
            let uuid = UUID().uuidString
            messageID = "\(userUID)_\(uuid)"
            
            isUnique = CoreDataManager.shared.validateCoreDataChatMessageID(messageID: messageID)
        }
        // alwan current task end
        
        var documentReference: DocumentReference?
        documentReference = database.collection("chat_messages").addDocument(
            data: [
                "message_id": messageID,
                "sender_id": userUID,
                "room_id": room,
                "timestamp": timestamp,
                "type": type,
                "content": content,
                "read_by": [userUID]
            ],
            completion: { error in
                if let error = error {
                    print("Error sending chat message: \(error)")
                }
                else {
                    print("Success sending chat message: \(messageID)")
                    
//                    guard let documentReference = documentReference
//                    else {
//                        print("documentReference not found")
//                        return
//                    }
//
//                    print("Chat message sent with ID: \(documentReference.documentID)")
//
//                    self.database.collection("chat_messages").document(documentReference.documentID).setData(
//                        [
//                            "message_id": documentReference.documentID
//                        ],
//                        merge: true)
                }
            })
    }
    
    public func updateChatRoomLastMessage(userUID: String, roomID: String, timestamp: String, lastMessage: String) {
        database.collection("chat_rooms").whereField("room_id", isEqualTo: roomID).getDocuments(completion: { querySnapshot, error in

            if let error = error {
                print("Error getting chat room: \(error)")
            }
            else {
                guard let documents = querySnapshot?.documents
                else {
                    print("documents not found")
                    return
                }

                for document in documents {
                    document.reference.setData(
                        [
                            "last_message": lastMessage,
                            "timestamp": timestamp,
                            "read_by": [userUID]
                        ],
                        merge: true,
                        completion: { error in
                            if let error = error {
                                print("Failed to update chat room last message: \(error)")
                            }
                            else {
                                print("Successfully update last message for chat room id: \(roomID)")
                            }
                        })
                }
            }
        })
    }
    
    // ini seharusnya ngga ada, cuma chat message read yang di update
    public func updateChatRoomRead(userUID: String, roomID: String) {
        database.collection("chat_rooms").whereField("room_id", isEqualTo: roomID).getDocuments(completion: { querySnapshot, error in
            if let error = error {
                print("Failed to update chat room read: \(error)")
            }
            else {
                guard let querySnapshot = querySnapshot
                else {
                    print("querySnapshot not found")
                    return
                }

                for document in querySnapshot.documents {
                    document.reference.setData(
                        [
                            "read_by": FieldValue.arrayUnion([userUID])
                        ],
                        merge: true)
                }
            }
        })
    }
    
    public func updateChatMessageRead(userUID: String, messageID: String) {
        database.collection("chat_messages").whereField("message_id", isEqualTo: messageID).getDocuments(completion: { querySnapshot, error in
            if let error = error {
                print("Failed to update chat message read: \(error)")
            }
            else {
                guard let querySnapshot = querySnapshot
                else {
                    print("querySnapshot not found")
                    return
                }
                
                for document in querySnapshot.documents {
                    document.reference.setData(
                        [
                            "read_by": FieldValue.arrayUnion([userUID])
                        ],
                        merge: true)
                }
            }
        })
    }
    
    public func getUserName(userUID: String, completion: @escaping () -> Void) {
        print("Getting user's name for userUID: \(userUID)")
        
        database.collection("users").document(userUID).getDocument(completion: { documentSnapshot, error in
            
            if let error = error {
                print("Error to get user's name: \(error)")
                completion()
            }
            else {
                guard let documentSnapshot = documentSnapshot
                else {
                    print("documentSnapshot not found")
                    completion()
                    return
                }
                
                guard let documentData = documentSnapshot.data()
                else {
                    print("documentData not found")
                    completion()
                    return
                }
                
                guard let name = documentData["name"] as? String
                else {
                    print("name not found")
                    completion()
                    return
                }
                
                self.getUserNameReturn = name
                completion()
            }
        })
    }
    
    func getParticipantsName(participants: [String], completion: @escaping () -> Void) {
        
        let dispatchGroup = DispatchGroup()
        
        for participant in participants {
            
            dispatchGroup.enter()
            
            self.database.collection("users").document(participant).getDocument(completion: { documentSnapshot, error in
                if let error = error {
                    print("Failed to get participants names: \(error)")
                    dispatchGroup.leave()
                }
                else {
                    guard let documentData = documentSnapshot?.data() else {
                        print("documentData not found")
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let name = documentData["name"] as? String else {
                        print("name not found")
                        dispatchGroup.leave()
                        return
                    }
                    
                    self.getParticipantsNameReturn?.updateValue(name, forKey: participant)
                    print("getParticipantsNameReturn = \(self.getParticipantsNameReturn)")
                    dispatchGroup.leave()
                }
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    public func sendPushNotification(userUID: String, roomID: String, body: String) {
        
        database.collection("users").document(userUID).getDocument(completion: { documentSnapshot, error in
            if let error = error {
                print("Failed to get title for sending push notification: \(error)")
            }
            else {
                guard let documentSnapshot = documentSnapshot else {
                    print("documentSnapshot not found")
                    return
                }
                
                guard let documentData = documentSnapshot.data() else {
                    print("documentData not found")
                    return
                }
                
                guard let title = documentData["name"] as? String else {
                    print("title not found")
                    return
                }
                
                self.database.collection("chat_rooms").whereField("room_id", isEqualTo: roomID).getDocuments(completion: { querySnapshot, error in
                    if let error = error {
                        print("Failed to get participants when sending push notification: \(error)")
                    }
                    else {
                        guard let querySnapshot = querySnapshot else {
                            print("querySnapshot not found")
                            return
                        }
                        
                        for document in querySnapshot.documents {
                            guard let participants = document.data()["participants"] as? [String] else {
                                print("participants not found")
                                return
                            }
                            
                            for participant in participants {
                                
                                if participant != userUID {
                                    
                                    self.database.collection("users").document(participant).getDocument(completion: { documentSnapshot, error in
                                        if let error = error {
                                            print("Failed to get fcmToken when sending push notification: \(error)")
                                        }
                                        else {
                                            guard let documentData = documentSnapshot?.data() else {
                                                print("documentData not found")
                                                return
                                            }
                                            
                                            guard let to = documentData["fcm_token"] as? String else {
                                                print("to not found")
                                                return
                                            }
                                            
                                            print("to = \(to)")
                                            FCMManager.shared.sendPushNotification(to: to, title: title, body: body)
                                        }
                                    })
                                    
                                }
                            }
                        }
                    }
                })
            }
        })
        
    }
    
    
    // TESTING FUNCTIONS
    
//    public func testAddUser(firstName: String, middleName: String?, lastName: String, born: Int, completion: @escaping () -> Void){
//
//        print("addUser -\nfirstName: \(firstName), middleName: \(middleName), lastName: \(lastName), born: \(born)")
//
//        if let middleName = middleName {
//            // add collection "users"; add document ref.documentID; add fields "first", "middle", "last", "born"
//            ref = database.collection("users").addDocument(data: [
//                "first": firstName,
//                "middle": middleName,
//                "last": lastName,
//                "born": born
//            ]) { error in
//                if let error = error {
//                    print("Error adding user document: \(error)")
//                    completion()
//                }
//                else {
//                    guard let ref = self.ref
//                    else {
//                        print("ref not found")
//                        completion()
//                        return
//                    }
//
//                    print("Document added with ID: \(ref.documentID)")
//                    completion()
//                }
//            }
//        }
//        else {
//            ref = database.collection("users").addDocument(data: [
//                "first": firstName,
//                "last": lastName,
//                "born": born
//            ], completion: { error in
//                if let error = error {
//                    print("Error adding user document: \(error)")
//                    completion()
//                }
//                else {
//                    guard let ref = self.ref
//                    else {
//                        print("ref not found")
//                        completion()
//                        return
//                    }
//
//                    print("Document added with ID: \(ref.documentID)")
//                    completion()
//                }
//            })
//        }
//
//    }
//
//    public func testReadChatRooms(completion: @escaping () -> Void) {
//        database.collection("chats").getDocuments(completion: { querySnapshot, error in
//            print("\nreadAllChatRooms")
//
//            if let error = error {
//                print("Error getting chats: \(error)")
//                completion()
//            }
//            else {
//                guard let querySnapshot = querySnapshot
//                else {
//                    print("querySnapshot not found")
//                    completion()
//                    return
//                }
//
//                for document in querySnapshot.documents {
//                    print("\(document.documentID) => \(document.data())")
//                }
//
//                completion()
//            }
//        })
//    }
//
//    public func testReadChatRoom(completion: @escaping () -> Void) {
//        database.collection("chats").document("room1").getDocument(completion: { documentSnapshot, error in
//            print("\nreadChatRoom")
//
//            if let error = error {
//                print("Failed to read chat room: \(error)")
//                completion()
//            }
//            else {
//                guard let documentSnapshot = documentSnapshot, documentSnapshot.exists
//                else {
//                    print("document not found")
//                    completion()
//                    return
//                }
//
//                let dataDescription = documentSnapshot.data().map(String.init(describing:)) ?? "nil"
//                print("\(documentSnapshot.documentID) => \(dataDescription)")
//
//                completion()
//            }
//        })
//    }
//
//    public func testReadChatRoomMessages(completion: @escaping () -> Void) {
//        database.collection("chats").document("room1").collection("messages").getDocuments(completion: { querySnapshot, error in
//            print("\nreadChatRoomMessages")
//
//            if let error = error {
//                print("Failed to read chat room messages: \(error)")
//                completion()
//            }
//            else {
//                guard let querySnapshot = querySnapshot
//                else {
//                    print("documents not found")
//                    completion()
//                    return
//                }
//
//                for document in querySnapshot.documents {
//                    print("\(document.documentID) => \(document.data())")
//                }
//
//                completion()
//            }
//        })
//    }
//
//    public func testReadChatRoomMessage() {
//        database.collection("chats").document("room1").collection("messages").document("message1").getDocument(completion: { documentSnapshot, error in
//            print("\nreadChatMessage")
//
//            if let error = error {
//                print("Failed to read chat message: \(error)")
//            }
//            else {
//                guard let documentSnapshot = documentSnapshot, documentSnapshot.exists
//                else {
//                    print("documentSnapshot not found")
//                    return
//                }
//
//                guard let documentData = documentSnapshot.data()
//                else {
//                    print("documentData not found")
//                    return
//                }
//
//                print("\(documentSnapshot.documentID) => \(documentData)")
//
//                guard let documentDataMessage = documentData["message"]
//                else {
//                    print("documentDataMessage not found")
//                    return
//                }
//                print("documentDataMessage = \(documentDataMessage)")
//
//                var message1 = [String: Any]()
//                message1 = documentData
//                print("message1 = \(message1)")
//
//                guard let message1Message = message1["message"]
//                else {
//                    print("message1Message not found")
//                    return
//                }
//                print("message1Message = \(message1Message)")
//            }
//        })
//    }
//
//    func testChatsListener() {
//        if let chatsListener = chatRoomsListener {
//            chatsListener.remove()
//        }
//
//        chatRoomsListener = database.collection("chats").whereField("participants", arrayContains: "user1").addSnapshotListener({ querySnapshot, error in
//            print("\nChatsListener")
//
//            if let error = error {
//                print("Error listening to chats: \(error)")
//            }
//            else {
//                guard let querySnapshot = querySnapshot
//                else {
//                    print("querySnapshot not found")
//                    return
//                }
//
//                for document in querySnapshot.documents {
//                    print("\(document.documentID) => \(document.data())")
//                }
//            }
//        })
//    }
//
//    public func testRemoveChatsListener() {
//        guard let chatsListener = chatRoomsListener
//        else {
//            print("chatsListener not foun")
//            return
//        }
//
//        chatsListener.remove()
//    }
    
}
