//
//  SaisonFicheDetails.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 24/08/2025.
//  Copyright © 2025 Home. All rights reserved.
//

import UIKit


class CellRecapYoutube: UITableViewCell {
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var descr: UITextView!
    @IBOutlet weak var channel: UILabel!
    @IBOutlet weak var thumb: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var duree: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var langue: UIImageView!
    
    var videoID : String = ""
}


class SaisonFicheDetails: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var serie : Serie = Serie(serie: "")
    var saison : Int = 0
    
    var allVids : [YoutubeVideo] = []
    
    @IBOutlet weak var tableRecaps: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        allVids = youtube.searchRecap(serie: serie.serie, Season: saison-1)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allVids.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailRecap", for: indexPath) as! CellRecapYoutube
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? SerieColor2 : SerieColor1
        
        cell.titre.text = allVids[indexPath.row].titre
        cell.descr.text = allVids[indexPath.row].description
        cell.channel.text = allVids[indexPath.row].channel
        cell.thumb.image = loadImage(allVids[indexPath.row].thumbnails)
        cell.date.text = dateFormShort.string(from: allVids[indexPath.row].date)
        cell.duree.text = allVids[indexPath.row].duree
        cell.likes.text = allVids[indexPath.row].likes
        cell.langue.image = getDrapeau(country: allVids[indexPath.row].langue.uppercased())
        
        
        cell.videoID = allVids[indexPath.row].videoID
                
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.open(URL(string: "youtube://\(allVids[indexPath.row].videoID)")!)
    }
    
}

