//
//  Assignment.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/8/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation

public enum AssignmentState: Int {
    case awaitingCompletion = 0
    case inProgress = 1
    case completed = 2
    case unfinishedWithFeedback = 3
}

class Assignment {
    var id: String?
    var exercise: Exercise
    var dateAssigned: TimeInterval
    var order: Int
    var last_completed: String?
    var state: AssignmentState
    
    required init(exercise: Exercise, dateAssigned: TimeInterval, order: Int) {
        self.id = nil
        self.exercise = exercise
        self.dateAssigned = dateAssigned
        self.order = order
        self.last_completed = nil
        self.state = .awaitingCompletion
    }
    
    init(id: String, exercise: Exercise, dateAssigned: TimeInterval, order: Int, last_completed: String?) {
        self.id = id
        self.exercise = exercise
        self.dateAssigned = dateAssigned
        self.order = order
        self.last_completed = last_completed
        self.state = .awaitingCompletion
    }
}
extension Assignment {
    convenience init(json: [String: Any]) {

        self.init(id: json["id"] as! String,
                  exercise: Exercise(json: json["exercise"] as! [String: Any]),
                  dateAssigned: json["dateAssigned"] as! TimeInterval,
                  order: json["order"] as! Int,
                  last_completed: json["last_completed"] as? String)
    }
    
}
