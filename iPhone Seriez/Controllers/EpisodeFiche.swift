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

class CellComment: UITableViewCell {
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var auteur: UILabel!
}


class EpisodeFiche : UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()
    var saison : Int = 0
    var episode : Int = 0
    var allComments : [Critique] = []
    var displayComments : [Critique] = []
    var allCasting : [Casting] = []
    var parentalGuide : NSMutableDictionary = [:]
    
    @IBOutlet weak var boutonVuUnEp: UIView!
    
    @IBOutlet weak var resume: UITextView!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var duree: UILabel!
    
    @IBOutlet weak var viewComments: UITableView!
    @IBOutlet weak var casting: UICollectionView!
    @IBOutlet weak var graphe: GraphEpisode!
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var labelNotes: UILabel!
    @IBOutlet weak var labelcommentaires: UILabel!
    @IBOutlet weak var labelCasting: UILabel!
    @IBOutlet weak var labelDivers: UILabel!
    
    @IBOutlet weak var viewInfos: UIView!
    @IBOutlet weak var viewRatings: UIView!
    @IBOutlet weak var viewCasting: UIView!
    @IBOutlet weak var viewDivers: UIView!
    @IBOutlet weak var viewCommentaires: UIView!
    
    @IBOutlet weak var bTrakt: UIButton!
    @IBOutlet weak var bMovieDB: UIButton!
    @IBOutlet weak var bTVMaze: UIButton!
    @IBOutlet weak var bRotTom: UIButton!
    @IBOutlet weak var bIMDB: UIButton!
    @IBOutlet weak var bBetaSeries: UIButton!
    @IBOutlet weak var bMetaCritic: UIButton!
    @IBOutlet weak var bAlloCine: UIButton!
    
    @IBOutlet weak var parentSex: UILabel!
    @IBOutlet weak var parentViolence: UILabel!
    @IBOutlet weak var parentDrugs: UILabel!
    @IBOutlet weak var parentProfanity: UILabel!
    @IBOutlet weak var parentFrightened: UILabel!
    
    @IBOutlet weak var langueFR: UIButton!
    @IBOutlet weak var langueGB: UIButton!
    
    @IBOutlet weak var comTrakt: UIButton!
    @IBOutlet weak var comBetaSeries: UIButton!
    @IBOutlet weak var comIMDB: UIButton!
    @IBOutlet weak var comRottenTom: UIButton!
    
    @IBOutlet weak var epsNum: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(serie.serie) - " + String(format: "S%02dE%02d", saison, episode)
        
        if (appConfig.modeCouleurSerie) {
            let mainSerieColor : UIColor = extractDominantColor(from: image) ?? .systemRed
            SerieColor1 = mainSerieColor.withAlphaComponent(0.3)
            SerieColor2 = mainSerieColor.withAlphaComponent(0.1)
        }
        
        arrondirLabel(texte: labelNotes, radius: 10)
        arrondirLabel(texte: labelcommentaires, radius: 10)
        arrondirLabel(texte: labelDivers, radius: 10)
        
        arrondirLabel(texte: parentSex, radius: 7)
        arrondirLabel(texte: parentViolence, radius: 7)
        arrondirLabel(texte: parentDrugs, radius: 7)
        arrondirLabel(texte: parentProfanity, radius: 7)
        arrondirLabel(texte: parentFrightened, radius: 7)
        
        seriesBackgrounds(carre: viewInfos)
        seriesBackgrounds(carre: viewRatings)
        seriesBackgrounds(carre: viewCasting)
        seriesBackgrounds(carre: viewDivers)
        seriesBackgrounds(carre: viewCommentaires)
        
        makeGradiant(carre: boutonVuUnEp, couleur: "Rouge")
            if (episode <= serie.saisons[saison - 1].nbWatchedEps) {
            boutonVuUnEp.isHidden = true
        }
        
        // Masquer les liens s'il n'y a pas de page derrière ... (version iPad only)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            if (serie.idTrakt == "") { bTrakt.isHidden = true }
            if (rottenTomatoes.getPath(serie: serie.serie) == "") { bRotTom.isHidden = true }
            if (serie.slugMetaCritic == "") { bMetaCritic.isHidden = true }
            if (serie.idAlloCine == "") { bAlloCine.isHidden = true }
            if (serie.idTVmaze == "") { bTVMaze.isHidden = true }
            if (serie.saisons[saison-1].episodes[episode-1].idIMdb == "") { bIMDB.isHidden = true }
            if (serie.idMoviedb == "") { bMovieDB.isHidden = true }
        }
        
        resume.text = serie.saisons[saison - 1].episodes[episode - 1].resumeFR
        titre.text = serie.saisons[saison - 1].episodes[episode - 1].titreFR
        date.text = dateFormShort.string(from: serie.saisons[saison - 1].episodes[episode - 1].date)
        duree.text = String(serie.saisons[saison - 1].episodes[episode - 1].duration)  + " min"
        photo.image = getImage(serie.saisons[saison - 1].episodes[episode - 1].photo)
        epsNum.text = String(format: "S%02dE%02d", saison, episode)
        
        
        graphe.sendEpisode(ep: serie.saisons[saison - 1].episodes[episode - 1])
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            arrondirLabel(texte: labelCasting, radius: 10)
        }
        
        let queue : OperationQueue = OperationQueue()
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let opeCasting = BlockOperation(block: {
                //        allCasting = betaSeries.getEpisodeCast(idTVDB: serie.saisons[saison - 1].episodes[episode - 1].idTVdb)
                self.allCasting = theMoviedb.getCasting(idMovieDB: self.serie.idMoviedb, saison: self.saison, episode: self.episode)
                OperationQueue.main.addOperation({
                    self.casting.reloadData()
                    self.casting.setNeedsLayout()
                } )
            } )
            queue.addOperation(opeCasting)
        }
        
        let opeCommentsIMDB = BlockOperation(block: {
            self.allComments.append(contentsOf: imdb.getComments(IMDBid: self.serie.saisons[self.saison-1].episodes[self.episode-1].idIMdb).prefix(5))
            OperationQueue.main.addOperation({
                self.displayComments = self.allComments
                self.viewComments.reloadData()
                self.viewComments.setNeedsLayout()
            } )
        } )
        queue.addOperation(opeCommentsIMDB)
        
        let opeCommentsTrakt = BlockOperation(block: {
            self.allComments.append(contentsOf: trakt.getComments(IMDBid: self.serie.idIMdb, season: self.saison, episode: self.episode).prefix(5))
            OperationQueue.main.addOperation({
                self.displayComments = self.allComments
                self.viewComments.reloadData()
                self.viewComments.setNeedsLayout()
            } )
        } )
        queue.addOperation(opeCommentsTrakt)
        
        let opeCommentsRotten = BlockOperation(block: {
            self.allComments.append(contentsOf: rottenTomatoes.getComments(serie: self.serie.serie, saison: self.saison, episode: self.episode).prefix(5))
            OperationQueue.main.addOperation({
                self.displayComments = self.allComments
                self.viewComments.reloadData()
                self.viewComments.setNeedsLayout()
            } )
        } )
        queue.addOperation(opeCommentsRotten)
        
        let opeCommentsBetaSeries = BlockOperation(block: {
            self.allComments.append(contentsOf: betaSeries.getComments(episodeID: self.serie.saisons[self.saison-1].episodes[self.episode-1].idBetaSeries).prefix(5))
            OperationQueue.main.addOperation({
                self.displayComments = self.allComments
                self.viewComments.reloadData()
                self.viewComments.setNeedsLayout()
            } )
        } )
        queue.addOperation(opeCommentsBetaSeries)
        
        let opParental = BlockOperation(block: {
            self.parentalGuide = imdb.getParentalGuide(IMDBid: self.serie.saisons[self.saison - 1].episodes[self.episode - 1].idIMdb)
            OperationQueue.main.addOperation({
                self.parentSex.backgroundColor = parentguideColor(severity: self.parentalGuide["#nudity"] as? String ?? "None")
                self.parentViolence.backgroundColor = parentguideColor(severity: self.parentalGuide["#violence"] as? String ?? "None")
                self.parentProfanity.backgroundColor = parentguideColor(severity: self.parentalGuide["#profanity"] as? String ?? "None")
                self.parentDrugs.backgroundColor = parentguideColor(severity: self.parentalGuide["#alcohol"] as? String ?? "None")
                self.parentFrightened.backgroundColor = parentguideColor(severity: self.parentalGuide["#frightening"] as? String ?? "None")
            } )
        } )
        queue.addOperation(opParental)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellComment", for: indexPath) as! CellComment
        cell.comment.text = displayComments[indexPath.row].texte
        cell.date.text = displayComments[indexPath.row].date
        cell.auteur.text = displayComments[indexPath.row].auteur
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? SerieColor2 : SerieColor1
        
        if (displayComments[indexPath.row].source == srcTrakt) { cell.logo.image = #imageLiteral(resourceName: "trakt.ico") }
        if (displayComments[indexPath.row].source == srcIMdb) { cell.logo.image = #imageLiteral(resourceName: "imdb.ico") }
        if (displayComments[indexPath.row].source == srcRottenTom) { cell.logo.image = #imageLiteral(resourceName: "rottentomatoes.ico") }
        if (displayComments[indexPath.row].source == srcBetaSeries) { cell.logo.image = #imageLiteral(resourceName: "betaseries.png") }
        
        return cell
    }
    
    @IBAction func webIMdb(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "http://www.imdb.com/title/\(serie.saisons[saison-1].episodes[episode-1].idIMdb)")!) }
    @IBAction func webTrakt(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "https://trakt.tv/shows/\(serie.idTrakt)/seasons/\(saison)/episodes/\(episode)")!) }
    @IBAction func webRottenTomatoes(_ sender: AnyObject) { UIApplication.shared.open(URL(string: rottenTomatoes.getPath(serie: serie.serie) + String(format: "/s%02d/e%02d", saison, episode))!) }
    @IBAction func webMetaCritic(_ sender: AnyObject) { UIApplication.shared.open(URL(string: "https://www.metacritic.com/tv/" + serie.slugMetaCritic + String(format: "/season-%d", saison))!) }
    @IBAction func webAlloCine(_ sender: Any) { UIApplication.shared.open(URL(string: "http://www.allocine.fr/series/ficheserie_gen_cserie=" + serie.idAlloCine + ".html")!) }
    @IBAction func webTVMaze(_ sender: Any) { UIApplication.shared.open(URL(string: "https://www.tvmaze.com/shows/\(serie.idTVmaze)")!) }
    @IBAction func webTheMovieDB(_ sender: Any) { UIApplication.shared.open(URL(string: "https://www.themoviedb.org/tv/\(serie.idMoviedb)/season/\(saison)/episode/\(episode)")!) }
    
    @IBAction func webBetaSeries(_ sender: AnyObject) {
        let myURL : String = "https://www.betaseries.com/episode/\(serie.serie.lowercased().replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "-"))" + String(format: "/s%02de%02d", saison, episode)
        UIApplication.shared.open(URL(string: myURL)!)
    }
    
    @IBAction func vuUnEpisode(_ sender: Any) {
        if (episode <= serie.saisons[saison - 1].nbEpisodes) {
            if (trakt.addToHistory(traktID: serie.saisons[saison - 1].episodes[episode - 1].idTrakt, tvdbID: serie.saisons[saison - 1].episodes[episode - 1].idTVdb, imdbID: serie.saisons[saison - 1].episodes[episode - 1].idIMdb)) {
                serie.saisons[saison - 1].nbWatchedEps = serie.saisons[saison - 1].nbWatchedEps + 1
                if (serie.unfollowed) {
                    serie.unfollowed = false
                    journal.addInfo(serie: serie.serie, source: srcUneSerie, methode: funcEpisodeVu, texte: "Reprise de la série abandonnée", type: newsListes)
                }
                if (serie.watchlist) {
                    serie.watchlist = false
                    journal.addInfo(serie: serie.serie, source: srcUneSerie, methode: funcEpisodeVu, texte: "Visionnage d'un nouvelle série", type: newsListes)
                }
                
                boutonVuUnEp.isHidden = true
                
                db.updateCompteurs()
                
                var dataUpdates : DataUpdatesEntry = db.loadDataUpdates()
                dataUpdates.UneSerieWatchedEps = Date()
                db.saveDataUpdates(dataUpdates: dataUpdates)

                if (episode == 1) {
                    journal.addInfo(serie: serie.serie, source: srcUneSerie, methode: funcEpisodeVu, texte: "Saison \(saison) commencée", type: newsVision)
                } else if (episode == serie.saisons[saison - 1].nbEpisodes) {
                    journal.addInfo(serie: serie.serie, source: srcUneSerie, methode: funcEpisodeVu, texte: "Saison \(saison) visionnée", type: newsVision)
                    
                    if ( (saison == serie.nbSaisons) && ((serie.status == "ended") || (serie.status == "Ended") || (serie.status == "canceled"))) {
                        journal.addInfo(serie: serie.serie, source: srcUneSerie, methode: funcEpisodeVu, texte: "La série est vue entièrement", type: newsListes)
                    }
                }

                db.saveDB()
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
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? SerieColor2 : SerieColor1

        cell.poster.image = getImage(allCasting[indexPath.row].photo)
        cell.perso.text = allCasting[indexPath.row].personnage
        cell.nom.text = allCasting[indexPath.row].name
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    @IBAction func setFrancais(_ sender: Any) {
        resume.text = serie.saisons[saison - 1].episodes[episode - 1].resumeFR
        titre.text = serie.saisons[saison - 1].episodes[episode - 1].titreFR
        langueFR.isSelected = true
        langueGB.isSelected = false
    }
    
    @IBAction func setAnglais(_ sender: Any) {
        resume.text = serie.saisons[saison - 1].episodes[episode - 1].resume
        titre.text = serie.saisons[saison - 1].episodes[episode - 1].titre
        langueFR.isSelected = false
        langueGB.isSelected = true
    }
    
    @IBAction func selectComment(_ sender: Any) {
        let bouton = sender as! UIButton

        if (bouton.alpha == 0.5 ) { bouton.alpha = 1.0; } else { bouton.alpha = 0.5; }
        
        filterComments(filterTrakt: (comTrakt.alpha == 1.0), filterBetaSeries: (comBetaSeries.alpha == 1.0), filterIMDB: (comIMDB.alpha == 1.0), filterRottenTom: (comRottenTom.alpha == 1.0))
        
        viewComments.reloadData()
        viewComments.setNeedsLayout()
    }
    
    
    func filterComments(filterTrakt: Bool, filterBetaSeries: Bool, filterIMDB: Bool, filterRottenTom: Bool) {
        displayComments = []
        
        for oneComment in allComments {
            if (filterTrakt && (oneComment.source == srcTrakt) ) { displayComments.append(oneComment) }
            if (filterBetaSeries && (oneComment.source == srcBetaSeries) ) { displayComments.append(oneComment) }
            if (filterIMDB && (oneComment.source == srcIMdb) ) { displayComments.append(oneComment) }
            if (filterRottenTom && (oneComment.source == srcRottenTom) ) { displayComments.append(oneComment) }
        }
    }
    
}

