//
//  CommentViewModel.swift
//  APIWithCoreDataBase
//
//  Created by Arpit iOS Dev. on 15/06/24.
//

import Foundation
import UIKit

class CommentsViewModel {
    var comments: [Comment] = []
    var apiState: APIState<[Comment]> = .loading(false) {
        didSet {
            DispatchQueue.main.async {
                self.onStateChange?(self.apiState)
            }
        }
    }
    
    var onStateChange: ((APIState<[Comment]>) -> Void)?
    var onNoInternetConnection: (() -> Void)?
    
    func fetchData() {
        if Reachability.shared.isConnectedToNetwork() {
            fetchCommentsFromAPI()
        } else {
            fetchCommentsFromCoreData()
            onNoInternetConnection?()
        }
    }
    
    private func fetchCommentsFromAPI() {
        apiState = .loading(true)
        NetworkManager.shared.getComments { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let comments):
                self.comments = comments
                self.apiState = .success(comments)
                print("Successfully fetched comments from API: \(comments)")
            case .failure(let error):
                self.apiState = .failure(error)
                print("Failed to fetch comments from API: \(error)")
            case .loading(_):
                break
            }
        }
    }
    
    private func fetchCommentsFromCoreData() {
        NetworkManager.shared.fetchCommentsFromCoreData { [weak self] comments in
            guard let self = self else { return }
            if let comments = comments {
                self.comments = comments
                self.apiState = .success(comments)
            } else {
                self.apiState = .failure(.custom(message: "Failed to fetch comments from Core Data"))
            }
        }
    }
}
