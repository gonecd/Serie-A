//
//  ViewAdecouvrir.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit


class CellAdecouvrir: UITableViewCell {
    
    @IBOutlet weak var banniereSerie: UIImageView!
    @IBOutlet weak var note: UILabel!
    var index: Int = 0
}


class ViewAdecouvrir: UITableViewController {
    
    var allSeries: [Serie] = [Serie]()
    let trakt : Trakt = Trakt.init()
    let theTVdb : TheTVdb = TheTVdb.init()
    let betaSeries : BetaSeries = BetaSeries.init()
    
    // Correctiond es notes pour homogénéisation
    var correctionTVdb : Double = 1.0
    var correctionBetaSeries : Double = 1.0
    var correctionTrakt : Double = 1.0
    
    var popupTextField : UITextField = UITextField()
    var imagesCache : NSCache = NSCache<NSString, UIImage>()
    
    
    func configurationTextField(textField: UITextField!){
        textField.placeholder = "Nom de la série"
        popupTextField = textField
    }
    
    func doNothing(alertView: UIAlertAction!) {}
    
    func searchSerie(alertView: UIAlertAction!)
    {
        let seriesTrouvees : [Serie] = trakt.recherche(serieArechercher: self.popupTextField.text!)
        let actionSheetController: UIAlertController = UIAlertController(title: "Ajouter à ma watchlist", message: nil, preferredStyle: .actionSheet)
        
        for uneSerie in seriesTrouvees
        {
            let uneAction: UIAlertAction = UIAlertAction(title: uneSerie.serie+" ("+String(uneSerie.year)+")", style: UIAlertActionStyle.default) { action -> Void in
                
                if (self.trakt.addToWatchlist(theTVdbId: uneSerie.idTVdb))
                {
                    self.theTVdb.getSerieInfos(uneSerie)
                    self.trakt.getEpisodesRatings(uneSerie)
                    self.betaSeries.getEpisodesRatings(uneSerie)
                    uneSerie.computeSerieInfos()
                    
                    self.allSeries.append(uneSerie)
                    self.saveDB()
                    
                    self.tableView.reloadData()
                }
            }
            actionSheetController.addAction(uneAction)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.cancel, handler: doNothing)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func saveDB ()
    {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathToSVG = dir.appendingPathComponent("iPhoneSeriez")
            let success : Bool = NSKeyedArchiver.archiveRootObject(allSeries, toFile: pathToSVG.path)
            print("saveDB a réussi : \(success)")
        }
    }
    
    func loadDB ()
    {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathToSVG = dir.appendingPathComponent("iPhoneSeriez")
            if (FileManager.default.fileExists(atPath: pathToSVG.path))
            {
                allSeries = (NSKeyedUnarchiver.unarchiveObject(withFile: pathToSVG.path) as? [Serie])!
                computeCorrections()
                tableView.reloadData()
            }
        }
    }
    
    
    @IBAction func addSerie(_ sender: Any) {
        let alert = UIAlertController(title: "Série à rechercher", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.default, handler:doNothing))
        alert.addAction(UIAlertAction(title: "Valider", style: UIAlertActionStyle.default, handler:searchSerie))
        
        self.present(alert, animated: true, completion: { })
    }
    
    @IBAction func refreshAll(_ sender: Any) {
        allSeries = trakt.getWatchlist()
        let infoWindow : UIAlertController = UIAlertController(title: "Info", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(infoWindow, animated: true, completion: { })
        
        DispatchQueue.global(qos: .utility).async {
            for uneSerie:Serie in self.allSeries
            {
                DispatchQueue.main.async {
                    infoWindow.message = "Loading ... \(uneSerie.serie)"
                }
                
                self.theTVdb.getSerieInfos(uneSerie)
                self.trakt.getEpisodesRatings(uneSerie)
                self.self.betaSeries.getEpisodesRatings(uneSerie)
                uneSerie.computeSerieInfos()
            }
            self.computeCorrections()
            infoWindow.dismiss(animated: true, completion: { })
            
            DispatchQueue.main.async {
                self.saveDB()
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialisation des token de data sources et de la watchlist
        //trakt.downloadToken(key: "A0F0010E")
        trakt.start()
        theTVdb.initializeToken()
        
        //self.refreshAll(self)
        self.loadDB()
        
        self.navigationController!.setToolbarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSeries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellAdecouvrir", for: indexPath) as! CellAdecouvrir
        
        cell.banniereSerie?.image = getImage(allSeries[indexPath.row].banner)
        cell.index = indexPath.row
        cell.note.text = String(computeCorrectedRate(uneSerie: allSeries[indexPath.row]))
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let tableCell : CellAdecouvrir = sender as! CellAdecouvrir
        viewController.serie = allSeries[tableCell.index]
        viewController.image = getImage(allSeries[tableCell.index].banner)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete)
        {
            if (self.trakt.removeFromWatchlist(theTVdbId: allSeries[indexPath.row].idTVdb))
            {
                self.allSeries.remove(at: indexPath.row)
                self.saveDB()
                
                tableView.reloadData()
            }
        }
    }
    
    
    func getImage(_ url: String) -> UIImage
    {
        if (url == "") { return UIImage() }
        
        do {
            if ((imagesCache.object(forKey: url as NSString)) == nil)
            {
                let imageData : Data = try Data.init(contentsOf: URL(string: "https://www.thetvdb.com/banners/\(url)")!)
                imagesCache.setObject(UIImage.init(data: imageData)!, forKey: url as NSString)
            }
            return imagesCache.object(forKey: url as NSString)!
        }
        catch let error as NSError { print("getImage failed for \(url) : \(error)") }
        
        return UIImage()
    }
    
    func computeCorrectedRate(uneSerie: Serie) -> Int
    {
        var totalRatings : Double = 0.0
        var nbRatings : Int = 0
        
        for uneSaison in uneSerie.saisons
        {
            for unEpisode in uneSaison.episodes
            {
                if (unEpisode.ratingTVdb != 0.0 && !unEpisode.ratingTVdb.isNaN)
                {
                    totalRatings = totalRatings + (80 * unEpisode.ratingTVdb / correctionTVdb)
                    nbRatings = nbRatings + 1
                }
                
                if (unEpisode.ratingBetaSeries != 0.0 && !unEpisode.ratingBetaSeries.isNaN)
                {
                    totalRatings = totalRatings + (80 * unEpisode.ratingBetaSeries / correctionBetaSeries)
                    nbRatings = nbRatings + 1
                }
                
                if (unEpisode.ratingTrakt != 0.0 && !unEpisode.ratingTrakt.isNaN)
                {
                    totalRatings = totalRatings + (80 * unEpisode.ratingTrakt / correctionTrakt)
                    nbRatings = nbRatings + 1
                }
            }
        }
        
        if (nbRatings > 0)
        {
            //return Int(totalRatings/Double(nbRatings))
            let rate = 60+((40/15)*((totalRatings/Double(nbRatings))-75))
            return Int(rate)
        }
        else
        {
            return -1
        }
    }
    
    func computeCorrections()   {
        var sumTVdb : Double = 0.0
        var nbTVdb : Int = 0
        var sumBetaSeries : Double = 0.0
        var nbBetaSeries : Int = 0
        var sumTrakt : Double = 0.0
        var nbTrakt : Int = 0
        
        var minTVdb : Double = 10.0
        var maxTVdb : Double = 0.0
        var minBetaSeries : Double = 10.0
        var maxBetaSeries : Double = 0.0
        var minTrakt : Double = 10.0
        var maxTrakt : Double = 0.0
        
        for uneSerie in allSeries
        {
            for uneSaison in uneSerie.saisons
            {
                for unEpisode in uneSaison.episodes
                {
                    if (unEpisode.ratingTVdb != 0.0 && !unEpisode.ratingTVdb.isNaN)
                    {
                        if (unEpisode.ratingTVdb < minTVdb) { minTVdb = unEpisode.ratingTVdb }
                        if (unEpisode.ratingTVdb > maxTVdb) { maxTVdb = unEpisode.ratingTVdb }
                        sumTVdb = sumTVdb + unEpisode.ratingTVdb
                        nbTVdb = nbTVdb + 1
                    }
                    
                    if (unEpisode.ratingBetaSeries != 0.0 && !unEpisode.ratingBetaSeries.isNaN)
                    {
                        if (unEpisode.ratingBetaSeries < minBetaSeries) { minBetaSeries = unEpisode.ratingBetaSeries }
                        if (unEpisode.ratingBetaSeries > maxBetaSeries) { maxBetaSeries = unEpisode.ratingBetaSeries }
                        sumBetaSeries = sumBetaSeries + unEpisode.ratingBetaSeries
                        nbBetaSeries = nbBetaSeries + 1
                    }
                    
                    if (unEpisode.ratingTrakt != 0.0 && !unEpisode.ratingTrakt.isNaN)
                    {
                        if (unEpisode.ratingTrakt < minTrakt) { minTrakt = unEpisode.ratingTrakt }
                        if (unEpisode.ratingTrakt > maxTrakt) { maxTrakt = unEpisode.ratingTrakt }
                        sumTrakt = sumTrakt + unEpisode.ratingTrakt
                        nbTrakt = nbTrakt + 1
                    }
                }
            }
        }
        
        correctionTVdb = sumTVdb / Double(nbTVdb)
        correctionBetaSeries = sumBetaSeries / Double(nbBetaSeries)
        correctionTrakt = sumTrakt / Double(nbTrakt)
        
    }
    
    
}



