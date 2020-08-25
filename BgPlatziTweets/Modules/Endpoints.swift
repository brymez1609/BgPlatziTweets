//
//  Endpoints.swift
//  BgPlatziTweets
//
//  Created by Bryan Andres Gomez Hernandez on 8/25/20.
//  Copyright © 2020 Bryan Andres Gomez Hernandez. All rights reserved.
//

import Foundation
struct Endpoints {
    static let domain = "https://platzi-tweets-backend.herokuapp.com/api/v1"
    static let login = Endpoints.domain + "/auth"
    static let register = Endpoints.domain + "/register"
    static let getPosts = Endpoints.domain + "/posts"
    static let post = Endpoints.domain + "/posts"
    static let delete = Endpoints.domain + "/posts/"
}
