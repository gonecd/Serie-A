//
//  ViewJournal.swift
//  SerieA-iPad copy
//
//  Created by Cyril DELAMARE on 02/03/2025.
//  Copyright © 2025 Home. All rights reserved.
//

import UIKit


class CellJournal: UITableViewCell {
    @IBOutlet weak var banner: UIImageView!
    @IBOutlet weak var serie: UILabel!
    @IBOutlet weak var info: UITextView!
    @IBOutlet weak var source: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var typeInfo: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    
    var index: Int = 0
}


class ViewJournal: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var cadreListe: UIView!
    
    @IBOutlet weak var filterVision: UISwitch!
    @IBOutlet weak var filterDates: UISwitch!
    @IBOutlet weak var filterArrets: UISwitch!
    @IBOutlet weak var filterDiffusion: UISwitch!
    @IBOutlet weak var filterListes: UISwitch!
    
    var viewNews : [News] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Le journal de mes séries"

        if (UIDevice.current.userInterfaceIdiom == .pad) {
            makeGradiant(carre: cadreListe, couleur: "Blanc")
            
            filterVision.onTintColor = mainUIcolor
            filterArrets.onTintColor = mainUIcolor
            filterDates.onTintColor = mainUIcolor
            filterDiffusion.onTintColor = mainUIcolor
            filterListes.onTintColor = mainUIcolor
        }

        viewNews = journal.articles.sorted(by: { $0.date > $1.date })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellJournal", for: indexPath) as! CellJournal
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIcolor2 : UIcolor1
        
        cell.serie.text = viewNews[indexPath.row].serie
        cell.info.text = viewNews[indexPath.row].info
        cell.date.text = dateFormLong.string(for: viewNews[indexPath.row].date)
        
        switch viewNews[indexPath.row].methode {
        case funcFullRefresh : cell.typeInfo.text = "Reload"
        case funcQuickRefresh : cell.typeInfo.text = "Update"
        case funcBackgroundFetch : cell.typeInfo.text = "Background fetch"
        case funcEpisodeVu : cell.typeInfo.text = "Fiche épisode"
        case funcSerie : cell.typeInfo.text = "Fiche série"
        default : cell.typeInfo.text = "Non identifié"
        }
        
        switch viewNews[indexPath.row].type {
        case codeNewsDates : cell.typeImage.image = UIImage(systemName: "calendar") ?? UIImage()
        case codeNewsVisionnage : cell.typeImage.image = UIImage(systemName: "eye") ?? UIImage()
        case codeNewsStatusChg : cell.typeImage.image = UIImage(systemName: "switch.2") ?? UIImage()
        case codeNewsDiffusion : cell.typeImage.image = UIImage(systemName: "antenna.radiowaves.left.and.right") ?? UIImage()

        case codeNewsWatchlist : cell.typeImage.image = UIImage(systemName: "list.bullet.clipboard") ?? UIImage()
        case codeNewsAbandon : cell.typeImage.image = UIImage(systemName: "trash") ?? UIImage()
        case codeNewsReprise : cell.typeImage.image = UIImage(systemName: "playpause.circle") ?? UIImage()
        case codeNewsNouvelleSerie : cell.typeImage.image = UIImage(systemName: "playpause.circle") ?? UIImage()
        case codeNewsSerieVisionnee : cell.typeImage.image = UIImage(systemName: "tray.full") ?? UIImage()

        default : cell.typeImage.image = UIImage(systemName: "questionmark.app") ?? UIImage()
        }
        
        switch viewNews[indexPath.row].source {
        case srcTrakt : cell.source.image = #imageLiteral(resourceName: "trakt.ico")
        case srcTVMaze : cell.source.image = #imageLiteral(resourceName: "tvmaze.ico")
        case srcUneSerie : cell.source.image = #imageLiteral(resourceName: "120.png")

        default : cell.source.image = UIImage()
        }
        
        let indexDB : Int = db.index[viewNews[indexPath.row].serie] ?? -1
        if (indexDB != -1) {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                cell.banner.image = getImage(db.shows[indexDB].banner)
            }
            else {
                cell.banner.image = getImage(db.shows[indexDB].poster)
            }
            arrondir(fenetre: cell.banner, radius: 6)
        } else {
            cell.banner.image = UIImage()
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            
            journal.removeInfo(uneNews : self.viewNews[indexPath.row])
            self.appliquerSelection(self)
        }
        delete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
    @IBAction func appliquerSelection(_ sender: Any) {
        viewNews = journal.articles.sorted(by: { $0.date > $1.date })
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            if (filterDates.isOn == false) { viewNews = viewNews.filter({$0.type != codeNewsDates})}
            if (filterVision.isOn == false) { viewNews = viewNews.filter({$0.type != codeNewsVisionnage})}
            if (filterArrets.isOn == false) { viewNews = viewNews.filter({$0.type != codeNewsStatusChg})}
            if (filterDiffusion.isOn == false) { viewNews = viewNews.filter({$0.type != codeNewsDiffusion})}
            if (filterListes.isOn == false) { viewNews = viewNews.filter({($0.type != codeNewsWatchlist) && ($0.type != codeNewsReprise) && ($0.type != codeNewsNouvelleSerie) && ($0.type != codeNewsSerieVisionnee) && ($0.type != codeNewsAbandon)})}
        }
        
        self.table.reloadData()
        self.view.setNeedsDisplay()
    }
}
