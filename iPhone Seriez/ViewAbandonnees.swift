//
//  ViewAbandonnees.swift
//  SerieA
//
//  Created by Cyril Delamare on 02/01/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

class CellAbandonnees: UICollectionViewCell {
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var message: UILabel!
}


class ViewAbandonnees: UICollectionViewController {

    var trakt : Trakt = Trakt()
    var theTVdb : TheTVdb = TheTVdb()
    var betaSeries : BetaSeries = BetaSeries()
    
    var allSeries: [Serie] = [Serie]()
    var imagesCache : NSCache = NSCache<NSString, UIImage>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allSeries.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellAbandonnees", for: indexPath) as! CellAbandonnees

        cell.rating.text = String(computeCorrectedRate(uneSerie: allSeries[indexPath.item]))
        cell.poster.image = getImage(allSeries[indexPath.item].poster)
        cell.message.text = allSeries[indexPath.item].message
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let collectionCell : CellAbandonnees = sender as! CellAbandonnees
        let index = self.collectionView!.indexPath(for: collectionCell)
        viewController.serie = allSeries[index?.row ?? 0]
        viewController.image = getImage(allSeries[index?.row ?? 0].banner)
    }
    

    
    // MARK: - UICollectionViewDelegate protocol
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
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
        // Correction des notes pour homogénéisation
        let correctionTVdb : Double = 7.666
        let correctionBetaSeries : Double = 8.559
        let correctionTrakt : Double = 7.965
        

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

    
}
