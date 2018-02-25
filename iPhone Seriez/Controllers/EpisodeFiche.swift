//
//  EpisodeFiche.swift
//  SerieA
//
//  Created by Cyril Delamare on 20/01/2018.
//  Copyright © 2018 Home. All rights reserved.
//


import UIKit

class EpisodeFiche : UIViewController {

    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()
    var saison : Int = 0
    var episode : Int = 0
    
    @IBOutlet weak var resume: UITextView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var banniere: UIImageView!
    
    @IBOutlet weak var graphe: GraphEpisode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM yy"

        resume.text = serie.saisons[saison - 1].episodes[episode - 1].resume
        titre.text = serie.saisons[saison - 1].episodes[episode - 1].titre
        date.text = dateFormatter.string(from: serie.saisons[saison - 1].episodes[episode - 1].date)
        banniere.image = image
        graphe.sendEpisode(serie.saisons[saison - 1].episodes[episode - 1])
    }
    
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func webTrakt(_ sender: AnyObject) {
        let myURL : String = "http://trakt.tv/shows/\(serie.serie.lowercased().replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: "'", with: "-"))"
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func webTheTVdb(_ sender: AnyObject) {
        let myURL : String = "https://www.thetvdb.com/?tab=series&id=\(serie.idTVdb)"
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func webRottenTomatoes(_ sender: AnyObject) {
        let myURL : String = "http://www.rottentomatoes.com/tv/\(serie.serie.lowercased().replacingOccurrences(of: "'", with: "_").replacingOccurrences(of: " ", with: "_"))"
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func webIMdb(_ sender: AnyObject) {
        let myURL : String = "http://www.imdb.com/title/\(serie.idIMdb)"
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func webBetaSeries(_ sender: AnyObject) {
        let myURL : String = "https://www.betaseries.com/serie/\(serie.serie.lowercased().replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "-"))"
        UIApplication.shared.open(URL(string: myURL)!)
    }
}
