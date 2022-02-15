//
//  StorageManager.swift
//  Firebase Chat
//
//  Created by Admin on 21/12/21.
//

import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage(url: "gs://fir-chat-73aef.appspot.com").reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    // uploads picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data, filename: String, completion: @escaping UploadPictureCompletion) {
        
        // alwan comment: yang ini ga kebaca, jadi profile picture belum kesimpan di firebase
        storage.child("images/\(filename)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil
            else {
                print("Failed to upload to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                if let error = error {
                    print("Error uploading picture to firebase: \(error.localizedDescription)")
                }
                return
            }
            
            print("Upload picture to firebase success")
            
            self.storage.child("images/\(filename)").downloadURL(completion: { url, error in
                guard error == nil
                else {
                    if let error = error {
                        print("Get download url error: \(error)")
                    }
                    return
                }
                
                guard let url = url
                else {
                    print("Failed to get download url for picture")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned:\n url = \(url)\nurlString = \(urlString)")
                completion(.success(urlString))
            })
        })
        
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadUrl(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard error == nil
            else {
                print("downloadUrl error: \(error?.localizedDescription)")
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            guard let url = url
            else {
                print("url not found")
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        })
    }
    
}
