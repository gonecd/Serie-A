//
//  Graph.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit
import SeriesCommon

class Graph: UIView {
    
    var theSerie : Serie = Serie(serie: "")
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        self.background()
        self.traceGraphePoints()
    }

    
    func sendSerie(_ uneSerie: Serie) {
        theSerie = uneSerie
    }
    
    
    func background() {
        let origineX : CGFloat = 30.0
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
        let largeur : CGFloat = (self.frame.width - origineX - 10.0)
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: colorAxis]
        let nbSaisons : Int = theSerie.saisons.count

       // Fond
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true

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
        for i:Int in 1 ..< 4 {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.move(to: CGPoint(x: origineX, y: origineY - (hauteur * CGFloat(i)/4)))
            pathLine.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur * CGFloat(i)/4)))

            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.stroke()
        }

        // Légende en Y
        for i:Int in 0 ..< 5 {
            let episode : NSString = String(i*25) as NSString
            episode.draw(in: CGRect(x: 7, y: origineY - (hauteur * CGFloat(i)/4) - 7, width: 20, height: 10), withAttributes: textAttributes)
        }

        // Coches verticales
        for i:Int in 0 ..< nbSaisons {
            let saison : NSString = String(i+1) as NSString
            saison.draw(in: CGRect(x: origineX - 5.0 + (largeur * (CGFloat(i)+0.5) / CGFloat(nbSaisons)),
                                   y: self.frame.height - 25, width: 15, height: 12), withAttributes: textAttributes)
        }

        if (nbSaisons < 1) { return }

        // Lignes hachurées verticale
        for i:Int in 1 ..< nbSaisons
        {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.move(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbSaisons)), y: origineY))
            pathLine.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbSaisons)), y: origineY - hauteur))

            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.stroke()
        }
    }
    
    
    func traceGraphePoints() {
        let nbSaisons : Int = theSerie.saisons.count
        let origineX : CGFloat = 30.0
        let largeur : CGFloat = (self.frame.width - origineX - 10.0)

        for i:Int in 0 ..< nbSaisons {
            let offset : CGFloat = (largeur * (CGFloat(i)+0.5) / CGFloat(nbSaisons))
            
            traceUnPoint(theSerie.saisons[i].getFairRatingTrakt(), uneCouleur: colorTrakt, offsetSaison: offset, offsetSource: 0)
            traceUnPoint(theSerie.saisons[i].getFairRatingBetaSeries(), uneCouleur: colorBetaSeries, offsetSaison: offset, offsetSource: 5)
            traceUnPoint(theSerie.saisons[i].getFairRatingIMdb(), uneCouleur: colorIMDB, offsetSaison: offset, offsetSource: 10)
        }
    }


    func traceUnPoint(_ uneNote: Int, uneCouleur: UIColor, offsetSaison: CGFloat, offsetSource: CGFloat)
    {
        let diametre : CGFloat = 10.0
        let origineX : CGFloat = 30.0
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
        var note : Int = uneNote
        
        if (uneNote == 0) { return }
        if (uneNote > 100 ) { note = 100 }
        if (uneNote < 0 ) { note = 0 }

        uneCouleur.setStroke()
        uneCouleur.setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX - 5 + offsetSaison + offsetSource,
                                        y: origineY - (hauteur * CGFloat(note) / 100)),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        path.lineWidth = 2.0
        path.stroke()
    }

}
