//
//  ViewAbandonnees.swift
//  SerieA
//
//  Created by Cyril Delamare on 02/01/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

class ViewSaisons: UICollectionViewController {
    var viewList: [Serie] = [Serie]()
    var allMessages: [String] = [String]()
    var allSaisons: [Int] = [Int]()
    
    var accueil : ViewAccueil = ViewAccueil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellAbandonnees", for: indexPath) as! CellAbandonnees
        
        cell.rating.text = String(viewList[indexPath.item].computeCorrectedRate())
        cell.poster.image = accueil.getImage(viewList[indexPath.item].poster)
        cell.message.text = allMessages[indexPath.item]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SaisonFiche
        let collectionCell : CellAbandonnees = sender as! CellAbandonnees
        let index = self.collectionView!.indexPath(for: collectionCell)
        viewController.serie = viewList[index?.row ?? 0]
        viewController.saison = allSaisons[index?.row ?? 0]
        viewController.image = accueil.getImage(viewList[index?.row ?? 0].banner)
    }
    
    // MARK: - UICollectionViewDelegate protocol
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
}

