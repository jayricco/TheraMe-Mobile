//
//  VideoHandler.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/8/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MediaHandler {
    static var shared: MediaHandler?
    var session: URLSession
    var assetSession: AVAssetDownloadURLSession
    init(auth_key: String) {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": auth_key]
        self.session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
        if SharedObjectManager.shared.thumbnails == nil {
            SharedObjectManager.shared.thumbnails = [:]
        }
        let bkgrdConfig = URLSessionConfiguration.background(withIdentifier: "assetDownloadSession")
        bkgrdConfig.httpAdditionalHeaders = ["Authorization": auth_key]
        self.assetSession = AVAssetDownloadURLSession(configuration: bkgrdConfig, assetDownloadDelegate: nil, delegateQueue: OperationQueue.main)
        assetSession.getAllTasks { tasksArray in
            // For each task, restore the state in the app
            for task in tasksArray {
                guard let downloadTask = task as? AVAssetDownloadTask else { break }
                // Restore asset, progress indicators, state, etc...
                let asset = downloadTask.urlAsset
                print(asset)
            }
        }
    }
    
    func exerciseToPlayerItem(exercise: Exercise) -> AVPlayerItem {
        
        let assetKeys = [
            "playable",
            "hasProtectedContent"
        ]
        let asset = AVURLAsset(url: URL(string: "https://localhost:8443/api/video?id=\(exercise.id!)")!)
        let dltask = self.assetSession.makeAssetDownloadTask(asset: asset, assetTitle: exercise.title, assetArtworkData: nil , options: nil)!
        dltask.resume()
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
        
        return playerItem
    }
    
    func getExerciseThumbnail(exercise: Exercise) -> UIImage? {
        let dispatchGroup = DispatchGroup()
        var returnImage: UIImage? = nil
        guard let id = exercise.id else {
            print("Exercise id is bad?\n\(exercise)")
            return nil
        }
        
        if var thumbnails = SharedObjectManager.shared.thumbnails {
            dispatchGroup.enter()
            if let preStored = thumbnails[id] {
                print("Found thumbnail for \"\(id)\" already!")
                return preStored
            }
            else {
                print("Did not find thumbnail yet")

                let task = self.session.dataTask(with: URL(string: "https://localhost:8443/api/thumbnail?id=\(id)")!) {
                    (data, response, error) in
                    if let error = error {

                        dispatchGroup.leave()
                        return
                    }
                    guard let data = data else {
                        print("Thumbnail data was nil...")
                        dispatchGroup.leave()
                        return
                    }
                    if let img = UIImage(data: data) {
                        returnImage = img
                        print("SETTING IMG: \(img)")
                        SharedObjectManager.shared.thumbnails!.updateValue(img.copy() as! UIImage, forKey: id)
                        dispatchGroup.leave()
                        
                    } else {
                        print("something else bad happened")
                        dispatchGroup.leave()
                    }
                    
                }
                task.resume()
                }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            print(returnImage)
        }
        return returnImage
    }
    
    class func applyInstance(instance: MediaHandler) -> Void {
        shared = instance
    }
    class var sharedInstance: MediaHandler {
        return shared!
    }
    
    
}
