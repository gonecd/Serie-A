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
    var webOpinions : (comments : [String], likes : [Int], dates : [Date], source : [Int]) = ([], [], [], [])
    
    @IBOutlet weak var resume: UITextView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var banniere: UIImageView!
    
    @IBOutlet weak var viewComments: UITableView!
    @IBOutlet weak var graphe: GraphEpisode!
    
    @IBOutlet weak var labelNotes: UILabel!
    @IBOutlet weak var labelResume: UILabel!
    @IBOutlet weak var labelcommentaires: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrondirLabel(texte: labelNotes, radius: 10)
        arrondirLabel(texte: labelResume, radius: 10)
        arrondirLabel(texte: labelcommentaires, radius: 10)

        
        webOpinions = trakt.getComments(IMDBid: self.serie.idIMdb, season: saison, episode: episode)
        
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
        return webOpinions.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM yy"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellComment", for: indexPath) as! CellComment
        cell.comment.text = webOpinions.comments[indexPath.row]
        
        if (webOpinions.likes[indexPath.row] > 0) { cell.likes.text = String(webOpinions.likes[indexPath.row]) + " likes" }
        if (webOpinions.dates[indexPath.row] != ZeroDate) { cell.date.text = dateFormatter.string(from: webOpinions.dates[indexPath.row]) }
        if (webOpinions.source[indexPath.row] == sourceTrakt) { cell.logo.image = #imageLiteral(resourceName: "trakt.ico") }
        if (webOpinions.source[indexPath.row] == sourceMovieDB) { cell.logo.image = #imageLiteral(resourceName: "themoviedb.ico") }
        return cell
    }
    
    @IBAction func webIMdb(_ sender: AnyObject) {
        if (serie.saisons[saison-1].episodes[episode-1].idIMdb != "") {
            let myURL : String = "http://www.imdb.com/title/\(serie.saisons[saison-1].episodes[episode-1].idIMdb)"
            UIApplication.shared.open(URL(string: myURL)!)
        }
    }
    
}
