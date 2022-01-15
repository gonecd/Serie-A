//
//  EpisodeFiche.swift
//  SerieA
//
//  Created by Cyril Delamare on 20/01/2018.
//  Copyright © 2018 Home. All rights reserved.
//


import UIKit


class CellCasting : UICollectionViewCell {
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var nom: UILabel!
    @IBOutlet weak var perso: UILabel!
}

class EpisodeFiche : UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()
    var saison : Int = 0
    var episode : Int = 0
    var allComments : [Critique] = []
    var allCasting : [Casting] = []
    @IBOutlet weak var boutonVuUnEp: UIView!

    @IBOutlet weak var resume: UITextView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var banniere: UIImageView!
    
    @IBOutlet weak var viewComments: UITableView!
    @IBOutlet weak var casting: UICollectionView!
    @IBOutlet weak var graphe: GraphEpisode!
    
    @IBOutlet weak var labelNotes: UILabel!
    @IBOutlet weak var labelResume: UILabel!
    @IBOutlet weak var labelcommentaires: UILabel!
    @IBOutlet weak var labelLiens: UILabel!
    @IBOutlet weak var labelCasting: UILabel!
    
    @IBOutlet weak var bTrakt: UIButton!
    @IBOutlet weak var bMovieDB: UIButton!
    @IBOutlet weak var bTVMaze: UIButton!
    @IBOutlet weak var bRotTom: UIButton!
    @IBOutlet weak var bIMDB: UIButton!
    @IBOutlet weak var bBetaSeries: UIButton!
    @IBOutlet weak var bMetaCritic: UIButton!
    @IBOutlet weak var bAlloCine: UIButton!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Episode " + String(episode)
        
        arrondirLabel(texte: labelNotes, radius: 10)
        arrondirLabel(texte: labelResume, radius: 10)
        arrondirLabel(texte: labelcommentaires, radius: 10)
        arrondirLabel(texte: labelLiens, radius: 10)
        arrondirLabel(texte: labelCasting, radius: 10)

        makeGradiant(carre: boutonVuUnEp, couleur: "Rouge")
        if (episode <= serie.saisons[saison - 1].nbWatchedEps) {
            boutonVuUnEp.isHidden = true
        }

        // Masquer les liens s'il n'y a pas de page derrière ... (version iPad only)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            if (serie.idTrakt == "") { bTrakt.isHidden = true }
            if (rottenTomatoes.getPath(serie: serie.serie) == "") { bRotTom.isHidden = true }
            if (metaCritic.getPath(serie: serie.serie) == "") { bMetaCritic.isHidden = true }
            if (serie.idAlloCine == "") { bAlloCine.isHidden = true }
            if (serie.idTVmaze == "") { bTVMaze.isHidden = true }
            if (serie.saisons[saison-1].episodes[episode-1].idIMdb == "") { bIMDB.isHidden = true }
            if (serie.idMoviedb == "") { bMovieDB.isHidden = true }
        }
        
        resume.text = serie.saisons[saison - 1].episodes[episode - 1].resume
        titre.text = serie.saisons[saison - 1].episodes[episode - 1].titre
        date.text = dateFormShort.string(from: serie.saisons[saison - 1].episodes[episode - 1].date)
        banniere.image = image
        
        graphe.sendEpisode(ep: serie.saisons[saison - 1].episodes[episode - 1])
        
        allCasting = betaSeries.getEpisodeCast(idTVDB: serie.saisons[saison - 1].episodes[episode - 1].idTVdb)
        casting.setNeedsDisplay()
        
        let queue : OperationQueue = OperationQueue()

        let opeCommentsIMDB = BlockOperation(block: {
            self.allComments.append(contentsOf: imdb.getComments(IMDBid: self.serie.saisons[self.saison-1].episodes[self.episode-1].idIMdb).prefix(5))
            OperationQueue.main.addOperation({
                self.viewComments.reloadData()
                self.viewComments.setNeedsLayout()
            } )
        } )
        queue.addOperation(opeCommentsIMDB)

        let opeCommentsTrakt = BlockOperation(block: {
            self.allComments.append(contentsOf: trakt.getComments(IMDBid: self.serie.idIMdb, season: self.saison, episode: self.episode).prefix(5))
            OperationQueue.main.addOperation({
                self.viewComments.reloadData()
                self.viewComments.setNeedsLayout()
            } )
        } )
        queue.addOperation(opeCommentsTrakt)
        
        let opeCommentsRotten = BlockOperation(block: {
            self.allComments.append(contentsOf: rottenTomatoes.getComments(serie: self.serie.serie, saison: self.saison, episode: self.episode).prefix(5))
            OperationQueue.main.addOperation({
                self.viewComments.reloadData()
                self.viewComments.setNeedsLayout()
            } )
        } )
        queue.addOperation(opeCommentsRotten)
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
    
    @IBAction func webIMdb(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "http://www.imdb.com/title/\(serie.saisons[saison-1].episodes[episode-1].idIMdb)")!) }
    @IBAction func webTrakt(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "https://trakt.tv/shows/\(serie.idTrakt)/seasons/\(saison)/episodes/\(episode)")!) }
    @IBAction func webRottenTomatoes(_ sender: AnyObject) { UIApplication.shared.open(URL(string: rottenTomatoes.getPath(serie: serie.serie) + String(format: "/s%02d/e%02d", saison, episode))!) }
    @IBAction func webMetaCritic(_ sender: AnyObject) { UIApplication.shared.open(URL(string: metaCritic.getPath(serie: serie.serie) + String(format: "/season-%d", saison))!) }
    @IBAction func webAlloCine(_ sender: Any) { UIApplication.shared.open(URL(string: "http://www.allocine.fr/series/ficheserie_gen_cserie=" + serie.idAlloCine + ".html")!) }
    @IBAction func webTVMaze(_ sender: Any) { UIApplication.shared.open(URL(string: "https://www.tvmaze.com/shows/\(serie.idTVmaze)")!) }
    @IBAction func webTheMovieDB(_ sender: Any) { UIApplication.shared.open(URL(string: "https://www.themoviedb.org/tv/\(serie.idMoviedb)/season/\(saison)/episode/\(episode)")!) }

    @IBAction func webBetaSeries(_ sender: AnyObject) {
        let myURL : String = "https://www.betaseries.com/episode/\(serie.serie.lowercased().replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "-"))" + String(format: "/s%02de%02d", saison, episode)
        UIApplication.shared.open(URL(string: myURL)!)
    }

    @IBAction func vuUnEpisode(_ sender: Any) {
        if (episode <= serie.saisons[saison - 1].nbEpisodes) {
            
            if (trakt.addToHistory(tvdbID: serie.saisons[saison - 1].episodes[episode - 1].idTVdb, imdbID: serie.saisons[saison - 1].episodes[episode - 1].idIMdb)) {
                serie.saisons[saison - 1].nbWatchedEps = serie.saisons[saison - 1].nbWatchedEps + 1
                if (serie.unfollowed) { serie.unfollowed = false }
                if (serie.watchlist) { serie.watchlist = false }
                
                boutonVuUnEp.isHidden = true

                db.updateCompteurs()
                db.saveDB()
                db.shareWithWidget()
            }
            else {
                print("\(serie.serie) S\(saison)E\(episode) : Failed to mark as viewed")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCasting.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellActeur", for: indexPath as IndexPath) as! CellCasting
                
        cell.poster.image = getImage(allCasting[indexPath.row].photo)
        cell.perso.text = allCasting[indexPath.row].personnage
        cell.nom.text = allCasting[indexPath.row].name
                
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

