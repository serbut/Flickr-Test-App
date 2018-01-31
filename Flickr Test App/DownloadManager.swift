//
//  DownloadManager.swift
//  Flickr Test App
//
//  Created by Sergey Butorin on 31/01/2018.
//  Copyright © 2018 Sergey Butorin. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

class DownloadManager {
    
    static let shared = DownloadManager()
    
    private let apiUrl = "https://api.flickr.com/services/feeds/photos_public.gne"
    private var dataInBatch = [Data]()
    private var imageUrls = Set<URL>()
    private var downloadsInProgress = [URL : Alamofire.Request]()
    
    func startDownloads(completion: @escaping ([Data]) -> Void) {
        fetchFeedUrls(completion: completion)
    }
    
    func continueDownloads() {
        print("Continue")
        downloadsInProgress.forEach { $1.resume() }
    }
    
    func pauseDownloads() {
        print("Pause")
        downloadsInProgress.forEach { $1.suspend() }
    }
    
    private func fetchFeedUrls(completion: @escaping ([Data]) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(URL(string: apiUrl)!)
            .validate()
            .response { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard response.error == nil, let data = response.data else {
                    print("Error occured")
                    return
                }
                self.parsePhotoUrls(from: data, completion: completion)
        }
    }
    
    private func downloadBatch(completion: @escaping ([Data]) -> Void) {
        let batchSize = arc4random_uniform(5) + 1
        
        print("New batch downloading, batch size = \(batchSize)")
        
        for _ in 0..<batchSize {
            if imageUrls.isEmpty { return }
            let url = imageUrls.removeFirst()
            downloadImage(with: url, completion: completion)
        }
    }
    
    private func downloadImage(with url: URL, completion: @escaping ([Data]) -> Void) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .cachesDirectory)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let request = Alamofire.download(url, to: destination)
            .responseData { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let data = response.result.value {
                    self.dataInBatch.append(data)
                }
                self.downloadsInProgress[url] = nil
                
                if self.downloadsInProgress.isEmpty {
                    completion(self.dataInBatch)
                    self.dataInBatch = []
                    if !self.imageUrls.isEmpty {
                        self.downloadBatch(completion: completion)
                    }
                }
        }
        downloadsInProgress[url] = request
    }
    
    private func parsePhotoUrls(from data: Data, completion: @escaping ([Data]) -> Void) {
        let xml = SWXMLHash.parse(data)
        for entry in xml["feed"]["entry"].all {
            do {
                guard let urlString = try entry["link"].withAttribute("rel", "enclosure").element?.attribute(by: "href")?.text,
                    let url = URL(string: urlString) else {
                        print("Error while parsing URLs")
                        continue
                }
                imageUrls.insert(url)
            } catch {
                print("Error while parsing URLs")
            }
        }
        downloadBatch(completion: completion)
    }
}
