//
//  GraphSaison.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit

class GraphSaison: UIView {

    var theSaison : Saison = Saison(serie:"", saison:0)
    let origineX : CGFloat = 5.0

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)

        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = true

        // Drawing code here.
        self.background()
        self.traceGraphePoints()
    }


    func sendSaison(_ uneSaison: Saison) {
        theSaison = uneSaison
    }

    func background() {
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 5.0)
        let largeur : CGFloat = (self.frame.width - origineX - 5.0)
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: colorAxis]
        let nbEpisodes : Int = theSaison.nbEpisodes

        // Lignes
        colorAxis.setStroke()

        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.lineWidth = 0.5
        path.move(to: CGPoint(x: origineX, y: origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY))
        path.stroke()

        // Lignes achurées horizontales
        for i:Int in 1 ..< 4 {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.lineWidth = 0.5
            pathLine.move(to: CGPoint(x: origineX, y: origineY - (hauteur * CGFloat(i)/4)))
            pathLine.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur * CGFloat(i)/4)))

            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.stroke()
        }

        // Légende en Y
//        for i:Int in 0 ..< 5 {
//            let episode : NSString = String(i*25) as NSString
//            episode.draw(in: CGRect(x: 8, y: origineY - (hauteur * CGFloat(i)/4) - 7, width: 30, height: 10), withAttributes: textAttributes)
//        }

        // Coches verticales
        for i:Int in 0 ..< nbEpisodes {
            let saison : NSString = String(i+1) as NSString
            saison.draw(in: CGRect(x: origineX - 5.0 + (largeur * (CGFloat(i)+0.5) / CGFloat(nbEpisodes)),
                                   y: self.frame.height - 25, width: 15, height: 12),
                        withAttributes: textAttributes)
        }

        if (nbEpisodes < 1) { return }

        // Lignes hachurées verticales
        for i:Int in 1 ..< nbEpisodes {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.move(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbEpisodes)), y: origineY))
            pathLine.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbEpisodes)), y: origineY - hauteur))

            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.stroke()
        }
    }


    func traceGraphePoints() {
        let nbEpisodes : Int = theSaison.nbEpisodes
        let largeur : CGFloat = (self.frame.width - origineX - 10.0)

        for i:Int in 0 ..< theSaison.episodes.count {
            let offset : CGFloat = (largeur * (CGFloat(i)+0.5) / CGFloat(nbEpisodes))

            traceUnPoint(theSaison.episodes[i].getFairRatingTrakt(), uneCouleur: colorTrakt, offsetEpisode: offset, offsetSource: 4, nbRaters : theSaison.episodes[i].ratersTrakt)
            traceUnPoint(theSaison.episodes[i].getFairRatingBetaSeries(), uneCouleur: colorBetaSeries, offsetEpisode: offset, offsetSource: 6, nbRaters : theSaison.episodes[i].ratersBetaSeries)
            traceUnPoint(theSaison.episodes[i].getFairRatingIMdb(), uneCouleur: colorIMDB, offsetEpisode: offset, offsetSource: 10, nbRaters : theSaison.episodes[i].ratersIMdb)
        }
    }


    func traceUnPoint(_ uneNote: Int, uneCouleur: UIColor, offsetEpisode: CGFloat, offsetSource: CGFloat, nbRaters : Int) {
        let diametre : CGFloat = 6.0
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
        var note : Int = uneNote
        
        if (uneNote == 0) { return }
        if (uneNote > 100 ) { note = 100 }
        if (uneNote < 0 ) { note = 0 }

        uneCouleur.setStroke()
        uneCouleur.setFill()

        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX - 5 + offsetEpisode + offsetSource,
                                        y: origineY - (hauteur * CGFloat(note) / 100) ),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        path.stroke()
        
        if (nbRaters > 10) { path.fill() }
    }
}
