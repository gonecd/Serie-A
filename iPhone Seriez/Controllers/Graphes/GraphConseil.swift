//
//  GraphConseil.swift
//  SerieA
//
//  Created by Cyril Delamare on 21/04/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit

class GraphConseil: UIView {
    
    var serieListe : [(serie : Serie, cpt : Int, category : Int)] = []
    var maxConseils : Int = 10
    
    var origineX : CGFloat = 0.0
    var origineY : CGFloat = 0.0
    var hauteur  : CGFloat = 0.0
    var largeur  : CGFloat = 0.0
    var bordure  : CGFloat = 10.0
    var accueil : ViewAccueil = ViewAccueil()
    var vue : ViewConseil = ViewConseil()
    var grapheType : Int = 0
    var showSuivies : Bool = true
    var showWatchlist : Bool = true
    var showAbandonnees : Bool = true
    var showInconnues : Bool = true

    override func draw(_ dirtyRect: CGRect) {
        
        for subview in (self.subviews).reversed() {
            subview.removeFromSuperview()
        }
        
        super.draw(dirtyRect)
        
        origineX = 35.0
        origineY = (self.frame.height - 25.0)
        hauteur  = (self.frame.height - 25.0 - bordure)
        largeur  = (self.frame.width - origineX - bordure)
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = true
        
        // Drawing code here.
        self.background()
        self.afficheConseils()
    }
    
    func sendSeries(liste : [(serie : Serie, cpt : Int, category : Int)], max : Int)
    {
        serieListe = liste
        maxConseils = max
    }
    
    func toggleCategory(category : Int)
    {
        switch (category)
        {
        case categAbandonnees:
            showAbandonnees = !showAbandonnees
        case categInconnues:
            showInconnues = !showInconnues
        case categSuivies:
            showSuivies = !showSuivies
        case categWatchlist:
            showWatchlist = !showWatchlist
        default:
            print("Categorie inconnue dans toggleCategory")
            return
        }

    }
    
    func setType(type : Int)
    {
        grapheType = type
    }
    
    func background()
    {
        let origineX : CGFloat = 30.0
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
        let largeur : CGFloat = (self.frame.width - origineX - 10.0)
        let textAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: colorAxis]
        let maxCitations : Int = maxConseils
        
        // Lignes
        colorAxis.setStroke()
        
        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: origineX, y: origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY))
        path.stroke()
        
        // Lignes achurées horizontales
        for i:Int in 1 ..< 4
        {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.move(to: CGPoint(x: origineX, y: origineY - (hauteur * CGFloat(i)/4)))
            pathLine.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur * CGFloat(i)/4)))
            
            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.stroke()
        }
        
        // Légende en Y
        for i:Int in 0 ..< 5
        {
            let episode : NSString = String(i*25) as NSString
            episode.draw(in: CGRect(x: 8, y: origineY - (hauteur * CGFloat(i)/4) - 7, width: 30, height: 10), withAttributes: textAttributes)
        }
        
        // Coches verticales
        for i:Int in 0 ..< maxCitations
        {
            let saison : NSString = String(i+1) as NSString
            saison.draw(in: CGRect(x: origineX - 5.0 + (largeur * (CGFloat(i)+0.5) / CGFloat(maxCitations)),
                                   y: self.frame.height - 25, width: 15, height: 12),
                        withAttributes: textAttributes)
        }
        
        if (maxCitations < 1) { return }
        
        // Lignes hachurées verticale
        for i:Int in 1 ..< maxCitations
        {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.move(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(maxCitations)), y: origineY))
            pathLine.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(maxCitations)), y: origineY - hauteur))
            
            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.stroke()
        }
    }
    
    func afficheConseils()
    {
        for index in 0..<serieListe.count
        {
            if (grapheType == 1)
            {
                switch (serieListe[index].category)
                {
                case categAbandonnees:
                    if (showAbandonnees) { traceUnPoint(note: serieListe[index].serie.getGlobalRating(), nbConseils : serieListe[index].cpt, titre : serieListe[index].serie.serie, uneCouleur: UIColor.red) }
                case categInconnues:
                    if (showInconnues) { traceUnPoint(note: serieListe[index].serie.getGlobalRating(), nbConseils : serieListe[index].cpt, titre : serieListe[index].serie.serie, uneCouleur: UIColor.blue) }
                case categSuivies:
                    if (showSuivies) { traceUnPoint(note: serieListe[index].serie.getGlobalRating(), nbConseils : serieListe[index].cpt, titre : serieListe[index].serie.serie, uneCouleur: UIColor.green) }
                case categWatchlist:
                    if (showWatchlist) { traceUnPoint(note: serieListe[index].serie.getGlobalRating(), nbConseils : serieListe[index].cpt, titre : serieListe[index].serie.serie, uneCouleur: UIColor.yellow) }
                default:
                    print("Categorie inconnue dans afficheConseils")
                    return
                }
            }
            else
            {
                traceUneAffiche(note: serieListe[index].serie.getGlobalRating(), nbConseils : serieListe[index].cpt, poster : accueil.getImage(serieListe[index].serie.poster), titre : serieListe[index].serie.serie)
            }
        }
    }
    
    func traceUnPoint(note: Int, nbConseils : Int, titre : String, uneCouleur: UIColor)
    {
        let diametre : CGFloat = 10.0
        let origineX : CGFloat = 30.0
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
        let textAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.black]
        
        if (note == 0) { return }
        
        uneCouleur.setStroke()
        uneCouleur.withAlphaComponent(0.5).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX + 12 + (largeur * CGFloat(nbConseils-1) / CGFloat(maxConseils)),
                                        y: origineY - (hauteur * CGFloat(note) / 100) ),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        path.stroke()
        path.fill()
        
        
        let nom : NSString = titre as NSString
        nom.draw(in: CGRect(x: origineX + 20 + (largeur * CGFloat(nbConseils-1) / CGFloat(maxConseils)),
                            y: origineY - 6 - (hauteur * CGFloat(note) / 100), width: 200, height: 12),
                 withAttributes: textAttributes)
        
    }
    
    
    func traceUneAffiche(note: Int, nbConseils : Int, poster : UIImage, titre : String)
    {
        let origineX : CGFloat = 30.0
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
        var i : Int = 0
        if (maxConseils == 3) { i = Int(arc4random_uniform(3)) }
        
        if (note == 0) { return }
        
        let rect : CGRect = CGRect(x: origineX + 5 + (largeur * CGFloat(nbConseils-1) / CGFloat(maxConseils))  + CGFloat(i*32),
                                   y: origineY - 20 - (hauteur * CGFloat(note) / 100),
                                   width: 30.0, height: 42.0)
        
        poster.draw(in: rect)
        
        let button = UIButton(frame: rect)
        button.setTitle(titre, for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.addSubview(button)
    }
    
    
    @objc func buttonAction(sender: UIButton!) {
        self.vue.showDetails(serie: (sender.titleLabel?.text)!)
    }
    
}
