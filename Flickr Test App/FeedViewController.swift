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
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("appeared")
    }

    override func viewDidDisappear(_ animated: Bool) {
        print("disappeared")
    }

}

extension FeedViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
        
        cell.photoImageView.image = images[indexPath.row]
        
        return cell
    }
}
