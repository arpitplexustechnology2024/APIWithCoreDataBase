//
//  Model.swift
//  APIWithCoreDataBase
//
//  Created by Arpit iOS Dev. on 15/06/24.
//

import Foundation

struct Comment: Codable {
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}
