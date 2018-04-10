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



class HomeViewController : UIViewController {
    
    @IBOutlet weak var button: UIBarButtonItem!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var helpButton: UIButton!
    
    var dest: AVPlayerViewController?

    var queuePlayer: AVQueuePlayer?
    public var playerContext = 0
    var pap: [AVPlayerItem: Assignment] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helpButton.layer.cornerRadius = helpButton.layer.bounds.width/2
    
        
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
            var pi = (MediaHandler.sharedInstance.exerciseToPlayerItem(exercise: assignment.exercise), assignment)
            pi.0.addObserver(self,
                                   forKeyPath: #keyPath(AVPlayerItem.status),
                                   options: [.old, .new],
                                   context: &playerContext)
            
                pap.updateValue(pi.1, forKey: pi.0)
            return pi
            }.reduce(into: AVQueuePlayer()) { (partial, nextitem) in
                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nextitem.0, queue: OperationQueue.main, using: { (note) in
                        nextitem.1.complete = true
                })
                partial.insert(nextitem.0, after: nil)
                return
        }
        
        self.dest!.player = assetQueuePlayer
        self.dest!.player?.actionAtItemEnd = AVPlayerActionAtItemEnd.advance
        self.dest!.player?.play()
        let sideMenuControl = SideMenuManager.default.menuRightNavigationController!.topViewController as! SideMenuController
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
                    let thisAssign = pap[object as! AVPlayerItem]!
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
        (notification.object as! AVPlayerItem).removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    }
    @IBAction func helpRequested(_ sender: Any) {
        let alertController = UIAlertController.init(title: "Help Requested", message: "Uh-Oh, is there an issue you'd like your therapist to know about?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Send", style: .default) { (_) in
            let message = alertController.textFields?[0].text
            
            print(message)
            
            (self.dest?.player as! AVQueuePlayer).advanceToNextItem()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField {
            (textField) in
            textField.placeholder = "Enter Message"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

