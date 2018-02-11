//
//  ViewSeries
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


class ViewSeries: UICollectionViewController {
    var viewList: [Serie] = [Serie]()

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
        cell.message.text = viewList[indexPath.item].message
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! SerieFiche
        let collectionCell : CellAbandonnees = sender as! CellAbandonnees
        let index = self.collectionView!.indexPath(for: collectionCell)
        viewController.serie = viewList[index?.row ?? 0]
        viewController.image = accueil.getImage(viewList[index?.row ?? 0].banner)
    }

    @IBAction func deleteSerie(_ sender: Any) {
        print("Supprimer")
    }
    
    @IBAction func exploreSerie(_ sender: Any) {
        print("Explorer")
    }
    
    
    
    
    
    @IBAction func addSerie(_ sender: Any) {
        let alert = UIAlertController(title: "Série à rechercher", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.default, handler:doNothing))
        alert.addAction(UIAlertAction(title: "Valider", style: UIAlertActionStyle.default, handler:searchSerie))
        
        self.present(alert, animated: true, completion: { })
    }
 
    
    func configurationTextField(textField: UITextField!){
        textField.placeholder = "Nom de la série"
        popupTextField = textField
    }
    
    var popupTextField : UITextField = UITextField()
    func doNothing(alertView: UIAlertAction!) {}
    
    func searchSerie(alertView: UIAlertAction!)
    {
        let seriesTrouvees : [Serie] = accueil.chercherUneSerieSurTrakt(nomSerie: self.popupTextField.text!)
        let actionSheetController: UIAlertController = UIAlertController(title: "Ajouter à ma watchlist", message: nil, preferredStyle: .actionSheet)
        
        for uneSerie in seriesTrouvees
        {
            let uneAction: UIAlertAction = UIAlertAction(title: uneSerie.serie+" ("+String(uneSerie.year)+")", style: UIAlertActionStyle.default) { action -> Void in
                if (self.accueil.ajouterUneSerieDansLaWatchlistTrakt(uneSerie: uneSerie))
                {
                    self.viewList.append(uneSerie)
                    self.view.setNeedsDisplay()
                }
            }
            actionSheetController.addAction(uneAction)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.cancel, handler: doNothing)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }

    
    
    // MARK: - UICollectionViewDelegate protocol
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }

}
