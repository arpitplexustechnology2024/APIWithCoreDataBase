//
//  APIHalper.swift
//  APIWithCoreDataBase
//
//  Created by Arpit iOS Dev. on 15/06/24.
//

import Foundation
import Alamofire
import CoreData

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "APIWithCoreDataBase")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        })
        return container
    }()
    
    func getComments(completion: @escaping (APIState<[Comment]>) -> Void) {
        let url = "https://jsonplaceholder.typicode.com/comments"
        
        print("Fetching comments from API...")
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseJSON { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let comments = try JSONDecoder().decode([Comment].self, from: jsonData)
                        
                        // Save comments to Core Data
                        self.saveCommentsToCoreData(comments)
                        print("Successfully fetched comments from API: \(comments)")
                        completion(.success(comments))
                    } catch {
                        print("JSON parsing error: \(error)")
                        completion(.failure(.jsonParsingFailure))
                    }
                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        print("API request failed with status code: \(statusCode), error: \(error)")
                        completion(.failure(.responseUnsuccessful(statusCode: statusCode)))
                    } else {
                        print("API request failed with error: \(error)")
                        completion(.failure(.requestFailed))
                    }
                }
            }
    }
    
    private func saveCommentsToCoreData(_ comments: [Comment]) {
        persistentContainer.performBackgroundTask { context in
            do {
                for commentData in comments {
                    let comment = CommentEntity(context: context)
                    comment.postId = Int16(commentData.postId)
                    comment.id = Int16(commentData.id)
                    comment.name = commentData.name
                    comment.email = commentData.email
                    comment.body = commentData.body
                }
                try context.save()
                print("Saved comments to Core Data")
            } catch {
                print("Failed to save comments to Core Data: \(error)")
            }
        }
    }
    
    func fetchCommentsFromCoreData(completion: @escaping ([Comment]?) -> Void) {
        let request: NSFetchRequest<CommentEntity> = CommentEntity.fetchRequest()
        
        do {
            let comments = try persistentContainer.viewContext.fetch(request)
            let commentModels = comments.map { Comment(postId: Int($0.postId), id: Int($0.id), name: $0.name ?? "", email: $0.email ?? "", body: $0.body ?? "") }
            print("Fetched comments from Core Data: \(commentModels)")
            completion(commentModels)
        } catch {
            print("Failed to fetch comments from Core Data: \(error)")
            completion(nil)
        }
    }
}
