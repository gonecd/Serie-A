//
//  ViewRecherche.swift
//  SerieA
//
//  Created by Cyril Delamare on 12/03/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

class ViewRecherche: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var pickerAnnee: UIPickerView!
    @IBOutlet weak var pickerGenre: UIPickerView!
    @IBOutlet weak var pickerNetwork: UIPickerView!
    @IBOutlet weak var pickerLangue: UIPickerView!
    
    @IBOutlet weak var viewNetworks: UIView!
    @IBOutlet weak var inNetworks: UITextView!
    
    @IBOutlet weak var viewAnnees: UIView!
    @IBOutlet weak var inAnnees: UITextView!
    @IBOutlet weak var outAnnees: UITextView!
    var modeAnneesInclude : Bool = true

    @IBOutlet weak var viewLangues: UIView!
    @IBOutlet weak var inLangues: UITextView!
    
    @IBOutlet weak var viewGenres: UIView!
    @IBOutlet weak var inGenres: UITextView!
    @IBOutlet weak var outGenres: UITextView!
    var modeGenresInclude : Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPickers(picker: pickerNetwork)
        initPickers(picker: pickerAnnee)
        initPickers(picker: pickerGenre)
        initPickers(picker: pickerLangue)
        
        makeGradiant(carre : viewNetworks, couleur: "Rouge")
        makeGradiant(carre : viewAnnees, couleur: "Rouge")
        makeGradiant(carre : viewLangues, couleur: "Vert")
        makeGradiant(carre : viewGenres, couleur: "Bleu")
    }
    
    func initPickers(picker : UIPickerView)
    {
        picker.dataSource = self
        picker.delegate = self
        picker.layer.cornerRadius = 20;
        picker.layer.masksToBounds = true;
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if (pickerView == pickerAnnee) { return anneesMovieDB.count }
        if (pickerView == pickerGenre) { return genresMovieDB.count }
        if (pickerView == pickerNetwork) { return networksMovieDB.count }
        if (pickerView == pickerLangue) { return languesMovieDB.count }

        return 0
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == pickerAnnee) { return (anneesMovieDB.allKeys[row] as! String) }
        if (pickerView == pickerGenre) { return (genresMovieDB.allKeys[row] as! String) }
        if (pickerView == pickerNetwork) { return (networksMovieDB.allKeys[row] as! String) }
        if (pickerView == pickerLangue) { return (languesMovieDB.allKeys[row] as! String) }

        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        // Choix du Network
        if (pickerView == pickerNetwork)
        {
            if (self.inNetworks.text == "Tous") { self.inNetworks.text = "" }
            self.inNetworks.text = self.inNetworks.text + (networksMovieDB.allKeys[pickerView.selectedRow(inComponent: 0)] as! String) + "\n"

            pickerNetwork.isHidden = true
        }
        
        // Choix du genre
        if (pickerView == pickerGenre)
        {
            if (modeGenresInclude)
            {
                if (self.inGenres.text == "Tous") { self.inGenres.text = "" }
                self.inGenres.text = self.inGenres.text + (genresMovieDB.allKeys[pickerView.selectedRow(inComponent: 0)] as! String) + "\n"
            }
            else
            {
                if (self.outGenres.text == "Aucun") { self.outGenres.text = "" }
                self.outGenres.text = self.outGenres.text + (genresMovieDB.allKeys[pickerView.selectedRow(inComponent: 0)] as! String) + "\n"
            }
            pickerGenre.isHidden = true
        }
        
        // Choix de l'année
        if (pickerView == pickerAnnee)
        {
            if (modeAnneesInclude)
            {
                self.inAnnees.text = (anneesMovieDB.allKeys[pickerView.selectedRow(inComponent: 0)] as! String)
            }
            else
            {
                self.outAnnees.text = (anneesMovieDB.allKeys[pickerView.selectedRow(inComponent: 0)] as! String)
            }
            pickerAnnee.isHidden = true
        }
        
        // Choix de la langue
        if (pickerView == pickerLangue)
        {
            if (self.inLangues.text == "Toutes") { self.inLangues.text = "" }
            self.inLangues.text = self.inLangues.text + (languesMovieDB.allKeys[pickerView.selectedRow(inComponent: 0)] as! String) + "\n"
            
            pickerLangue.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! ViewSerieListe
        
        var seriesTrouvees : [Serie]
        seriesTrouvees = theMoviedb.chercher(genreIncl: inGenres.text, genreExcl: outGenres.text,
                                             anneeBeg: inAnnees.text, anneeEnd: outAnnees.text,
                                             langue: inLangues.text, network: inNetworks.text)
        
        for uneSerie in seriesTrouvees
        {
            print("Enrichissement de \(uneSerie.serie)")
            theMoviedb.getIDs(serie: uneSerie)
            db.downloadGlobalInfo(serie: uneSerie)
        }
        
        viewController.title = "Propositions de séries"
        viewController.viewList = seriesTrouvees
    }
    
    
    @IBAction func plusInNetworks(_ sender: Any)    { pickerNetwork.isHidden = false }
    @IBAction func razInNetworks(_ sender: Any)     { inNetworks.text = "Tous" }
    @IBAction func plusInGenres(_ sender: Any)      { modeGenresInclude = true;  pickerGenre.isHidden = false; }
    @IBAction func plusOutGenres(_ sender: Any)     { modeGenresInclude = false; pickerGenre.isHidden = false; }
    @IBAction func razInGenres(_ sender: Any)       { inGenres.text = "Tous" }
    @IBAction func razOutGenres(_ sender: Any)      { outGenres.text = "Aucun" }
    @IBAction func plusInAnnees(_ sender: Any)      { pickerAnnee.isHidden = false; modeAnneesInclude = true; }
    @IBAction func plusOutAnnees(_ sender: Any)     { pickerAnnee.isHidden = false; modeAnneesInclude = false; }
    @IBAction func plusInLangues(_ sender: Any)     { pickerLangue.isHidden = false }
    @IBAction func razInLangues(_ sender: Any)      { inLangues.text = "Toutes" }
    
    
    
    
    //////////////////////////////////////////////////
    // Recherche par nom
    //////////////////////////////////////////////////
    
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
        let seriesTrouvees : [Serie] = trakt.recherche(serieArechercher: self.popupTextField.text!)
        let actionSheetController: UIAlertController = UIAlertController(title: "Ajouter à ma watchlist", message: nil, preferredStyle: .actionSheet)
        
        for uneSerie in seriesTrouvees
        {
            let uneAction: UIAlertAction = UIAlertAction(title: uneSerie.serie+" ("+String(uneSerie.year)+")", style: UIAlertActionStyle.default) { action -> Void in
                if (self.ajouterUneSerieDansLaWatchlistTrakt(uneSerie: uneSerie))
                {
                    trace(texte : "<< ViewRecherche : searchSerie >> Return : true", logLevel : logFuncReturn, scope : scopeController)
                }
            }
            actionSheetController.addAction(uneAction)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.cancel, handler: doNothing)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    
    func ajouterUneSerieDansLaWatchlistTrakt(uneSerie : Serie) -> Bool
    {
        trace(texte : "<< ViewRecherche : ajouterUneSerieDansLaWatchlistTrakt >>", logLevel : logFuncCalls, scope : scopeController)
        trace(texte : "<< ViewRecherche : ajouterUneSerieDansLaWatchlistTrakt >> Params : uneSerie = \(uneSerie)", logLevel : logFuncParams, scope : scopeController)
        
        if (trakt.addToWatchlist(theTVdbId: uneSerie.idTVdb))
        {
            db.downloadGlobalInfo(serie: uneSerie)
            uneSerie.watchlist = true
            db.shows.append(uneSerie)
            db.saveDB()
            //TODO : updateCompteurs()
            
            trace(texte : "<< ViewRecherche : ajouterUneSerieDansLaWatchlistTrakt >> Return : true", logLevel : logFuncReturn, scope : scopeController)
            return true
        }
        
        trace(texte : "<< ViewRecherche : ajouterUneSerieDansLaWatchlistTrakt >> Return : false", logLevel : logFuncReturn, scope : scopeController)
        return false
    }
    
    

    
    
    
    
    
}

