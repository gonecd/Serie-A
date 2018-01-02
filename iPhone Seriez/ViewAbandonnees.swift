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
    @IBOutlet weak var avancement: UILabel!
}


class ViewAbandonnees: UICollectionViewController {

    var trakt : Trakt = Trakt()
    var theTVdb : TheTVdb = TheTVdb()
    var allSeries: [Serie] = [Serie]()
    var imagesCache : NSCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad : ")

        allSeries = trakt.getStopped()
        for uneSerie in allSeries
        {
            print("   Refreshing data for : \(uneSerie.serie)")
            trakt.getSerieInfos(uneSerie)
            theTVdb.getSerieInfos(uneSerie)
            uneSerie.computeSerieInfos()
        }
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allSeries.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellAbandonnees", for: indexPath) as! CellAbandonnees

        cell.avancement.text = allSeries[indexPath.item].serie
        cell.poster.image = getImage(allSeries[indexPath.row].poster)
        
        return cell
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
    
}
