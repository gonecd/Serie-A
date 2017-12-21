//
//  SerieFiche.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit

class SerieFiche: UIViewController {
    
    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()

    @IBOutlet weak var resume: UITextView!
    @IBOutlet weak var banniere: UIImageView!
    @IBOutlet weak var graphe: Graph!
    @IBOutlet weak var iconeStatus: UIImageView!
    @IBOutlet weak var network: UILabel!
    
    @IBOutlet weak var genre1: UIImageView!
    @IBOutlet weak var genre2: UIImageView!
    @IBOutlet weak var genre3: UIImageView!
    @IBOutlet weak var genre4: UIImageView!
    @IBOutlet weak var genre5: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        resume.text = serie.resume
        banniere.image = image
        graphe.sendSerie(serie)
        if (serie.status == "Ended")
            { iconeStatus.image = #imageLiteral(resourceName: "TheEnd.png") }
        else
            { iconeStatus.image = #imageLiteral(resourceName: "ToBeContinued.png") }

        for i in 0...4
        {
            if (i > serie.genres.count-1) { serie.genres.append("") }
        }
        
        genre1.image = genreIcone(unGenre: serie.genres[0])
        genre2.image = genreIcone(unGenre: serie.genres[1])
        genre3.image = genreIcone(unGenre: serie.genres[2])
        genre4.image = genreIcone(unGenre: serie.genres[3])
        genre5.image = genreIcone(unGenre: serie.genres[4])

        network.text? = serie.network
    }

    func genreIcone(unGenre: String) -> UIImage
    {
        switch unGenre {
        case "Action":
            return #imageLiteral(resourceName: "action.png")
        case "Adventure":
            return #imageLiteral(resourceName: "adventure.png")
        case "Animation":
            return #imageLiteral(resourceName: "animation.png")
        case "Comedy":
            return #imageLiteral(resourceName: "comedy.png")
        case "Crime":
            return #imageLiteral(resourceName: "crime.png")
        case "Drama":
            return #imageLiteral(resourceName: "drama.png")
        case "Fantasy":
            return #imageLiteral(resourceName: "fantasy.png")
        case "Horror":
            return #imageLiteral(resourceName: "horror.png")
        case "Mini-Series":
            return #imageLiteral(resourceName: "mini-series.png")
        case "Mystery":
            return #imageLiteral(resourceName: "mystery.png")
        case "Romance":
            return #imageLiteral(resourceName: "romance.png")
        case "Science-Fiction":
            return #imageLiteral(resourceName: "science-fiction.png")
        case "Thriller":
            return #imageLiteral(resourceName: "thriller.png")
        case "Western":
            return #imageLiteral(resourceName: "western.png")
        case "":
            return UIImage()
        default:
            print("Genre inconnu : \(unGenre)")
            return #imageLiteral(resourceName: "random.png")
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func graphe(_ sender: Any) {
        graphe.change()
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
