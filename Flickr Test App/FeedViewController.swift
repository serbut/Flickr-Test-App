//
//  ViewController.swift
//  Flickr Test App
//
//  Created by Sergey Butorin on 30/01/2018.
//  Copyright © 2018 Sergey Butorin. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

class FeedViewController: UIViewController {

    private let apiUrl = "https://api.flickr.com/services/feeds/photos_public.gne"
    
    // MARK: Properties
    private var images = [UIImage]()
    private var imagesInBatch = [UIImage]()
    private var imageUrls = Set<URL>()
    private var downloadsInProgress = [URL : Alamofire.Request]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchFeedUrls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadsInProgress.forEach { $1.resume() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        downloadsInProgress.forEach { $1.suspend() }
    }
}

// MARK: TableViewDataSource
extension FeedViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
        
        cell.photoImageView.image = images.reversed()[indexPath.row]
        
        return cell
    }
}

// MARK: TableViewDelegate
extension FeedViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
}

// MARK: Networking
extension FeedViewController {
    private func fetchFeedUrls() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(URL(string: apiUrl)!)
            .validate()
            .response { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard response.error == nil, let data = response.data else {
                    print("Error occured")
                    return
                }
                self.parsePhotoUrls(from: data)
        }
    }
    
    private func downloadBatch() {
        let batchSize = arc4random_uniform(5) + 1
        
        print("New batch downloading, batch size = \(batchSize)")
        
        for _ in 0..<batchSize {
            if imageUrls.isEmpty { return }
            let url = imageUrls.removeFirst()
            downloadImage(with: url)
        }
    }
    
    private func downloadImage(with url: URL) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .cachesDirectory)
        let request = Alamofire.download(url, to: destination)
            .responseData { response in
            if let data = response.result.value,
                let image = UIImage(data: data) {
                self.imagesInBatch.append(image)
            }
            self.downloadsInProgress[url] = nil
            
            if self.downloadsInProgress.isEmpty {
                self.addImagesFromNewBatch()
                if !self.imageUrls.isEmpty {
                    self.downloadBatch()
                }
            }
        }
        downloadsInProgress[url] = request
    }
}

// MARK: Helpers
extension FeedViewController {
    private func parsePhotoUrls(from data: Data) {
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
        downloadBatch()
    }
    
    private func addImagesFromNewBatch() {
        for image in imagesInBatch {
            images.append(image)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        imagesInBatch = []
    }
}
