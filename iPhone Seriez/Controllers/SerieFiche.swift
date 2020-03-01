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
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var journal: UILabel!
    @IBOutlet weak var auteur: UILabel!
}


class SerieFiche: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()
    var allCritics : [Critique] = []
    var modeRecherche: Bool = false
    
    @IBOutlet weak var resume: UITextView!
    @IBOutlet weak var banniere: UIImageView!
    @IBOutlet weak var graphe: Graph!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewResume: UIView!
    @IBOutlet weak var viewInfos: UIView!
    @IBOutlet weak var viewSaisons: UITableView!
    @IBOutlet weak var viewComments: UITableView!
    @IBOutlet weak var boutonWatchlist: UIView!

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

    @IBOutlet weak var labelInfos: UILabel!
    @IBOutlet weak var labelResume: UILabel!
    @IBOutlet weak var labelNotes: UILabel!
    @IBOutlet weak var labelSaisons: UILabel!
    @IBOutlet weak var labelCritiques: UILabel!

    @IBOutlet weak var bWebSite: UIButton!
    @IBOutlet weak var bTrakt: UIButton!
    @IBOutlet weak var bTVMaze: UIButton!
    @IBOutlet weak var bRotTom: UIButton!
    @IBOutlet weak var bIMDB: UIButton!
    @IBOutlet weak var bBetaSeries: UIButton!
    @IBOutlet weak var bMetaCritic: UIButton!
    @IBOutlet weak var bAlloCine: UIButton!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        title = serie.serie
        
        makeGradiant(carre: boutonWatchlist, couleur: "Vert")
        if (modeRecherche) {
            boutonWatchlist.isHidden = false
        }

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
        
        arrondirLabel(texte: labelInfos, radius: 10)
        arrondirLabel(texte: labelResume, radius: 10)
        arrondirLabel(texte: labelNotes, radius: 10)
        arrondirLabel(texte: labelSaisons, radius: 10)
        arrondirLabel(texte: labelCritiques, radius: 10)
        
        annee.text = String(serie.year)
        resume.text = serie.resume
        banniere.image = image
        note.text = String(serie.getGlobalRating()) + " %"
        
        // Masquer les liens s'il n'y a pas de page derrière ...
        if (rottenTomatoes.getPath(serie: serie.serie) == "") { bRotTom.isHidden = true }
        if (metaCritic.getPath(serie: serie.serie) == "") { bMetaCritic.isHidden = true }
        if (serie.homepage == "") { bWebSite.isHidden = true }
        if (serie.idAlloCine == "") { bAlloCine.isHidden = true }
        if (serie.idTVmaze == "") { bTVMaze.isHidden = true }
        if (serie.idIMdb == "") { bIMDB.isHidden = true }
        if (serie.idTrakt == "") { bTrakt.isHidden = true }

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
            status.textColor = .black
        }
        else {
            status.text = "EN COURS"
            status.textColor = .systemBlue
        }
        
        // Remplissage des labels
        network.text? = serie.network
        duree.text? = String(serie.runtime) + " min"
        certif.text? = serie.certification
        langue.text? = serie.language
        drapeau.image = getDrapeau(country: serie.country)
        
        theTVdb.getEpisodesDetailsAndRating(uneSerie: self.serie)

        let queue : OperationQueue = OperationQueue()

        let opeCritics = BlockOperation(block: {
            self.allCritics.append(contentsOf: alloCine.getCritics(serie: self.serie.serie, saison: 1))
            OperationQueue.main.addOperation({
                 self.viewComments.reloadData()
                 self.viewComments.setNeedsLayout()
             } )
            
            self.allCritics.append(contentsOf: rottenTomatoes.getCritics(serie: self.serie.serie, saison: 1))
            OperationQueue.main.addOperation({
                 self.viewComments.reloadData()
                 self.viewComments.setNeedsLayout()
             } )
            
            self.allCritics.append(contentsOf: metaCritic.getCritics(serie: self.serie.serie, saison: 1))
            OperationQueue.main.addOperation({
                 self.viewComments.reloadData()
                 self.viewComments.setNeedsLayout()
             } )
        } )
        queue.addOperation(opeCritics)
       
        let opRates = BlockOperation(block: {
            imdb.getEpisodesRatings(self.serie)
            OperationQueue.main.addOperation({
                self.graphe.sendSerie(self.serie)
                self.graphe.setNeedsDisplay()
            } )

            if (self.serie.idTVdb != "") { betaSeries.getEpisodesRatings(self.serie) }
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
        opeFinalise.addDependency(opeCritics)
        queue.addOperation(opeFinalise)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == viewSaisons) { return serie.saisons.count }
        else { return allCritics.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == viewSaisons) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellSaison", for: indexPath) as! CellSaison
            cell.saison.text = "Saison " + String(indexPath.row + 1)
            cell.episodes.text = String(serie.saisons[indexPath.row].nbEpisodes) + " épisodes"
            
            if (serie.saisons[indexPath.row].starts == ZeroDate) { cell.debut.text = "TBD" }
            else { cell.debut.text = dateFormShort.string(from: serie.saisons[indexPath.row].starts) }

            if (serie.saisons[indexPath.row].ends == ZeroDate) { cell.fin.text = "TBD" }
            else { cell.fin.text = dateFormShort.string(from: serie.saisons[indexPath.row].ends) }
            
            cell.graphe.setSerie(serie: serie, saison: indexPath.row + 1)
            cell.graphe.setType(type: 3)
            cell.graphe.setNeedsDisplay()

            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellComment", for: indexPath) as! CellComment

            cell.comment.text = allCritics[indexPath.row].texte
            cell.date.text = allCritics[indexPath.row].date
            cell.journal.text = allCritics[indexPath.row].journal
            cell.auteur.text = allCritics[indexPath.row].auteur

            if (allCritics[indexPath.row].source == srcMetaCritic) { cell.logo.image = #imageLiteral(resourceName: "metacritic.png") }
            if (allCritics[indexPath.row].source == srcRottenTom) { cell.logo.image = #imageLiteral(resourceName: "rottentomatoes.ico") }
            if (allCritics[indexPath.row].source == srcAlloCine) { cell.logo.image = #imageLiteral(resourceName: "allocine.ico") }

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
    
    
    @IBAction func webTrakt(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "https://trakt.tv/shows/\(serie.idTrakt)")!) }
    @IBAction func webTVMaze(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "https://www.tvmaze.com/shows/\(serie.idTVmaze)")!) }
    @IBAction func webMetaCritic(_ sender: AnyObject) { UIApplication.shared.open(URL(string: metaCritic.getPath(serie: serie.serie))!) }
    @IBAction func webHomepage(_ sender: Any) { UIApplication.shared.open(URL(string: serie.homepage)!)}
    @IBAction func webRottenTomatoes(_ sender: AnyObject) { UIApplication.shared.open(URL(string: rottenTomatoes.getPath(serie: serie.serie))!) }
    @IBAction func webIMdb(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "http://www.imdb.com/title/\(serie.idIMdb)")!) }
    @IBAction func webAlloCine(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "http://www.allocine.fr/series/ficheserie_gen_cserie=\(serie.idAlloCine).html")!) }
    
    @IBAction func webBetaSeries(_ sender: AnyObject) {
        let myURL : String = "https://www.betaseries.com/serie/\(serie.serie.lowercased().replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "-"))"
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func addToWatchlist(_ sender: AnyObject) {
        if (serie.idTVdb != "") {
            if (trakt.addToWatchlist(theTVdbId: serie.idTVdb)) {
                db.downloadGlobalInfo(serie: serie)
                serie.watchlist = true
                db.shows.append(serie)
                
                boutonWatchlist.isHidden = true
                
                db.saveDB()
            }
        }
    }

    
}
