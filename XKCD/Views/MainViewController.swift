//
//  ViewController.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {

    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        token = try! Realm()
            .objects(XKCD.self).sorted(byKeyPath: "number", ascending: false)
            .observe { change in
                print(change)
            }
        
        ComicFetcher.refreshComics()
    }
}

