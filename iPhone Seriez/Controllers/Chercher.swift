//
//  Chercher.swift
//  SerieA
//
//  Created by Cyril Delamare on 12/03/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

class Chercher: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var pickerAnnee: UIPickerView!
    @IBOutlet weak var pickerGenre: UIPickerView!
    @IBOutlet weak var pickerNetwork: UIPickerView!
    @IBOutlet weak var pickerLangue: UIPickerView!
    
    var accueil : ViewAccueil = ViewAccueil()
    
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
        
        makeJolisGradiantsSimples(vue: viewNetworks)
        makeJolisGradiantsDoubles(vue: viewAnnees)
        makeJolisGradiantsSimples(vue: viewLangues)
        makeJolisGradiantsDoubles(vue: viewGenres)
    }
    
    func initPickers(picker : UIPickerView)
    {
        picker.dataSource = self
        picker.delegate = self
        picker.layer.cornerRadius = 20;
        picker.layer.masksToBounds = true;


    }
    
    func makeJolisGradiantsDoubles(vue : UIView)
    {
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.green.withAlphaComponent(0.3).cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.lightGray.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.red.withAlphaComponent(0.3).cgColor]
        gradient.locations = [0.0, 0.1, 0.4, 0.5, 0.6, 0.9, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.frame = vue.bounds
        
        vue.layer.cornerRadius = 10;
        vue.layer.masksToBounds = true;
        vue.layer.insertSublayer(gradient, at: 0)
    }
    
    
    func makeJolisGradiantsSimples(vue : UIView)
    {
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.green.withAlphaComponent(0.3).cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.lightGray.cgColor]
        gradient.locations = [0.0, 0.2, 0.8, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.frame = vue.bounds
        
        vue.layer.cornerRadius = 10;
        vue.layer.masksToBounds = true;
        vue.layer.insertSublayer(gradient, at: 0)
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
        seriesTrouvees = self.accueil.theMoviedb.chercher(genreIncl: inGenres.text,
                                                          genreExcl: outGenres.text,
                                                          anneeBeg: inAnnees.text,
                                                          anneeEnd: outAnnees.text,
                                                          langue: inLangues.text,
                                                          network: inNetworks.text)
        
        for uneSerie in seriesTrouvees
        {
            print("Enrichissement de \(uneSerie.serie)")
            self.accueil.theMoviedb.getIDs(serie: uneSerie)
            self.accueil.downloadGlobalInfo(serie: uneSerie)
        }
        
        viewController.title = "Propositions de séries"
        viewController.accueil = self.accueil
        viewController.viewList = seriesTrouvees
    }
    
    
    @IBAction func plusInNetworks(_ sender: Any) { pickerNetwork.isHidden = false }
    @IBAction func razInNetworks(_ sender: Any) { inNetworks.text = "Tous" }
    
    @IBAction func plusInGenres(_ sender: Any) {
        modeGenresInclude = true
        pickerGenre.isHidden = false
    }
    @IBAction func plusOutGenres(_ sender: Any) {
        modeGenresInclude = false
        pickerGenre.isHidden = false
    }
    @IBAction func razInGenres(_ sender: Any) { inGenres.text = "Tous" }
    @IBAction func razOutGenres(_ sender: Any) { outGenres.text = "Aucun" }
    
    @IBAction func plusInAnnees(_ sender: Any)
    {
        pickerAnnee.isHidden = false
        modeAnneesInclude = true
    }
    @IBAction func plusOutAnnees(_ sender: Any)
    {
        pickerAnnee.isHidden = false
        modeAnneesInclude = false
    }
    
    @IBAction func plusInLangues(_ sender: Any) { pickerLangue.isHidden = false }
    @IBAction func razInLangues(_ sender: Any) { inLangues.text = "Toutes" }
    
}

