//
//  ViewCalendrier.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 01/11/2022.
//  Copyright © 2022 Home. All rights reserved.
//

import UIKit

class ViewCalendrier: UIViewController {
    
    
    @IBOutlet weak var Scroller: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Scroller.contentSize = CGSize(width: 1000.0, height: Scroller.frame.size.height)


    }

}
