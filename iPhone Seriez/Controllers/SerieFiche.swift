//
//  SerieFiche.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit
import SeriesCommon

class CellSaison: UITableViewCell {
    @IBOutlet weak var saison: UILabel!
    @IBOutlet weak var debut: UILabel!
    @IBOutlet weak var fin: UILabel!
    @IBOutlet weak var episodes: UILabel!
    @IBOutlet weak var graphe: GraphMiniSaison!
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
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewResume: UIView!
    @IBOutlet weak var viewInfos: UIView!
    @IBOutlet weak var viewSaisons: UITableView!
    @IBOutlet weak var viewComments: UITableView!
    
    @IBOutlet weak var network: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var duree: UILabel!
    @IBOutlet weak var certif: UILabel!
    @IBOutlet weak var langue: UILabel!
    @IBOutlet weak var drapeau: UIImageView!
    @IBOutlet weak var drapeauBgd: UILabel!
    @IBOutlet weak var annee: UILabel!
    @IBOutlet weak var note: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = serie.serie
        
        //alloCine.getID(serie: serie.serie)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
        
        annee.text = String(serie.year)
        resume.text = serie.resume
        banniere.image = image
        note.text = String(serie.getGlobalRating()) + " %"
        
        // Affichage des genres
        var allGenres : String = ""
        for unGenre in serie.genres {
            allGenres = allGenres + unGenre + " "
        }
        genre.text = allGenres
        
        // Arrondir les labels
        arrondirLabel(texte: status, radius: 10)
        arrondirLabel(texte: network, radius: 8)
        arrondirLabel(texte: duree, radius: 8)
        arrondirLabel(texte: certif, radius: 8)
        arrondirLabel(texte: langue, radius: 8)
        arrondirLabel(texte: drapeauBgd, radius: 8)
        arrondirLabel(texte: genre, radius: 8)
        arrondirLabel(texte: annee, radius: 8)
        arrondirLabel(texte: note, radius: 10)

        // Affichage du status
        if (serie.status == "Ended") {
            status.text = "FINIE"
            status.textColor = UIColor.black
        }
        else {
            status.text = "EN COURS"
            status.textColor = UIColor.blue
        }
        
        // Remplissage des labels
        network.text? = serie.network
        duree.text? = String(serie.runtime) + " min"
        certif.text? = serie.certification
        langue.text? = serie.language
        drapeau.image = getDrapeau(country: serie.country)
        
        theTVdb.getEpisodesDetailsAndRating(uneSerie: self.serie)

        let queue : OperationQueue = OperationQueue()

        let opeReviews = BlockOperation(block: {
            self.webOpinions = theMoviedb.getReviews(movieDBid: self.serie.idMoviedb)
            OperationQueue.main.addOperation({
                self.viewComments.reloadData()
                self.viewComments.setNeedsLayout()
            } )

            let webOpinionsTmp : (comments : [String], likes : [Int], dates : [Date], source : [Int]) = trakt.getComments(IMDBid: self.serie.idIMdb, season: 0, episode: 0)
            self.webOpinions.comments.append(contentsOf: webOpinionsTmp.comments)
            self.webOpinions.likes.append(contentsOf: webOpinionsTmp.likes)
            self.webOpinions.dates.append(contentsOf: webOpinionsTmp.dates)
            self.webOpinions.source.append(contentsOf: webOpinionsTmp.source)
            OperationQueue.main.addOperation({
                self.viewComments.reloadData()
                self.viewComments.setNeedsLayout()
            } )
        } )
        queue.addOperation(opeReviews)

        let opRates = BlockOperation(block: {
            if (self.serie.idTVdb != "") { betaSeries.getEpisodesRatings(self.serie) }
            OperationQueue.main.addOperation({
                self.graphe.sendSerie(self.serie)
                self.graphe.setNeedsDisplay()
            } )

            if (self.serie.idMoviedb != "") { theMoviedb.getEpisodesRatings(self.serie) }
            OperationQueue.main.addOperation({
                self.graphe.sendSerie(self.serie)
                self.graphe.setNeedsDisplay()
            } )

            imdb.getEpisodesRatings(self.serie)
            OperationQueue.main.addOperation({
                self.graphe.sendSerie(self.serie)
                self.graphe.setNeedsDisplay()
            } )

            if (self.serie.idTrakt != "") { trakt.getEpisodesRatings(self.serie) }
            OperationQueue.main.addOperation({
                self.graphe.sendSerie(self.serie)
                self.graphe.setNeedsDisplay()
            } )
        } )
        queue.addOperation(opRates)
        
        let opeFinalise = BlockOperation(block: {
            db.saveDB()

            OperationQueue.main.addOperation({
                self.viewSaisons.reloadData()
                self.viewSaisons.setNeedsLayout()
            } )
        } )
        opeFinalise.addDependency(opRates)
        opeFinalise.addDependency(opeReviews)
        queue.addOperation(opeFinalise)

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
            cell.episodes.text = String(serie.saisons[indexPath.row].nbEpisodes) + " épisodes"
            
            if (serie.saisons[indexPath.row].starts == ZeroDate) { cell.debut.text = "TBD" }
            else { cell.debut.text = dateFormatter.string(from: serie.saisons[indexPath.row].starts) }

            if (serie.saisons[indexPath.row].ends == ZeroDate) { cell.fin.text = "TBD" }
            else { cell.fin.text = dateFormatter.string(from: serie.saisons[indexPath.row].ends) }
            
            cell.graphe.setSerie(serie: serie, saison: indexPath.row + 1)
            cell.graphe.setType(type: 1)
            cell.graphe.setNeedsDisplay()

            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellComment", for: indexPath) as! CellComment
            cell.comment.text = webOpinions.comments[indexPath.row]
            if (webOpinions.likes[indexPath.row] > 0) { cell.likes.text = String(webOpinions.likes[indexPath.row]) + " likes" }
            if (webOpinions.dates[indexPath.row] != ZeroDate) { cell.date.text = dateFormatter.string(from: webOpinions.dates[indexPath.row]) }
            if (webOpinions.source[indexPath.row] == sourceTrakt) { cell.logo.image = #imageLiteral(resourceName: "trakt.ico") }
            if (webOpinions.source[indexPath.row] == sourceMovieDB) { cell.logo.image = #imageLiteral(resourceName: "themoviedb.ico") }
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowSaison") {
            let viewController = segue.destination as! SaisonFiche
            
            viewController.serie = serie
            viewController.saison = (viewSaisons.indexPathForSelectedRow?.row)! + 1
            viewController.image = getImage(serie.banner)
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            if gesture.direction == UISwipeGestureRecognizer.Direction.right {
                pageControl.currentPage = pageControl.currentPage - 1
            }
            else {
                pageControl.currentPage = pageControl.currentPage + 1
            }
            
            self.changePage(sender: self)
        }
    }
    
    @objc func changePage(sender: AnyObject) -> () {
        switch (pageControl.currentPage) {
        case 0:
            viewResume.isHidden = false
            viewInfos.isHidden = false
            viewSaisons.isHidden = true
            viewComments.isHidden = true
            graphe.isHidden = true
            
        case 1:
            viewResume.isHidden = true
            viewInfos.isHidden = false
            viewSaisons.isHidden = true
            viewComments.isHidden = true
            graphe.isHidden = false

        case 2:
            viewResume.isHidden = true
            viewInfos.isHidden = true
            viewSaisons.isHidden = false
            viewComments.isHidden = true
            graphe.isHidden = true

        case 3:
            viewResume.isHidden = true
            viewInfos.isHidden = true
            viewSaisons.isHidden = true
            viewComments.isHidden = false
            graphe.isHidden = true

        default:
            viewResume.isHidden = false
            viewInfos.isHidden = true
            viewSaisons.isHidden = true
            viewComments.isHidden = true
            graphe.isHidden = true
        }
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
        if (rottenTomatoes.getPath(serie: serie.serie) != "") {
            UIApplication.shared.open(URL(string: rottenTomatoes.getPath(serie: serie.serie))!)
        }
    }
    
    @IBAction func webIMdb(_ sender: AnyObject) {
        let myURL : String = "http://www.imdb.com/title/\(serie.idIMdb)"
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func webBetaSeries(_ sender: AnyObject) {
        let myURL : String = "https://www.betaseries.com/serie/\(serie.serie.lowercased().replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "-"))"
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func webMetaCritic(_ sender: AnyObject) {
        if (metaCritic.getPath(serie: serie.serie) != "") {
            UIApplication.shared.open(URL(string: metaCritic.getPath(serie: serie.serie))!)
        }
    }
    
    @IBAction func webHomepage(_ sender: Any) {
        if (serie.homepage != "") {
            UIApplication.shared.open(URL(string: serie.homepage)!)
        }
    }
    
}
