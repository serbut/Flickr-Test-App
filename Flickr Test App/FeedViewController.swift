//
//  ViewController.swift
//  Flickr Test App
//
//  Created by Sergey Butorin on 30/01/2018.
//  Copyright © 2018 Sergey Butorin. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    
    // MARK: Properties
    private var images = [UIImage]()
    private let rowHeight: CGFloat = 300
    
    @IBOutlet weak private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        DownloadManager.shared.startDownloads { imagesData in
            self.addImages(fromData: imagesData)
        }
    }
    
    private func addImages(fromData dataArray: [Data]) {
        for imageData in dataArray {
            if let image = UIImage(data: imageData) {
                self.images.append(image)
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                self.tableView.endUpdates()
            }
        }
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
        return rowHeight
    }
}
