//
//  SerieFiche.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit

class CellSaison: UITableViewCell {
    @IBOutlet weak var saison: UILabel!
    @IBOutlet weak var debut: UILabel!
    @IBOutlet weak var fin: UILabel!
}

class CellComment: UITableViewCell {
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var date: UILabel!
}


class SerieFiche: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()
    var webOpinions : (comments : [String], likes : [Int], dates : [Date], source : [Int]) = ([], [], [], [])
    
    @IBOutlet weak var resume: UITextView!
    @IBOutlet weak var banniere: UIImageView!
    @IBOutlet weak var graphe: Graph!
    @IBOutlet weak var network: UILabel!
    @IBOutlet weak var genre: UITextView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var roue: UIActivityIndicatorView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var annee: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var viewResume: UIView!
    @IBOutlet weak var viewInfos: UIView!
    @IBOutlet weak var viewSaisons: UITableView!
    @IBOutlet weak var viewComments: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)

        titre.text = serie.serie
        annee.text = "(" + String(serie.year) + ")"
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
        self.graphe.sendSerie(self.serie)
        self.graphe.setNeedsDisplay()
        
        theTVdb.getSerieInfosLight(uneSerie: serie)
        
        DispatchQueue.global(qos: .utility).async {
            
            DispatchQueue.main.async { self.roue.startAnimating() }

            self.webOpinions = trakt.getComments(IMDBid: self.serie.idIMdb, season: 0, episode: 0)
            DispatchQueue.main.async { self.viewComments.reloadData() }

            let webOpinions2 : (comments : [String], likes : [Int], dates : [Date], source : [Int]) = theMoviedb.getReviews(movieDBid: self.serie.idMoviedb)
            self.webOpinions.comments.append(contentsOf: webOpinions2.comments)
            self.webOpinions.likes.append(contentsOf: webOpinions2.likes)
            self.webOpinions.dates.append(contentsOf: webOpinions2.dates)
            self.webOpinions.source.append(contentsOf: webOpinions2.source)
            DispatchQueue.main.async { self.viewComments.reloadData() }

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
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == viewSaisons) { return serie.saisons.count }
        else { return webOpinions.comments.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM yy"
        
        if (tableView == viewSaisons) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellSaison", for: indexPath) as! CellSaison
            cell.saison.text = "Saison " + String(indexPath.row + 1)
            cell.debut.text = dateFormatter.string(from: serie.saisons[indexPath.row].starts)
            cell.fin.text = dateFormatter.string(from: serie.saisons[indexPath.row].ends)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellComment", for: indexPath) as! CellComment
            
            cell.comment.text = webOpinions.comments[indexPath.row]
            cell.likes.text = String(webOpinions.likes[indexPath.row]) + " likes"
            cell.date.text = dateFormatter.string(from: webOpinions.dates[indexPath.row])
            
            if (webOpinions.source[indexPath.row] == sourceTrakt) { cell.logo.image = #imageLiteral(resourceName: "trakt.ico") }
            if (webOpinions.source[indexPath.row] == sourceMovieDB) { cell.logo.image = #imageLiteral(resourceName: "themoviedb.ico") }

            return cell
        }
    }
    
    

    
    @objc func changePage(sender: AnyObject) -> () {
        print("Called : \(pageControl.currentPage)")
        
        switch (pageControl.currentPage) {
        case 0:
            viewResume.isHidden = false
            viewInfos.isHidden = true
            viewSaisons.isHidden = true
            viewComments.isHidden = true

        case 1:
            viewResume.isHidden = true
            viewInfos.isHidden = false
            viewSaisons.isHidden = true
            viewComments.isHidden = true

        case 2:
            viewResume.isHidden = true
            viewInfos.isHidden = true
            viewSaisons.isHidden = false
            viewComments.isHidden = true

        case 3:
            viewResume.isHidden = true
            viewInfos.isHidden = true
            viewSaisons.isHidden = true
            viewComments.isHidden = false

        default:
            viewResume.isHidden = false
            viewInfos.isHidden = true
            viewSaisons.isHidden = true
            viewComments.isHidden = true

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
