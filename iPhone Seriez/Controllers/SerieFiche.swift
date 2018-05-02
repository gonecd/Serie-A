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
    @IBOutlet weak var network: UILabel!
    @IBOutlet weak var genre: UITextView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var roue: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        resume.text = serie.resume
        banniere.image = image
        //graphe.backgroundColor = colorBackground
        graphe.sendSerie(serie)

        // Affichage des genres
        var allGenres : String = ""
        for unGenre in serie.genres
        {
            allGenres = allGenres + unGenre + " "
        }
        genre.text = allGenres

        // Affichage du status
        status.layer.cornerRadius = 8
        status.layer.masksToBounds = true
        if (serie.status == "Ended")
        {
            status.text = "FINIE"
            status.textColor = UIColor.black
        }
        else
        {
            status.text = "EN COURS"
            status.textColor = UIColor.blue
        }

        network.layer.cornerRadius = 8
        network.layer.masksToBounds = true
        network.text? = serie.network
        
        theTVdb.getSerieInfosLight(uneSerie: serie)
        
        DispatchQueue.global(qos: .utility).async {
            
            DispatchQueue.main.async { self.roue.startAnimating() }

            if (self.serie.idTVdb != "") { theTVdb.getEpisodesRatings(self.serie) }
            self.graphe.sendSerie(self.serie)
            DispatchQueue.main.async { self.graphe.setNeedsDisplay() }
            
            if (self.serie.idTrakt != "") { trakt.getEpisodesRatings(self.serie) }
            self.graphe.sendSerie(self.serie)
            DispatchQueue.main.async { self.graphe.setNeedsDisplay() }
            
            if (self.serie.idTVdb != "") { betaSeries.getEpisodesRatings(self.serie) }
            self.graphe.sendSerie(self.serie)
            DispatchQueue.main.async { self.graphe.setNeedsDisplay() }
            
            if (self.serie.idMoviedb != "") { theMoviedb.getEpisodesRatings(self.serie) }
            self.graphe.sendSerie(self.serie)
            DispatchQueue.main.async { self.graphe.setNeedsDisplay() }
            
            imdb.getEpisodesRatings(self.serie)
            self.graphe.sendSerie(self.serie)
            DispatchQueue.main.async { self.graphe.setNeedsDisplay() }

            db.saveDB()
            
            DispatchQueue.main.async { self.roue.stopAnimating() }
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
