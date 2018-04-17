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

private class CacheHandler {
    static let shared = CacheHandler()
    private var items: [URL] = []
    private let fileManager = FileManager()
    private lazy var mainDirectoryUrl: URL = {
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("TheraMe_MediaCache", isDirectory: true)
        if(!fileManager.fileExists(atPath: documentsUrl.path)) {
            do {
                try fileManager.createDirectory(atPath: documentsUrl.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }

        print("DOCS URL: \(documentsUrl.path)\n")
        return documentsUrl
    }()
    deinit {
        items.forEach { (storedItem) in
            if (fileManager.fileExists(atPath: storedItem.path)) {
                do {
                    try fileManager.removeItem(atPath: storedItem.path)
                } catch {
                    print(error)
                    print("\n")
                }
            }
        }
    }
    func putVideo(exerciseId: String, tempUrl: URL) {
        print("\n")
        let newPath: URL = mainDirectoryUrl.appendingPathComponent(exerciseId).appendingPathExtension("mp4")
        guard !fileManager.fileExists(atPath: newPath.path) else {
            print("FILE EXISTS: \(newPath)")
            DispatchQueue.global().async {
                if let videoData = NSData(contentsOf: tempUrl) {
                    self.fileManager.createFile(atPath: newPath.path, contents: videoData as Data)
                }
            }
            return
        }
        
        do {
            try fileManager.replaceItemAt(newPath, withItemAt: tempUrl, backupItemName: nil, options: [])
        } catch {
            print(error)
        }
    }

    func getVideo(exerciseId: String) -> AVAsset? {
        guard fileManager.fileExists(atPath: mainDirectoryUrl.appendingPathComponent(exerciseId)
            .appendingPathExtension("mp4").path) else {
            return nil
        }
        let asset = AVAsset(url: mainDirectoryUrl.appendingPathComponent(exerciseId))
        print(asset.allMediaSelections )
        return asset
    }
    private func directoryFor(stringUrl: String) -> URL {
        let fileURL = URL(string: stringUrl)!.lastPathComponent
        let file = self.mainDirectoryUrl.appendingPathComponent(fileURL)
        return file
    }
    
}

class MediaHandler: NSObject, AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("\n\n=== FINISHED DOWNLOAD ===")
        print("Task:\n")
        print(downloadTask)
        print("location:\n")
        print(location)
        print()
    }
    
    static var shared: MediaHandler?
    var session: URLSession? = nil
    var assetSession: AVAssetDownloadURLSession? = nil
    var dq: OperationQueue? = nil
    init(auth_key: String) {
        super.init()
        dq = OperationQueue()
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": auth_key]
        self.session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
        if SharedObjectManager.shared.thumbnails == nil {
            SharedObjectManager.shared.thumbnails = [:]
        }

        
        let bkgrdConfig = URLSessionConfiguration.background(withIdentifier: "assetDownloadSession")
        bkgrdConfig.httpAdditionalHeaders = ["Authorization": auth_key]
        self.assetSession = AVAssetDownloadURLSession(configuration: bkgrdConfig, assetDownloadDelegate: self as! AVAssetDownloadDelegate, delegateQueue: OperationQueue.main)
        self.assetSession!.getAllTasks { tasksArray in
            // For each task, restore the state in the app
            for task in tasksArray {
                guard let downloadTask = task as? AVAssetDownloadTask else { break }
                // Restore asset, progress indicators, state, etc...
                let asset = downloadTask.urlAsset
                print(asset)
            }
        }
        
    }

    
    func getExerciseThumbnail(exercise: Exercise) -> UIImage? {
        let dispatchGroup = DispatchGroup()
        var returnImage: UIImage? = nil
        guard let id = exercise.id else {
            return nil
        }
        
        if var thumbnails = SharedObjectManager.shared.thumbnails {
            dispatchGroup.enter()
            if let preStored = thumbnails[id] {
                return preStored
            }
            else {
                let task = self.session!.dataTask(with: URL(string: SharedObjectManager.shared.mainURL + "/api/thumbnail?id=\(id)")!) {
                    (data, response, error) in
                    if let error = error {

                        dispatchGroup.leave()
                        return
                    }
                    guard let data = data else {
                        dispatchGroup.leave()
                        return
                    }
                    if let img = UIImage(data: data) {
                        returnImage = img
                        SharedObjectManager.shared.thumbnails!.updateValue(img.copy() as! UIImage, forKey: id)
                        dispatchGroup.leave()
                        
                    } else {
                        dispatchGroup.leave()
                    }
                }
                task.resume()
                }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            print("Finished retrieving Thumbnails!")
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
