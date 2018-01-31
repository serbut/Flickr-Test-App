//
//  TabBarViewController.swift
//  Flickr Test App
//
//  Created by Sergey Butorin on 31/01/2018.
//  Copyright © 2018 Sergey Butorin. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        // Do any additional setup after loading the view.
    }
}

extension TabBarViewController : UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 1: // Blank View Controller
            DownloadManager.shared.pauseDownloads()
        case 2: // Feed View Controller
            DownloadManager.shared.continueDownloads()
        default:
            return
        }
    }
}
