//
//  Statistiques.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 26/01/2020.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

class Statistiques: UIViewController {
    // Stats chiffrées
    // --------------------------
    
    @IBOutlet weak var graphe1: Stat1!
    @IBOutlet weak var graphe2: UIView!
    @IBOutlet weak var graphe4: StatRates!
    @IBOutlet weak var graphGantt: UIView!
    @IBOutlet weak var viewSerieCounts: UIView!
    @IBOutlet weak var viewGantt: UIView!
    @IBOutlet weak var viewParNotes: UIView!
    
    @IBOutlet weak var nbEpisodes: UILabel!
    @IBOutlet weak var nbSaisons: UILabel!
    @IBOutlet weak var nbSeries: UILabel!
    
    @IBOutlet weak var bRate1: UIButton!
    @IBOutlet weak var bRate2: UIButton!
    @IBOutlet weak var bRate3: UIButton!
    @IBOutlet weak var bRate4: UIButton!
    @IBOutlet weak var bRate5: UIButton!
    @IBOutlet weak var bRate6: UIButton!
    @IBOutlet weak var bRate7: UIButton!
    @IBOutlet weak var bRate8: UIButton!
    @IBOutlet weak var bRate9: UIButton!
    @IBOutlet weak var bRateNone: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let today : Date = Date()
        var nbSeriesToSee : Int = 0
        var nbEpisodesToSee : Int = 0
        
        makeGradiant(carre: viewSerieCounts, couleur: "Blanc")
        makeGradiant(carre: graphe2, couleur: "Blanc")
        makeGradiant(carre: viewParNotes, couleur: "Blanc")
        makeGradiant(carre: viewGantt, couleur: "Blanc")
        
        // Boutons des ratings
        arrondirButton(texte: bRate1, radius: 6.0)
        bRate1.setTitleColor(UIColor.systemBackground, for: .normal)
        bRate1.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 1.0)

        arrondirButton(texte: bRate2, radius: 6.0)
        bRate2.setTitleColor(UIColor.systemBackground, for: .normal)
        bRate2.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 2.0)

        arrondirButton(texte: bRate3, radius: 6.0)
        bRate3.setTitleColor(UIColor.systemBackground, for: .normal)
        bRate3.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 3.0)

        arrondirButton(texte: bRate4, radius: 6.0)
        bRate4.setTitleColor(UIColor.systemBackground, for: .normal)
        bRate4.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 4.0)

        arrondirButton(texte: bRate5, radius: 6.0)
        bRate5.setTitleColor(UIColor.systemBackground, for: .normal)
        bRate5.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 5.0)

        arrondirButton(texte: bRate6, radius: 6.0)
        bRate6.setTitleColor(UIColor.systemBackground, for: .normal)
        bRate6.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 6.0)

        arrondirButton(texte: bRate7, radius: 6.0)
        bRate7.setTitleColor(UIColor.systemBackground, for: .normal)
        bRate7.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 7.0)

        arrondirButton(texte: bRate8, radius: 6.0)
        bRate8.setTitleColor(UIColor.systemBackground, for: .normal)
        bRate8.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 8.0)

        arrondirButton(texte: bRate9, radius: 6.0)
        bRate9.setTitleColor(UIColor.systemBackground, for: .normal)
        bRate9.backgroundColor = colorGradient(borneInf: 0.0, borneSup: 10.0, valeur: 9.0)

        arrondirButton(texte: bRateNone, radius: 6.0)
        bRateNone.setTitleColor(UIColor.systemBackground, for: .normal)
        bRateNone.backgroundColor = .systemGray
        
        for uneSerie in db.shows {
            var serieDejaComptee : Bool = false
            
            for uneSaison in uneSerie.saisons {
                if ( (uneSaison.starts != ZeroDate) &&
                    (uneSaison.ends.compare(today) == .orderedAscending ) && (uneSaison.ends != ZeroDate) &&
                    (uneSaison.watched() == false) && (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) ) {
                    
                    nbEpisodesToSee = nbEpisodesToSee + uneSaison.nbEpisodes - uneSaison.nbWatchedEps
                    
                    if (serieDejaComptee == false) {
                        nbSeriesToSee = nbSeriesToSee + 1
                        serieDejaComptee = true
                    }
                }
            }
        }
        
        nbSeries.text = String(nbSeriesToSee)
        nbSaisons.text = String(db.valSaisonsDiffusees)
        nbEpisodes.text = String(nbEpisodesToSee)
    }
        
}



class GrapheCalendrier: UIView  {
    // Gant view
    // --------------------------
    
    var origineX : CGFloat = 0.0
    var origineY : CGFloat = 0.0
    var hauteur  : CGFloat = 0.0
    var largeur  : CGFloat = 0.0
    
    let bordure  : CGFloat = 10.0
    let nbMonths : Int     = 5
    
    var borneDebut : Date = Date()
    var borneFin : Date = Date()

    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
                              NSAttributedString.Key.paragraphStyle: paragraph,
                              NSAttributedString.Key.foregroundColor: colorAxis]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let now = Date()

        borneDebut = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        borneDebut = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: borneDebut)))!
        
        borneFin = Calendar.current.date(byAdding: .month, value: nbMonths-1, to: now)!
        borneFin = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: borneFin)))!
        borneFin = Calendar.current.date(byAdding: .day, value: -1, to: borneFin)!

        origineX = bordure
        origineY = (self.frame.height - 25.0)
        hauteur  = (self.frame.height - 25.0 - bordure)
        largeur  = (self.frame.width - origineX - bordure)
        
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
        
        // Lignes achurées verticales
        for i:Int in 0 ..< nbMonths {
            let firstDayOfMonth = Calendar.current.date(byAdding: .month, value: i, to: borneDebut)!
            let xFirstDay = origineX + largeur * CGFloat(Calendar.current.dateComponents([.day], from: borneDebut, to: firstDayOfMonth).day!)
                                                / CGFloat(Calendar.current.dateComponents([.day], from: borneDebut, to: borneFin).day!)
            let subAxis : UIBezierPath = UIBezierPath()
            colorAxis.setStroke()

            subAxis.move(to: CGPoint(x: xFirstDay, y: origineY))
            subAxis.addLine(to: CGPoint(x: xFirstDay, y: origineY - hauteur))
            subAxis.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            subAxis.stroke()
            
            let nameOfMonth = dateFormatter.string(from: firstDayOfMonth)
            nameOfMonth.draw(in: CGRect(x: origineX + (largeur * (CGFloat(i)+0.5)/CGFloat(nbMonths)) - 30.0,
                                        y: self.frame.height - 20, width: 60, height: 12), withAttributes: textAttributes)
        }
        
        
        // Barre today
        let xToday = origineX + largeur * CGFloat(Calendar.current.dateComponents([.day], from: borneDebut, to: now).day!)
                                        / CGFloat(Calendar.current.dateComponents([.day], from: borneDebut, to: borneFin).day!)
        let todayLine : UIBezierPath = UIBezierPath()
        UIColor.systemRed.setStroke()
        todayLine.move(to: CGPoint(x: xToday, y: origineY))
        todayLine.addLine(to: CGPoint(x: xToday, y: origineY - hauteur))
        todayLine.stroke()

        
        // Tracer les gants de chaque épisode
        var offset : Int = 0
        for uneSerie in db.shows {
//            if ( uneSerie.unfollowed ) { continue }
//            if (uneSerie.watchlist || uneSerie.unfollowed ) { continue }

            for uneSaison in uneSerie.saisons {
                if (uneSaison.ends.compare(borneDebut) == .orderedDescending ) {
                    offset = offset + 1

                    if ( uneSerie.watchlist ) { // Watchlist
                        traceGantt(debut: uneSaison.starts, fin: uneSaison.ends, offset: offset, serie: uneSerie.serie, color: UIColor.systemGreen)
                    }
                    else if ( uneSerie.unfollowed ) { // Abandonnées
                        traceGantt(debut: uneSaison.starts, fin: uneSaison.ends, offset: offset, serie: uneSerie.serie, color: UIColor.systemRed)
                    }
                    else if ( (uneSaison.starts.compare(now) == .orderedDescending) ) { // Annoncées
                        traceGantt(debut: uneSaison.starts, fin: uneSaison.ends, offset: offset, serie: uneSerie.serie, color: UIColor.systemIndigo)
                    }
                    else if ( (uneSaison.ends.compare(now) == .orderedAscending) ) { // Finies
                        traceGantt(debut: uneSaison.starts, fin: uneSaison.ends, offset: offset, serie: uneSerie.serie, color: UIColor.systemTeal)
                    }
                    else { // En cours
                        traceGantt(debut: uneSaison.starts, fin: uneSaison.ends, offset: offset, serie: uneSerie.serie, color: UIColor.systemBlue)
                    }
                }
            }
        }
    }
    
    
    func traceGantt(debut: Date, fin: Date, offset : Int, serie : String, color: UIColor) {
        if (fin.compare(ZeroDate) == .orderedSame) { return }
        
        let size : CGFloat = 3.0
        let decalY : CGFloat = 10.0
        let intervalle : CGFloat = 26.0
        var xdebut : CGFloat
        var xfin : CGFloat
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
                              NSAttributedString.Key.foregroundColor: color,
                              NSAttributedString.Key.paragraphStyle: paragraph]

        
        if (debut.compare(borneDebut) == .orderedAscending) {
            xdebut = origineX
        }
        else {
            xdebut = origineX + largeur * CGFloat(Calendar.current.dateComponents([.day], from: borneDebut, to: debut).day!)
                                        / CGFloat(Calendar.current.dateComponents([.day], from: borneDebut, to: borneFin).day!)
        }

        
        if (fin.compare(borneFin) == .orderedDescending) {
            xfin = origineX + largeur
        }
        else {
            xfin = origineX + largeur * CGFloat(Calendar.current.dateComponents([.day], from: borneDebut, to: fin).day!)
                                        / CGFloat(Calendar.current.dateComponents([.day], from: borneDebut, to: borneFin).day!)
        }

        if (debut.compare(fin) == .orderedSame) {
            xdebut = xdebut - 1.0
            xfin = xfin + 1.0
        }
        
    
        let path : UIBezierPath = UIBezierPath()
        
        color.setStroke()
        color.withAlphaComponent(0.25).setFill()
        
        path.move(to: CGPoint(x: xdebut, y: origineY - decalY - size - (CGFloat(offset) * intervalle) ))
        path.addLine(to: CGPoint(x: xfin, y: origineY - decalY - size - (CGFloat(offset) * intervalle) ))
        path.addLine(to: CGPoint(x: xfin, y: origineY - decalY + size - (CGFloat(offset) * intervalle) ))
        path.addLine(to: CGPoint(x: xdebut, y: origineY - decalY + size - (CGFloat(offset) * intervalle) ))
        path.addLine(to: CGPoint(x: xdebut, y: origineY - decalY - size - (CGFloat(offset) * intervalle) ))
        path.stroke()
        path.fill()
        
        serie.draw(in: CGRect(x: (xfin + xdebut - 160.0) / 2, y: origineY - decalY + 5.0 - (CGFloat(offset) * intervalle), width: 160, height: 12), withAttributes: textAttributes)
    }
}


class Stat1: UIView  {
    // Camembert
    // --------------------------

    var centreX : CGFloat = 150.0
    var centreY : CGFloat = 150.0
    var rayon : CGFloat = 120.0
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        let total : Int = db.valSeriesAbandonnees + db.valSeriesFinies + db.valWatchList + db.valSeriesEnCours
        
        centreX = 110.0
        centreY = 130.0
        rayon = 80.0
        
        traceUnArc(color: .systemGray, debut: 0.0, fin: CGFloat(db.valSeriesFinies)/CGFloat(total))
        traceUnArc(color: .systemBlue, debut: CGFloat(db.valSeriesFinies)/CGFloat(total), fin: CGFloat(db.valSeriesFinies + db.valSeriesEnCours)/CGFloat(total))
        traceUnArc(color: .systemRed, debut: CGFloat(db.valSeriesFinies + db.valSeriesEnCours)/CGFloat(total), fin: CGFloat(db.valSeriesFinies + db.valSeriesEnCours + db.valSeriesAbandonnees)/CGFloat(total))
        traceUnArc(color: .systemGreen, debut: CGFloat(db.valSeriesFinies + db.valSeriesEnCours + db.valSeriesAbandonnees)/CGFloat(total), fin: 1.0)
        
        let x_label : CGFloat = 215.0
        let y_label : CGFloat = 40.0
        let size : CGFloat = 18.0
        
        var textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: size), NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        "\(db.valSeriesFinies) finies".draw(in: CGRect(x: x_label, y: y_label + 20.0, width: 300, height: 20), withAttributes: textAttributes)
        textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: size), NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        "\(db.valSeriesEnCours) en cours".draw(in: CGRect(x: x_label, y: y_label * 2 + 20.0, width: 300, height: 20), withAttributes: textAttributes)
        textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: size), NSAttributedString.Key.foregroundColor: UIColor.systemRed]
        "\(db.valSeriesAbandonnees) abandonnées".draw(in: CGRect(x: x_label, y: y_label * 3 + 20.0, width: 300, height: 20), withAttributes: textAttributes)
        textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: size), NSAttributedString.Key.foregroundColor: UIColor.systemGreen]
        "\(db.valWatchList) watchlist".draw(in: CGRect(x: x_label, y: y_label * 4 + 20.0, width: 300, height: 20), withAttributes: textAttributes)
    }
    
    func traceUnArc(color: UIColor, debut: CGFloat, fin: CGFloat) {
        UIColor.systemBackground.setStroke()
        color.withAlphaComponent(0.70).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.lineWidth = 2.0
        path.move(to: CGPoint(x: centreX, y: centreY))
        path.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                    radius: rayon,
                    startAngle: 2 * .pi * debut,
                    endAngle: 2 * .pi * fin,
                    clockwise: true)
        path.fill()
        path.stroke()
    }

}

class StatRates: UIView  {
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        let statsAbandonnees    : [Int]
        let statsWatchList      : [Int]
        let statsFinies         : [Int]
        let statsEnCours        : [Int]

        (statsAbandonnees, statsWatchList, statsFinies, statsEnCours) = db.computeStatsPerRate()
        
        for i in 0 ... 9 {
            traceOneRate(index: i, abandonnees: statsAbandonnees[i], watchlist: statsWatchList[i], finies: statsFinies[i], encours: statsEnCours[i])
        }
    }
    
    
    func traceOneRate(index: Int, abandonnees: Int, watchlist: Int, finies: Int, encours: Int) {
        let largeurUnitaire : CGFloat = 5.0
        var newdebut : CGFloat = 40.0
        let origineY : CGFloat = 5.0
        let hauteur : CGFloat = self.frame.height - 40.0
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
                              NSAttributedString.Key.paragraphStyle: paragraph,
                              NSAttributedString.Key.foregroundColor: colorAxis]

        // Lignes
        colorAxis.setStroke()
        
        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: newdebut, y: origineY))
        path.addLine(to: CGPoint(x:newdebut, y: origineY + hauteur))
        path.addLine(to: CGPoint(x:self.frame.width - 5.0, y: origineY + hauteur))
        path.addLine(to: CGPoint(x:self.frame.width - 5.0, y: origineY))
        path.addLine(to: CGPoint(x:newdebut, y: origineY))
        path.stroke()
        
        // Lignes achurées verticales
        for i:Int in 0 ..< Int((self.frame.height - 40.0)/10) {
            let cran = newdebut + CGFloat(10*i) * largeurUnitaire
            
            let subAxis : UIBezierPath = UIBezierPath()
            colorAxis.setStroke()

            subAxis.move(to: CGPoint(x: cran, y: origineY))
            subAxis.addLine(to: CGPoint(x: cran, y: origineY + hauteur))
            subAxis.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            subAxis.stroke()

            String(10*i).draw(in: CGRect(x: cran - 15.0, y: origineY + hauteur + 5.0, width: 30, height: 12), withAttributes: textAttributes)
        }

        
        // Series finies
        traceUnRectangle(xdebut: newdebut, xfin: newdebut + CGFloat(finies) * largeurUnitaire, index : index, color: .systemGray)
        newdebut = newdebut + CGFloat(finies) * largeurUnitaire

        // Series en cours
        traceUnRectangle(xdebut: newdebut, xfin: newdebut + CGFloat(encours) * largeurUnitaire, index : index, color: .systemBlue)
        newdebut = newdebut + CGFloat(encours) * largeurUnitaire

        // Series abandonnees
        traceUnRectangle(xdebut: newdebut, xfin: newdebut + CGFloat(abandonnees) * largeurUnitaire, index : index, color: .systemRed)
        newdebut = newdebut + CGFloat(abandonnees) * largeurUnitaire

        // Series a voir
        traceUnRectangle(xdebut: newdebut, xfin: newdebut + CGFloat(watchlist) * largeurUnitaire, index : index, color: .systemGreen)
    }
    
    
    func traceUnRectangle(xdebut: CGFloat, xfin: CGFloat, index : Int, color: UIColor) {
        let origineY : CGFloat = 219.0
        let interligne : CGFloat = 22.0
        let epaisseur : CGFloat = 8.0

        let path : UIBezierPath = UIBezierPath()

        color.setStroke()
        color.withAlphaComponent(0.50).setFill()
        
        path.move(to: CGPoint(x: xdebut, y: origineY - CGFloat(index) * interligne ))
        path.addLine(to: CGPoint(x: xfin, y: origineY - CGFloat(index) * interligne ))
        path.addLine(to: CGPoint(x: xfin, y: origineY - CGFloat(index) * interligne - epaisseur ))
        path.addLine(to: CGPoint(x: xdebut, y: origineY - CGFloat(index) * interligne - epaisseur ))
        path.addLine(to: CGPoint(x: xdebut, y: origineY - CGFloat(index) * interligne ))
        path.stroke()
        path.fill()
    }
    
}
