//
//  Exercise.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/8/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation

class Exercise {
    var id: String?
    var title: String
    var description: String
    var mediaUrl: String
    var runTime: String
    
    required init(title: String, description: String, runTime: String)
    {
        self.id = nil
        self.title = title
        self.description = description
        self.mediaUrl = "https://localhost:8443"
        self.runTime = runTime
    }
    init(id: String, title: String, description: String, mediaUrl: String, runTime: String) {
        self.id = id
        self.title = title
        self.description = description
        self.mediaUrl = mediaUrl
        self.runTime = runTime
    }
}
extension Exercise {
    convenience init(json: [String: Any]) {
        self.init(id: json["id"] as! String,
                  title: json["title"] as! String,
                  description: json["description"] as! String,
                  mediaUrl: json["mediaUrl"] as! String,
                  runTime: json["runTime"] as! String)
    }
}
