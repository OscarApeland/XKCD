//
//  ViewController.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: ContentViewController {

    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        proxies = [
        
        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ComicFetcher.refreshComics()
    }
}

