//
//  SaisonFiche.swift
//  iPhone Seriez
//
//  Created by Cyril Delamare on 11/11/2017.
//  Copyright © 2017 Home. All rights reserved.
//

import UIKit

class CellEpisode: UITableViewCell {
    
    @IBOutlet weak var numero: UILabel!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var noteTrakt: UILabel!
    @IBOutlet weak var noteTVdb: UILabel!
    @IBOutlet weak var noteBetaSeries: UILabel!
    @IBOutlet weak var noteIMdb: UILabel!
    @IBOutlet weak var noteRottentomatoes: UILabel!
    @IBOutlet weak var noteMoviedb: UILabel!
}



class SaisonFiche: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var serie : Serie = Serie(serie: "")
    var image : UIImage = UIImage()
    var saison : Int = 0

    @IBOutlet weak var banniere: UIImageView!
    @IBOutlet weak var graphe: GraphSaison!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        banniere.image = image
        graphe.sendSaison(serie.saisons[saison - 1])
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: {})
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "showEpisode")
        {
            let viewController = segue.destination as! EpisodeFiche
            let collectionCell : CellEpisode = sender as! CellEpisode
            viewController.serie = serie
            viewController.saison = saison
            viewController.image = image
            viewController.episode = Int(collectionCell.numero.text!)!
        }
        else
        {
            let viewController = segue.destination as! SerieFiche
            viewController.serie = serie
            viewController.image = image
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serie.saisons[saison - 1].episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellEpisode", for: indexPath) as! CellEpisode
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM yy"
        
        cell.numero.text = String(indexPath.row + 1)
        cell.titre.text = serie.saisons[saison - 1].episodes[indexPath.row].titre
        cell.date.text = dateFormatter.string(from: serie.saisons[saison - 1].episodes[indexPath.row].date)
        cell.noteTrakt.text = String(serie.saisons[saison - 1].episodes[indexPath.row].getFairRatingTrakt())
        cell.noteTVdb.text = String(serie.saisons[saison - 1].episodes[indexPath.row].getFairRatingTVdb())
        cell.noteBetaSeries.text = String(serie.saisons[saison - 1].episodes[indexPath.row].getFairRatingBetaSeries())
        cell.noteMoviedb.text = String(serie.saisons[saison - 1].episodes[indexPath.row].getFairRatingMoviedb())

        return cell
    }
    
    
    
}

