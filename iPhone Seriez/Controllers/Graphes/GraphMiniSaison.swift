//
//  GraphMiniSaison.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit
import SeriesCommon

class GraphMiniSaison: UIView {
    
    var noteTrakt : Int = 0
    var noteBetaSeries : Int = 0
    var noteIMdb : Int = 0
    
    var theSerie : Serie = Serie(serie: "")
    var theSaison : Int = 0
    var grapheType : Int = 0

    var moyTrakt : Int = 0
    var moyBetaSeries : Int = 0
    var moyIMdb : Int = 0
    
    var origineX : CGFloat = 0.0
    var origineY :CGFloat = 0.0
    var hauteur : CGFloat = 0.0
    var largeur : CGFloat = 0.0
    let bordure : CGFloat = 5.0
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        origineX = bordure
        origineY = (self.frame.height - bordure)
        hauteur  = (self.frame.height - bordure - bordure)
        largeur  = (self.frame.width - origineX - bordure)
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = true
        
        // Drawing code here.
        if (grapheType == 0) {
            self.background()
            self.traceGraphePoints()
        }
        else if (grapheType == 1) {
            self.backgroundSaisons()
            self.traceAllSaisons()
        }
        else if (grapheType == 2) {
            self.backgroundEpisodes()
            self.traceAllEpisodes()
        }
        else if (grapheType == 3) {
            self.backgroundEpisodes()
            self.traceAllEpisodesBox()
        }
    }
    
    
    func setType(type : Int) {
        grapheType = type
    }
    
    
    func setSerie(serie : Serie, saison : Int) {
        theSerie = serie
        theSaison = saison
    
        noteTrakt = theSerie.saisons[theSaison-1].getFairRatingTrakt()
        noteBetaSeries = theSerie.saisons[theSaison-1].getFairRatingBetaSeries()
        noteIMdb = theSerie.saisons[theSaison-1].getFairRatingIMdb()

        // Calcul des moyennes des saisons précédentes
        var totBetaSeriesMoy : Int = 0
        var totTraktMoy : Int = 0
        var totIMdbMoy : Int = 0
        var nbSeasons = 0

        for loopSaison in theSerie.saisons {
            if (loopSaison.saison < theSaison) {
                totBetaSeriesMoy = totBetaSeriesMoy + loopSaison.getFairRatingBetaSeries()
                totTraktMoy = totTraktMoy + loopSaison.getFairRatingTrakt()
                totIMdbMoy = totIMdbMoy + loopSaison.getFairRatingIMdb()
                nbSeasons = nbSeasons + 1
            }
        }

        moyTrakt = computeValue(noteCurrentSeason : noteTrakt, totalPrevSeasons : totTraktMoy, nbPrevSeasons : nbSeasons)
        moyBetaSeries = computeValue(noteCurrentSeason : noteBetaSeries, totalPrevSeasons : totBetaSeriesMoy, nbPrevSeasons : nbSeasons)
        moyIMdb = computeValue(noteCurrentSeason : noteIMdb, totalPrevSeasons : totIMdbMoy, nbPrevSeasons : nbSeasons)
    }
    
    
    func computeValue(noteCurrentSeason : Int, totalPrevSeasons : Int, nbPrevSeasons : Int) -> Int {
        if ((nbPrevSeasons == 0) || (totalPrevSeasons == 0) ) { return 50 }
        
        let moyPrevSeasons : Int = Int( Double(totalPrevSeasons) / Double(nbPrevSeasons) )
        let difference : Int = Int((Double((noteCurrentSeason - moyPrevSeasons)) / Double(moyPrevSeasons)) * 100 )
        
        return (50 + difference)
    }

    
    func background() {
        let path : UIBezierPath = UIBezierPath()
        let longueurFleche : CGFloat = 3.0
        
        // Couleur des lignes
        colorAxis.setStroke()
        path.lineWidth = 0.5
        
        // Lignes horizontales
        path.move(to: CGPoint(x: origineX, y: origineY - (hauteur / 2)))
        path.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur / 2)))
        path.stroke()
        
        path.move(to: CGPoint(x: origineX + largeur - longueurFleche, y: origineY - (hauteur / 2) - longueurFleche))
        path.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur / 2)))
        path.addLine(to: CGPoint(x: origineX + largeur - longueurFleche, y: origineY - (hauteur / 2) + longueurFleche))
        path.stroke()
        
        // Lignes verticales
        path.move(to: CGPoint(x: origineX + (largeur / 2), y: origineY))
        path.addLine(to: CGPoint(x: origineX + (largeur / 2), y: origineY - hauteur))
        path.stroke()
        
        path.move(to: CGPoint(x: origineX + (largeur / 2) - longueurFleche, y: origineY - hauteur + longueurFleche))
        path.addLine(to: CGPoint(x: origineX + (largeur / 2), y: origineY - hauteur))
        path.addLine(to: CGPoint(x: origineX + (largeur / 2) + longueurFleche, y: origineY - hauteur + longueurFleche))
        path.stroke()
    }
    
    
    func backgroundSaisons() {
        // Couleur des lignes
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
        
        // Quadrillage
        let path2 : UIBezierPath = UIBezierPath()
        path2.lineWidth = 0.5
        path2.setLineDash([5.0,5.0], count: 2, phase: 5.0)
        path2.move(to: CGPoint(x: origineX, y: origineY - (hauteur / 2)))
        path2.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur / 2)))
        path2.stroke()
        
        path2.move(to: CGPoint(x: origineX, y: origineY - (hauteur / 2) - (hauteur / 4)))
        path2.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur / 2) - (hauteur / 4)))
        path2.stroke()
        
        path2.move(to: CGPoint(x: origineX, y: origineY - (hauteur / 4)))
        path2.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur / 4)))
        path2.stroke()
    }
    

    func backgroundEpisodes() {
        // Couleur des lignes
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
        
        // Quadrillage
        let path2 : UIBezierPath = UIBezierPath()
        path2.lineWidth = 0.5
        path2.setLineDash([5.0,5.0], count: 2, phase: 5.0)
        path2.move(to: CGPoint(x: origineX, y: origineY - (hauteur / 2)))
        path2.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur / 2)))
        path2.stroke()
        
        path2.move(to: CGPoint(x: origineX, y: origineY - (hauteur / 2) - (hauteur / 4)))
        path2.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur / 2) - (hauteur / 4)))
        path2.stroke()
        
        path2.move(to: CGPoint(x: origineX, y: origineY - (hauteur / 4)))
        path2.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur / 4)))
        path2.stroke()

        path2.move(to: CGPoint(x: origineX + (largeur / 2), y: origineY))
        path2.addLine(to: CGPoint(x: origineX + (largeur / 2), y: origineY - hauteur ))
        path2.stroke()
    }
    
    
    func traceAllSaisons() {
        var offset : CGFloat = 0.0
        
        for i in 0..<theSaison-1 {
            offset = (largeur * (CGFloat(i)+0.5) / CGFloat(theSaison))
            traceUneSaison(offsetX: offset, note: theSerie.saisons[i].getFairRatingTrakt(), color: colorTrakt, diametre : 3.0)
            traceUneSaison(offsetX: offset, note: theSerie.saisons[i].getFairRatingBetaSeries(), color: colorBetaSeries, diametre : 3.0)
            traceUneSaison(offsetX: offset, note: theSerie.saisons[i].getFairRatingIMdb(), color: colorIMDB, diametre : 3.0)
            
            traceUnTrait(index : i, nbItem : theSaison, note1 : theSerie.saisons[i].getFairRatingTrakt(), note2 : theSerie.saisons[i+1].getFairRatingTrakt(), color: colorTrakt)
            traceUnTrait(index : i, nbItem : theSaison, note1 : theSerie.saisons[i].getFairRatingBetaSeries(), note2 : theSerie.saisons[i+1].getFairRatingBetaSeries(), color: colorBetaSeries)
            traceUnTrait(index : i, nbItem : theSaison, note1 : theSerie.saisons[i].getFairRatingIMdb(), note2 : theSerie.saisons[i+1].getFairRatingIMdb(), color: colorIMDB)
        }
        
        offset = (largeur * (CGFloat(theSaison-1)+0.5) / CGFloat(theSaison))
        traceUneSaison(offsetX: offset, note: theSerie.saisons[theSaison-1].getFairRatingTrakt(), color: colorTrakt, diametre : 8.0)
        traceUneSaison(offsetX: offset, note: theSerie.saisons[theSaison-1].getFairRatingBetaSeries(), color: colorBetaSeries, diametre : 8.0)
        traceUneSaison(offsetX: offset, note: theSerie.saisons[theSaison-1].getFairRatingIMdb(), color: colorIMDB, diametre : 8.0)
    }
    
    
    func traceAllEpisodes() {
        let today : Date = Date()
        
        for unEpisode in theSerie.saisons[theSaison-1].episodes {
            if ( (unEpisode.date.compare(today) == .orderedAscending) && (unEpisode.date.compare(ZeroDate) != .orderedSame) ) {
                traceUnPoint(note: unEpisode.getFairRatingTrakt(), ligne: 1, color: colorTrakt)
                traceUnPoint(note: unEpisode.getFairRatingBetaSeries(), ligne: 2, color: colorBetaSeries)
                traceUnPoint(note: unEpisode.getFairRatingIMdb(), ligne: 3, color: colorIMDB)
            }
        }
    }
    
    
    func traceAllEpisodesBox() {
        var minTrakt : Int = 100
        var minBetaSeries : Int = 100
        var minIMdb : Int = 100
        
        var maxTrakt : Int = 0
        var maxBetaSeries : Int = 0
        var maxIMdb : Int = 0
        
        let today : Date = Date()
        
        for unEpisode in theSerie.saisons[theSaison-1].episodes {
            if ( (unEpisode.date.compare(today) == .orderedAscending) && (unEpisode.date.compare(ZeroDate) != .orderedSame) ) {
                if ((unEpisode.getFairRatingTrakt() < minTrakt) && (unEpisode.ratingTrakt != 0) ) { minTrakt = unEpisode.getFairRatingTrakt() }
                if (unEpisode.getFairRatingTrakt() > maxTrakt) { maxTrakt = unEpisode.getFairRatingTrakt() }
                
                if ((unEpisode.getFairRatingBetaSeries() < minBetaSeries) && (unEpisode.ratingBetaSeries != 0) ) { minBetaSeries = unEpisode.getFairRatingBetaSeries() }
                if (unEpisode.getFairRatingBetaSeries() > maxBetaSeries) { maxBetaSeries = unEpisode.getFairRatingBetaSeries() }
                
                if ((unEpisode.getFairRatingIMdb() < minIMdb) && (unEpisode.ratingIMdb != 0) ) { minIMdb = unEpisode.getFairRatingIMdb() }
                if (unEpisode.getFairRatingIMdb() > maxIMdb) { maxIMdb = unEpisode.getFairRatingIMdb() }
            }
        }
        
        traceUneBox(min: minTrakt, max: maxTrakt, moy: theSerie.saisons[theSaison-1].getFairRatingTrakt(), ligne: 1, color: colorTrakt)
        traceUneBox(min: minBetaSeries, max: maxBetaSeries, moy: theSerie.saisons[theSaison-1].getFairRatingBetaSeries(), ligne: 2, color: colorBetaSeries)
        traceUneBox(min: minIMdb, max: maxIMdb, moy: theSerie.saisons[theSaison-1].getFairRatingIMdb(), ligne: 3, color: colorIMDB)
    }
    
    
    func traceUnTrait(index : Int, nbItem : Int,  note1 : Int, note2 : Int, color: UIColor) {
        color.setStroke()
        
        if (note1 == 0) { return }
        if (note2 == 0) { return }

        let path : UIBezierPath = UIBezierPath()
        path.lineWidth = 0.5

        path.move(to: CGPoint(x: origineX + (largeur * (CGFloat(index)+0.5) / CGFloat(nbItem)),
                              y: origineY - (hauteur * CGFloat(note1) / 100)))
        path.addLine(to: CGPoint(x: origineX + (largeur * (CGFloat(index+1)+0.5) / CGFloat(nbItem)),
                                 y: origineY - ( hauteur * CGFloat(note2) / 100) ))
        
        path.stroke()
    }
    
    
    func traceUneSaison(offsetX: CGFloat, note: Int, color: UIColor, diametre : CGFloat) {
        color.setStroke()
        color.withAlphaComponent(0.5).setFill()
        
        if (note == 0) { return }
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX + offsetX,
                                        y: origineY - (hauteur * CGFloat(note) / 100)),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        
        path.stroke()
        path.fill()
    }
    
    
    func traceGraphePoints() {
        traceUnPoint(noteX: noteTrakt,          noteY: moyTrakt,       color: colorTrakt)
        traceUnPoint(noteX: noteBetaSeries,     noteY: moyBetaSeries,  color: colorBetaSeries)
        traceUnPoint(noteX: noteIMdb,           noteY: moyIMdb,        color: colorIMDB)
    }
    
    
    func traceUnPoint(noteX: Int, noteY: Int, color: UIColor) {
        let diametre : CGFloat = 8.0

        color.setStroke()
        color.withAlphaComponent(0.5).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX + (largeur * CGFloat(noteX) / 100),
                                        y: origineY - (hauteur * CGFloat(noteY) / 100)),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        
        path.stroke()
        path.fill()
    }


    func traceUnPoint(note: Int, ligne: Int, color: UIColor) {
        let diametre : CGFloat = 8.0

        color.setStroke()
        color.withAlphaComponent(0.25).setFill()
        
        var noteAffichee : Int = note
        if (note == 0 ) { return }
        if (note > 100) { noteAffichee = 100 }
        if (note < 0) { noteAffichee = 0 }
        
        color.setStroke()
        color.withAlphaComponent(0.5).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX + (largeur * CGFloat(noteAffichee) / 100),
                                        y: origineY - (hauteur * CGFloat(25*ligne) / 100)),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        
        path.stroke()
        path.fill()
    }
   
    func traceUneBox(min: Int, max: Int, moy : Int, ligne: Int, color: UIColor) {
        let size : CGFloat = 3.0
        if (max == 0 ) { return }
        if (min == 100 ) { return }

        var mymax : Int = max
        var mymin : Int = min
        var mymoy : Int = moy
        if (max > 100 ) { mymax = 100 }
        if (min <= 0 ) { mymin = 0 }
        if (moy > 100 ) { mymoy = 100 }
        if (moy < 0 ) { mymoy = 0 }

        let path : UIBezierPath = UIBezierPath()

        color.setStroke()
        color.withAlphaComponent(0.25).setFill()

        path.move(to: CGPoint(x: origineX + (largeur * CGFloat(mymin) / 100), y: origineY - size - (hauteur * CGFloat(25*ligne) / 100)))
        path.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(mymax) / 100), y: origineY - size - (hauteur * CGFloat(25*ligne) / 100)))
        path.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(mymax) / 100), y: origineY + size - (hauteur * CGFloat(25*ligne) / 100)))
        path.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(mymin) / 100), y: origineY + size - (hauteur * CGFloat(25*ligne) / 100)))
        path.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(mymin) / 100), y: origineY - size - (hauteur * CGFloat(25*ligne) / 100)))
        path.stroke()
        path.fill()
        
        let path2 : UIBezierPath = UIBezierPath()
        path2.move(to: CGPoint(x: origineX + (largeur * CGFloat(mymoy-1) / 100), y: origineY - size - size - (hauteur * CGFloat(25*ligne) / 100)))
        path2.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(mymoy+1) / 100), y: origineY - size - size - (hauteur * CGFloat(25*ligne) / 100)))
        path2.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(mymoy+1) / 100), y: origineY + size + size - (hauteur * CGFloat(25*ligne) / 100)))
        path2.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(mymoy-1) / 100), y: origineY + size + size - (hauteur * CGFloat(25*ligne) / 100)))
        path2.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(mymoy-1) / 100), y: origineY - size - size - (hauteur * CGFloat(25*ligne) / 100)))
        path2.stroke()
        color.setFill()
        path2.fill()
    }

}
