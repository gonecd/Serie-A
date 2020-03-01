//
//  Statistiques.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 26/01/2020.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit
import SeriesCommon

class Statistiques: UIViewController {
    
    
    
    @IBOutlet weak var graphe1: Stat1!
    @IBOutlet weak var graphe2: UIView!
    @IBOutlet weak var graphe3: Stat3!
    
    @IBOutlet weak var nbEpisodes: UILabel!
    @IBOutlet weak var nbSaisons: UILabel!
    @IBOutlet weak var nbSeries: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let today : Date = Date()
        var nbSeriesToSee : Int = 0
        var nbEpisodesToSee : Int = 0
        
        makeGradiant(carre: graphe1, couleur: "Blanc")
        makeGradiant(carre: graphe2, couleur: "Blanc")
        makeGradiant(carre: graphe3, couleur: "Blanc")
        
        graphe1.setNeedsDisplay()
        
        for uneSerie in db.shows {
            var serieDejaComptee : Bool = false
            
            for uneSaison in uneSerie.saisons {
                if ( (uneSaison.starts != ZeroDate) &&
                    (uneSaison.ends.compare(today) == .orderedAscending ) && (uneSaison.ends != ZeroDate) &&
                    (uneSaison.watched() == false) && (uneSerie.watchlist == false) && (uneSerie.unfollowed == false) ) {
                    
                    nbEpisodesToSee = nbEpisodesToSee + uneSaison.nbEpisodes
                    
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



class Stat3: UIView  {
    
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
                              NSAttributedString.Key.paragraphStyle: paragraph]
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
        
        // Lignes achurées horizontales
        for i:Int in 0 ..< nbMonths {
            let firstDayOfMonth = Calendar.current.date(byAdding: .month, value: i, to: borneDebut)!
            let xFirstDay = origineX + largeur * CGFloat(Calendar.current.dateComponents([.day], from: borneDebut, to: firstDayOfMonth).day!)
                                                / CGFloat(Calendar.current.dateComponents([.day], from: borneDebut, to: borneFin).day!)
            let subAxis : UIBezierPath = UIBezierPath()

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
            if (uneSerie.watchlist || uneSerie.unfollowed ) { continue }
            
            for uneSaison in uneSerie.saisons {
                if (uneSaison.ends.compare(borneDebut) == .orderedDescending ) {
                    offset = offset + 1

                    if ( (uneSaison.starts.compare(now) == .orderedDescending) ) { // Annoncées
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
    
    var centreX : CGFloat = 150.0
    var centreY : CGFloat = 150.0
    var rayon : CGFloat = 120.0
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        let total : Int = db.valSeriesAbandonnees + db.valSeriesFinies + db.valWatchList + db.valSeriesEnCours
        
        traceUnCercle(color: .systemGray, debut: 0.0, fin: CGFloat(db.valSeriesFinies)/CGFloat(total))
        traceUnCercle(color: .systemBlue, debut: CGFloat(db.valSeriesFinies)/CGFloat(total), fin: CGFloat(db.valSeriesFinies + db.valSeriesEnCours)/CGFloat(total))
        traceUnCercle(color: .systemRed, debut: CGFloat(db.valSeriesFinies + db.valSeriesEnCours)/CGFloat(total), fin: CGFloat(db.valSeriesFinies + db.valSeriesEnCours + db.valSeriesAbandonnees)/CGFloat(total))
        traceUnCercle(color: .systemGreen, debut: CGFloat(db.valSeriesFinies + db.valSeriesEnCours + db.valSeriesAbandonnees)/CGFloat(total), fin: 1.0)
        
        var textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        "\(db.valSeriesFinies) séries finies".draw(in: CGRect(x: 300.0, y: 50, width: 300, height: 25), withAttributes: textAttributes)
        textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        "\(db.valSeriesEnCours) séries en cours".draw(in: CGRect(x: 300.0, y: 100, width: 300, height: 25), withAttributes: textAttributes)
        textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.systemRed]
        "\(db.valSeriesAbandonnees) séries abandonnées".draw(in: CGRect(x: 300.0, y: 150, width: 300, height: 25), withAttributes: textAttributes)
        textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.systemGreen]
        "\(db.valWatchList) séries à voir ?".draw(in: CGRect(x: 300.0, y: 200, width: 300, height: 25), withAttributes: textAttributes)
    }
    
    
    func traceUnCercle(color: UIColor, debut: CGFloat, fin: CGFloat) {
        UIColor.systemBackground.setStroke()
        color.setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.lineWidth = 3.0
        if (fin - debut < 0.5) {
            path.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                        radius: rayon,
                        startAngle: 2 * .pi * debut,
                        endAngle: 2 * .pi * fin,
                        clockwise: true)
            path.move(to: CGPoint(x: centreX + rayon*cos(2 * .pi * debut), y:centreY + rayon*sin(2 * .pi * debut)))
            path.addLine(to: CGPoint(x: centreX, y: centreY))
            path.addLine(to: CGPoint(x: centreX + rayon*cos(2 * .pi * fin), y:centreY + rayon*sin(2 * .pi * fin)))
            path.fill()
            path.stroke()
        }
        else{
            color.setStroke()
            
            let pathTmp1 : UIBezierPath = UIBezierPath()
            pathTmp1.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                            radius: rayon,
                            startAngle: 2 * .pi * debut,
                            endAngle: 2 * .pi * (debut+0.5),
                            clockwise: true)
            pathTmp1.move(to: CGPoint(x: centreX + rayon*cos(2 * .pi * debut), y:centreY + rayon*sin(2 * .pi * debut)))
            pathTmp1.addLine(to: CGPoint(x: centreX, y: centreY))
            pathTmp1.addLine(to: CGPoint(x: centreX + rayon*cos(2 * .pi * (debut+0.5) ), y:centreY + rayon*sin(2 * .pi * (debut+0.5))))
            pathTmp1.fill()
            pathTmp1.stroke()
            
            let pathTmp2 : UIBezierPath = UIBezierPath()
            pathTmp2.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                            radius: rayon,
                            startAngle: 2 * .pi * (debut+0.5),
                            endAngle: 2 * .pi * fin,
                            clockwise: true)
            pathTmp2.move(to: CGPoint(x: centreX + rayon*cos(2 * .pi * (debut+0.5)), y:centreY + rayon*sin(2 * .pi * (debut+0.5))))
            pathTmp2.addLine(to: CGPoint(x: centreX, y: centreY))
            pathTmp2.addLine(to: CGPoint(x: centreX + rayon*cos(2 * .pi * fin), y:centreY + rayon*sin(2 * .pi * fin)))
            pathTmp2.fill()
            pathTmp2.stroke()
            
            UIColor.systemBackground.setStroke()
            path.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                        radius: rayon,
                        startAngle: 2 * .pi * debut,
                        endAngle: 2 * .pi * fin,
                        clockwise: true)
            path.move(to: CGPoint(x: centreX + rayon*cos(2 * .pi * debut), y:centreY + rayon*sin(2 * .pi * debut)))
            path.addLine(to: CGPoint(x: centreX, y: centreY))
            path.addLine(to: CGPoint(x: centreX + rayon*cos(2 * .pi * fin), y:centreY + rayon*sin(2 * .pi * fin)))
            path.stroke()
        }
    }
    
}
