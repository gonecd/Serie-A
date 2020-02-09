//
//  Configuration.swift
//  SerieA
//
//  Created by Cyril Delamare on 17/06/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import SeriesCommon

class Configuration: UIViewController
{
    @IBOutlet weak var progresData: UIProgressView!
    @IBOutlet weak var boutonIMDB: UIButton!
    @IBOutlet weak var encours: UILabel!
    @IBOutlet weak var loadingIMDB: UIActivityIndicatorView!
    
    @IBOutlet weak var colTrakt: UIView!
    @IBOutlet weak var colTVdb: UIView!
    @IBOutlet weak var colBetaSeries: UIView!
    @IBOutlet weak var colMovieDB: UIView!
    @IBOutlet weak var colIMDB: UIView!
    @IBOutlet weak var colRottenTom: UIView!
    @IBOutlet weak var colTVmaze: UIView!
    @IBOutlet weak var colMetaCritic: UIView!
    @IBOutlet weak var colAlloCine: UIView!

    @IBOutlet weak var chronoTrakt: UILabel!
    @IBOutlet weak var chronoTVdb: UILabel!
    @IBOutlet weak var chronoBetaSeries: UILabel!
    @IBOutlet weak var chronoMovieDB: UILabel!
    @IBOutlet weak var chronoIMdb: UILabel!
    @IBOutlet weak var chronoRottenTom: UILabel!
    @IBOutlet weak var chronoTVmaze: UILabel!
    @IBOutlet weak var chronoMetaCritic: UILabel!
    @IBOutlet weak var chronoAlloCine: UILabel!
    
    @IBOutlet weak var viewReload: UIView!
    @IBOutlet weak var viewConnect: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progresData.isHidden = true
        loadingIMDB.isHidden = true
        boutonIMDB.layer.cornerRadius = 8.0
        boutonIMDB.layer.masksToBounds = true
        updateChronos()
        
        makeGradiant(carre: viewReload, couleur : "Gris")
        makeGradiant(carre: viewConnect, couleur : "Gris")
        
        makePrettyColorViews(view: colTrakt, couleur: colorTrakt)
        makePrettyColorViews(view: colTVdb, couleur: colorTVdb)
        makePrettyColorViews(view: colBetaSeries, couleur: colorBetaSeries)
        makePrettyColorViews(view: colMovieDB, couleur: colorMoviedb)
        makePrettyColorViews(view: colIMDB, couleur: colorIMDB)
        makePrettyColorViews(view: colRottenTom, couleur: colorRottenTomatoes)
        makePrettyColorViews(view: colTVmaze, couleur: colorTVmaze)
        makePrettyColorViews(view: colMetaCritic, couleur: colorMetaCritic)
        makePrettyColorViews(view: colAlloCine, couleur: colorAlloCine)
    }

    
    func makePrettyColorViews(view : UIView, couleur : UIColor) {
        view.layer.borderColor = couleur.cgColor
        view.layer.borderWidth = 2.0
        view.layer.backgroundColor = couleur.withAlphaComponent(0.5).cgColor
        view.layer.cornerRadius = 8;
    }
    
     
    @IBAction func loadAll(_ sender: Any) {
        progresData.setProgress(0.0, animated: false)
        progresData.isHidden = false
        encours.isHidden = false
        
        DispatchQueue.global(qos: .utility).async {
            
            DispatchQueue.main.async {
                self.encours.text = "Loading Watched list..."
                self.updateChronos()
            }
            db.shows = trakt.getWatched()
            
            DispatchQueue.main.async { self.encours.text = "Loading Stopped list ..." }
            db.shows = db.merge(db.shows, adds: trakt.getStopped())

            DispatchQueue.main.async { self.encours.text = "Loading Watchlist ..." }
            db.shows = db.merge(db.shows, adds: trakt.getWatchlist())

            DispatchQueue.main.async { self.encours.text = "Loading IMDB rates ..." }
            imdb.downloadData()
            imdb.loadDataFile()
            
            let nbShows : Float = Float(db.shows.count)
            var showNum : Int = 0
            
            for uneSerie in db.shows {
                showNum = showNum + 1
                DispatchQueue.main.async {
                    self.progresData.setProgress(Float(showNum)/nbShows, animated: true)
                    self.encours.text = "Loading " + uneSerie.serie
                    self.updateChronos()
                }
                
                db.downloadGlobalInfo(serie: uneSerie)
                db.downloadDates(serie: uneSerie)
                
                if ( (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) ) {
                    if (uneSerie.saisons[uneSerie.saisons.count - 1].watched() == false) {
                        db.downloadDetailInfo(serie: uneSerie)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.updateChronos()

                db.finaliseDB()
                db.saveDB()
                
                self.progresData.isHidden = true
                self.encours.isHidden = true
            }
        }
        
    }
    
    
    func updateChronos() {
        chronoTrakt.text = String(format: "%0.3f sec", trakt.chrono)
        chronoTVdb.text = String(format: "%0.3f sec", theTVdb.chrono)
        chronoBetaSeries.text = String(format: "%0.3f sec", betaSeries.chrono)
        chronoMovieDB.text = String(format: "%0.3f sec", theMoviedb.chrono)
        chronoIMdb.text = String(format: "%0.3f sec", imdb.chrono)
        chronoRottenTom.text = String(format: "%0.3f sec", rottenTomatoes.chrono)
        chronoTVmaze.text = String(format: "%0.3f sec", tvMaze.chrono)
        chronoMetaCritic.text = String(format: "%0.3f sec", metaCritic.chrono)
        chronoAlloCine.text = String(format: "%0.3f sec", alloCine.chrono)
    }
    
    
    @IBAction func LoadIMDB(_ sender: Any) {
        loadingIMDB.isHidden = false
        loadingIMDB.startAnimating()
        
        DispatchQueue.global(qos: .utility).async {
            
            imdb.downloadData()
            imdb.loadDataFile()
            
            var tmpSerie : Serie
            
            for uneSerie in db.shows {
                tmpSerie = imdb.getSerieGlobalInfos(idIMDB: uneSerie.idIMdb)
                uneSerie.ratersIMDB = tmpSerie.ratersIMDB
                uneSerie.ratingIMDB = tmpSerie.ratingIMDB
            }
            
            DispatchQueue.main.async {
                self.loadingIMDB.stopAnimating()
                self.loadingIMDB.isHidden = true
                db.saveDB()
            }
        }
    }
}

