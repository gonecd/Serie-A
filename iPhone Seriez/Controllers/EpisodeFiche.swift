//
//  EpisodeFiche.swift
//  SerieA
//
//  Created by Cyril Delamare on 20/01/2018.
//  Copyright © 2018 Home. All rights reserved.
//


import UIKit
import SeriesCommon

class EpisodeFiche : UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()
    var saison : Int = 0
    var episode : Int = 0
    var allComments : [Critique] = []
    @IBOutlet weak var boutonVuUnEp: UIView!

    @IBOutlet weak var resume: UITextView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var banniere: UIImageView!
    
    @IBOutlet weak var viewComments: UITableView!
    @IBOutlet weak var graphe: GraphEpisode!
    
    @IBOutlet weak var labelNotes: UILabel!
    @IBOutlet weak var labelResume: UILabel!
    @IBOutlet weak var labelcommentaires: UILabel!
    @IBOutlet weak var labelLiens: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Episode " + String(episode)
        
        arrondirLabel(texte: labelNotes, radius: 10)
        arrondirLabel(texte: labelResume, radius: 10)
        arrondirLabel(texte: labelcommentaires, radius: 10)
        arrondirLabel(texte: labelLiens, radius: 10)

        makeGradiant(carre: boutonVuUnEp, couleur: "Rouge")
        if (episode <= serie.saisons[saison - 1].nbWatchedEps) {
            boutonVuUnEp.isHidden = true
        }

        allComments.append(contentsOf: imdb.getComments(IMDBid: self.serie.saisons[self.saison-1].episodes[self.episode-1].idIMdb))
        allComments.append(contentsOf: trakt.getComments(IMDBid: self.serie.idIMdb, season: self.saison, episode: self.episode))
        allComments.append(contentsOf: rottenTomatoes.getComments(serie: self.serie.serie, saison: self.saison, episode: self.episode))

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM yy"
        
        resume.text = serie.saisons[saison - 1].episodes[episode - 1].resume
        titre.text = serie.saisons[saison - 1].episodes[episode - 1].titre
        date.text = dateFormatter.string(from: serie.saisons[saison - 1].episodes[episode - 1].date)
        banniere.image = image
        
        graphe.sendEpisode(nTrakt: serie.saisons[saison - 1].episodes[episode - 1].ratingTrakt,
                           nTVdb: serie.saisons[saison - 1].episodes[episode - 1].ratingTVdb,
                           nBetaSeries: serie.saisons[saison - 1].episodes[episode - 1].ratingBetaSeries,
                           nMovieDB: serie.saisons[saison - 1].episodes[episode - 1].ratingMoviedb,
                           nIMDB: serie.saisons[saison - 1].episodes[episode - 1].ratingIMdb,
                           nRottenTomatoes: serie.saisons[saison - 1].episodes[episode - 1].ratingRottenTomatoes,
                           nTVMaze: serie.saisons[saison - 1].episodes[episode - 1].ratingTVMaze,
                           nMetaCritic: serie.saisons[saison - 1].episodes[episode - 1].ratingMetaCritic,
                           nAlloCine: 0 )
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellComment", for: indexPath) as! CellComment
        cell.comment.text = allComments[indexPath.row].texte
        cell.date.text = allComments[indexPath.row].date
        cell.journal.text = allComments[indexPath.row].journal
        cell.auteur.text = allComments[indexPath.row].auteur

        if (allComments[indexPath.row].source == srcTrakt) { cell.logo.image = #imageLiteral(resourceName: "trakt.ico") }
        if (allComments[indexPath.row].source == srcIMdb) { cell.logo.image = #imageLiteral(resourceName: "imdb.ico") }
        if (allComments[indexPath.row].source == srcRottenTom) { cell.logo.image = #imageLiteral(resourceName: "rottentomatoes.ico") }

        return cell
    }
    
    @IBAction func webIMdb(_ sender: AnyObject) {
        if (serie.saisons[saison-1].episodes[episode-1].idIMdb != "") {
            let myURL : String = "http://www.imdb.com/title/\(serie.saisons[saison-1].episodes[episode-1].idIMdb)"
            UIApplication.shared.open(URL(string: myURL)!)
        }
    }
    
    @IBAction func webTrakt(_ sender: AnyObject) {
        let myURL : String = "http://trakt.tv/shows/\(serie.serie.lowercased().replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: "'", with: "-"))/seasons/\(saison)/episodes/\(episode)"
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func webTheTVdb(_ sender: AnyObject) {
        let myURL : String = "https://www.thetvdb.com/?tab=series&id=\(serie.idTVdb)"
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func webRottenTomatoes(_ sender: AnyObject) {
        if (rottenTomatoes.getPath(serie: serie.serie) != "") {
            let myURL : String = rottenTomatoes.getPath(serie: serie.serie) + String(format: "/s%02d/e%02d", saison, episode)
            UIApplication.shared.open(URL(string: myURL)!)
        }
    }
    
    @IBAction func webBetaSeries(_ sender: AnyObject) {
        let myURL : String = "https://www.betaseries.com/episode/\(serie.serie.lowercased().replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "-"))" + String(format: "/s%02de%02d", saison, episode)
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func webMetaCritic(_ sender: AnyObject) {
        if (metaCritic.getPath(serie: serie.serie) != "") {
            UIApplication.shared.open(URL(string: metaCritic.getPath(serie: serie.serie) + String(format: "/season-%d", saison))!)
        }
    }
    
    @IBAction func webTheMovieDB(_ sender: Any) {

    }
    
    @IBAction func webAlloCine(_ sender: Any) {
        if (serie.idAlloCine != "") {
            UIApplication.shared.open(URL(string: "http://www.allocine.fr/series/ficheserie_gen_cserie=" + serie.idAlloCine + ".html")!)
        }

    }

    @IBAction func webTVMaze(_ sender: Any) {

    }

    @IBAction func vuUnEpisode(_ sender: Any) {
        if (episode <= serie.saisons[saison - 1].nbEpisodes) {
            
            if (trakt.addToHistory(tvdbID: serie.saisons[saison - 1].episodes[episode - 1].idTVdb)) {
                serie.saisons[saison - 1].nbWatchedEps = serie.saisons[saison - 1].nbWatchedEps + 1
                if (serie.unfollowed) { serie.unfollowed = false }
                if (serie.watchlist) { serie.watchlist = false }
                
                boutonVuUnEp.isHidden = true

                db.updateCompteurs()
                db.saveDB()
            }
        }
    }
}
