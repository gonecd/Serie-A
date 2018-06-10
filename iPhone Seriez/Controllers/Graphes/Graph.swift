//
//  Graph.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit

class Graph: UIView {
    
    var grapheType : Int = 0
    var theSerie : Serie = Serie(serie: "")
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        self.background()
        if (grapheType == 0) { self.traceGraphePoints() }
        if (grapheType == 1) { self.traceGrapheLignes() }
    }

    
    func change()
    {
        if (grapheType == 0) { grapheType = 1 }
        else if (grapheType == 1) { grapheType = 0 }
        
        self.setNeedsDisplay()
    }
    

    func sendSerie(_ uneSerie: Serie)
    {
        theSerie = uneSerie
    }
    
    
    func background()
    {
        let origineX : CGFloat = 30.0
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
        let largeur : CGFloat = (self.frame.width - origineX - 10.0)
        let textAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: colorAxis]
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
            episode.draw(in: CGRect(x: 7, y: origineY - (hauteur * CGFloat(i)/4) - 7, width: 20, height: 10), withAttributes: textAttributes)
        }

        // Coches verticales
        for i:Int in 0 ..< nbSaisons
        {
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
    
    
    func traceGraphePoints()
    {
        let nbSaisons : Int = theSerie.saisons.count
        let origineX : CGFloat = 30.0
        let largeur : CGFloat = (self.frame.width - origineX - 10.0)

        for i:Int in 0 ..< nbSaisons
        {
            let offset : CGFloat = (largeur * (CGFloat(i)+0.5) / CGFloat(nbSaisons))
            
            traceUnPoint(theSerie.saisons[i].getFairRatingTVdb(), uneCouleur: colorTVdb, offsetSaison: offset, offsetSource: 0)
            traceUnPoint(theSerie.saisons[i].getFairRatingTrakt(), uneCouleur: colorTrakt, offsetSaison: offset, offsetSource: 2)
            traceUnPoint(theSerie.saisons[i].getFairRatingBetaSeries(), uneCouleur: colorBetaSeries, offsetSaison: offset, offsetSource: 4)
            traceUnPoint(theSerie.saisons[i].getFairRatingMoviedb(), uneCouleur: colorMoviedb, offsetSaison: offset, offsetSource: 8)
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


    func traceGrapheLignes()
    {
        let uneCase : CGFloat = (self.frame.width - 30.0 - 10.0) / CGFloat(theSerie.saisons.count)

        for uneSaison in theSerie.saisons
        {
            let nbEps: Int = uneSaison.episodes.count
            var locNotesTVdb: [Int] = [Int]()
            var locNotesTrakt: [Int] = [Int]()
            var locNotesBetaSeries: [Int] = [Int]()
            var locNotesMoviedb: [Int] = [Int]()
            var locNotesIMdb: [Int] = [Int]()

            for i:Int in 0 ..< nbEps
            {
                locNotesTVdb.append(uneSaison.episodes[i].getFairRatingTVdb())
                locNotesTrakt.append(uneSaison.episodes[i].getFairRatingTrakt())
                locNotesBetaSeries.append(uneSaison.episodes[i].getFairRatingBetaSeries())
                locNotesMoviedb.append(uneSaison.episodes[i].getFairRatingMoviedb())
                locNotesIMdb.append(uneSaison.episodes[i].getFairRatingIMdb())
            }

            traceLigne(locNotesTVdb, nbEpisodes: nbEps, uneCouleur: colorTVdb, offsetSaison: uneSaison.saison, largeur: uneCase)
            traceLigne(locNotesTrakt, nbEpisodes: nbEps, uneCouleur: colorTrakt, offsetSaison: uneSaison.saison, largeur: uneCase)
            traceLigne(locNotesBetaSeries, nbEpisodes: nbEps, uneCouleur: colorBetaSeries, offsetSaison: uneSaison.saison, largeur: uneCase)
            traceLigne(locNotesMoviedb, nbEpisodes: nbEps, uneCouleur: colorMoviedb, offsetSaison: uneSaison.saison, largeur: uneCase)
            traceLigne(locNotesIMdb, nbEpisodes: nbEps, uneCouleur: colorIMDB, offsetSaison: uneSaison.saison, largeur: uneCase)
        }
    }


    func traceLigne(_ desNotes: [Int], nbEpisodes: Int, uneCouleur: UIColor, offsetSaison: Int, largeur: CGFloat)
    {
        let origineX : CGFloat = 30.0 + (CGFloat(offsetSaison - 1) * largeur)
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)

        // Regression linéaire
        var sigmaX : Double = 0.0
        var sigmaX2 : Double = 0.0
        var sigmaY : Double = 0.0
        var sigmaXY : Double = 0.0
        var n : Double = 0.0

        for i:Int in 0 ..< nbEpisodes
        {
            if desNotes[i] != 0
            {
                let X : Double = Double(i+1)
                sigmaX = sigmaX + X
                sigmaY = sigmaY + Double(desNotes[i])
                sigmaX2 = sigmaX2 + (X * X)
                sigmaXY = sigmaXY + (X * Double(desNotes[i]))
                n = n + 1.0
            }
        }

        // Tracé de la droite
        if (n > 3.0)
        {
            let B : Double = ((n * sigmaXY) - (sigmaX * sigmaY)) / ((n * sigmaX2) - (sigmaX * sigmaX))
            let A : Double = (sigmaY / n) - B * (sigmaX / n)

            let path : UIBezierPath = UIBezierPath()
            path.move(to: CGPoint(x: origineX + (largeur * 0.5 / CGFloat(nbEpisodes)),
                                  y: (origineY - (hauteur * CGFloat(A + B))/100)))
            path.addLine(to: CGPoint(x: origineX + (largeur * (CGFloat(nbEpisodes-1)+0.5) / CGFloat(nbEpisodes)),
                                     y: (origineY - (hauteur * CGFloat(A + (B * Double(nbEpisodes))))/100)))
            uneCouleur.setStroke()
            path.lineWidth = 2.0

            path.stroke()
        }
    }

}
