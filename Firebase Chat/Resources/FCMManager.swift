//
//  FCMManager.swift
//  Firebase Chat
//
//  Created by Admin on 4/2/22.
//

import UIKit

final class FCMManager {
    static let shared = FCMManager()
    private let serverKey = "AAAA8KWJA0I:APA91bFBlE7R00yjdIhmEzJ9HEa6HF1Evzhkq-sfVXwf94qfIf39OlYgtRohzn_ssKeNILlmrW7Xkg-1UKstLM9NCufeXefrqlPDSnYIJZpW0SWgTilT4vi5euVvqbRZRjw7mSmM_HPi"
}

extension FCMManager {
    
    public func sendPushNotification(receiverFCMToken token: String, title: String, body: String) {
            let urlString = "https://fcm.googleapis.com/fcm/send"
            let url = NSURL(string: urlString)!
            let paramString: [String : Any] = ["to" : token,
                                               "notification" : ["title" : title, "body" : body],
                                               "data" : ["user" : "test_id"]
            ]
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
            let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
                do {
                    if let jsonData = data {
                        if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                            NSLog("Received data:\n\(jsonDataDict))")
                        }
                    }
                } catch let err as NSError {
                    print(err.debugDescription)
                }
            }
            task.resume()
        }
    
}
