//
//  HomeViewController.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/7/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

import AVFoundation
import AVKit
import NotificationCenter

enum HVCErrors: Error {
    case UnableToReferenceCurrentPlayerItemError
}

class HomeViewController : UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var button: UIBarButtonItem!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var helpButton: UIButton!
    
    var lastAssign: Assignment? = nil
    var lastAssignFinished: Bool = false
    var dest: AVPlayerViewController?
    var player: AVPlayer?
    

    var queuePlayer: AVQueuePlayer?
    public var playerContext = 0
    public var queueContext = 1
    var session: URLSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.isHidden = true
        SharedObjectManager.shared.playerAssignMap = [:]
        helpButton.layer.cornerRadius = helpButton.layer.bounds.width/2
    
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": SharedObjectManager.shared.auth_key!]
        session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
        
        let mh = MediaHandler(auth_key: SharedObjectManager.shared.auth_key!)
        MediaHandler.applyInstance(instance: mh)
       
        let menuRightNavigationController = storyboard!
            .instantiateViewController(withIdentifier: "RightMenuNavigationController")
            as! UISideMenuNavigationController
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.view)
        
        DispatchQueue.main.async {
            SharedObjectManager.shared.assignments!.forEach({ (assignment) in
                MediaHandler.sharedInstance.getExerciseThumbnail(exercise: assignment.exercise)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

         let assetQueuePlayer = SharedObjectManager.shared.assignments!.map { (assignment) -> (AVPlayerItem, Assignment) in
            let pi = (AVPlayerItem(url: URL(string: SharedObjectManager.shared.mainURL + "/api/video?id=\(assignment.exercise.id!)")!), assignment)
            pi.0.addObserver(self,
                                   forKeyPath: #keyPath(AVPlayerItem.status),
                                   options: [.old, .new],
                                   context: &playerContext)
            
                SharedObjectManager.shared.playerAssignMap!.updateValue(pi.1, forKey: pi.0)
            return pi
            }.reduce(into: AVQueuePlayer()) { (partial, nextitem) in
                NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nextitem.0)
        
                partial.insert(nextitem.0, after: nil)
                return
        }

        self.queuePlayer = assetQueuePlayer
        self.dest!.player = assetQueuePlayer
        self.dest!.player!.actionAtItemEnd = AVPlayerActionAtItemEnd.pause
        self.dest!.player!.play()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard context == &playerContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            switch status {
                case .readyToPlay:
                    
                    
                    let thisAssign = SharedObjectManager.shared.playerAssignMap![object as! AVPlayerItem]!
                    if (SharedObjectManager.shared.fin_unfin_count.1 == 1) {
                        lastAssign = thisAssign
                    }
                    thisAssign.state = .inProgress
                    print("Ready to play!")
                    titleLabel.text! = thisAssign.exercise.title
                    descriptionLabel.text! = thisAssign.exercise.description

                case .failed:
                    // Player item failed. See error.
                    print("Failed")
                case .unknown:
                    // Player item is not yet ready.
                    print("unknown error")
            }
        }
    }
    
    @IBAction func openMenu(_ sender: Any) {
        present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: {
        
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AVPlayerViewController
        self.dest = destination
        
    }
    @objc func itemDidFinishPlaying(_ notification: Notification) -> Void {
        
        
        print("ITEM DID FINISH: \(notification)")
        let playerItem = notification.object as! AVPlayerItem
        let thisAssign = SharedObjectManager.shared.playerAssignMap![playerItem]!
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    
        let dg = DispatchGroup()
        let req = NSMutableURLRequest(url: URL(string: SharedObjectManager.shared.mainURL + "/api/history/add?assignmentId=\(SharedObjectManager.shared.playerAssignMap![playerItem]!.id!)")!)
        req.httpMethod = "POST"
        dg.enter()
        let task = self.session!.dataTask(with: req as URLRequest) { (data, resp, err) in
            guard err == nil else {
                return
            }
            SharedObjectManager.shared.playerAssignMap![playerItem]!.state = .completed
            dg.leave()
        }
        task.resume()
        dg.notify(queue: DispatchQueue.main) {
            let current = SharedObjectManager.shared.playerAssignMap!.mapValues {
                (assign) in
                assign.state
                }.reduce((0, 0), { (d_nd, pi_as) -> (Int, Int) in
                    var complete = d_nd.0
                    var incomplete = d_nd.1
                    if(pi_as.value == AssignmentState.completed || pi_as.value == AssignmentState.unfinishedWithFeedback) {
                        complete += 1
                    } else {
                        incomplete += 1
                    }
                    return (complete, incomplete)
                })
            SharedObjectManager.shared.fin_unfin_count = current
            if(self.lastAssign != nil && self.lastAssign! === thisAssign) {
                print("LAST ASSIGNMENT FINISHED")
                self.lastAssignFinished = true
                self.continueButton.titleLabel?.text! = "Finish Up For Today!"
            }
             self.continueButton.isHidden = false
            
        }
    }
    @IBAction func helpRequested(_ sender: Any) {
        let alertController = UIAlertController.init(title: "Help Requested", message: "Uh-Oh, is there an issue you'd like your therapist to know about?", preferredStyle: .alert)
        
        self.queuePlayer!.pause()
        
        let confirmAction = UIAlertAction(title: "Send", style: .default) { (_) in
            let message: String = alertController.textFields![0].text!
            guard let playerItem = self.queuePlayer?.currentItem else {
                return
            }

            let relevantAssignment = SharedObjectManager.shared.playerAssignMap![playerItem]!
            let exerciseId = relevantAssignment.exercise.id!
            let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

            let url = URL(string: SharedObjectManager.shared.mainURL + "/api/history/feedbackAdd?exerciseId=\(exerciseId)&feedback=\(encodedMessage)")!
            let req = NSMutableURLRequest(url: url)
            req.httpMethod = "POST"
            let task = self.session!.dataTask(with: req as URLRequest) { (data, resp, err) in
                guard err == nil else {
                    return
                }
                SharedObjectManager.shared.playerAssignMap![playerItem]!.state = .unfinishedWithFeedback
            }
            task.resume()
            
            (self.dest?.player as! AVQueuePlayer).advanceToNextItem()
            (self.dest?.player as! AVQueuePlayer).play()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.queuePlayer!.play()
        }
        
        alertController.addTextField {
            (textField) in
            textField.placeholder = "Enter Message"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func continuePressed(_ sender: Any) {
        if self.lastAssignFinished  {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "WelcomeView")
            self.present(vc, animated: true, completion: nil)
        } else {
            (self.dest?.player as! AVQueuePlayer).advanceToNextItem()
            (self.dest?.player as! AVQueuePlayer).play()
        }
        self.continueButton.isHidden = true
    }
    
}

