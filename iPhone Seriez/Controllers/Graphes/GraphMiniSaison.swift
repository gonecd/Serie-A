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
    var noteTVdb : Int = 0
    var noteBetaSeries : Int = 0
    var noteMoviedb : Int = 0
    var noteIMdb : Int = 0
    
    var theSerie : Serie = Serie(serie: "")
    var theSaison : Int = 0
    var grapheType : Int = 0

    var moyTrakt : Int = 0
    var moyTVdb : Int = 0
    var moyBetaSeries : Int = 0
    var moyMoviedb : Int = 0
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
        if (grapheType == 0)
        {
            self.background()
            self.traceGraphePoints()
        }
        else
        {
            self.backgroundSaisons()
            self.traceAllSaisons()
        }
    }
    
    
    func setType(type : Int) {
        grapheType = type
    }
    
    
    func setSerie(serie : Serie, saison : Int) {
        theSerie = serie
        theSaison = saison
    
        noteTrakt = theSerie.saisons[theSaison-1].getFairRatingTrakt()
        noteTVdb = theSerie.saisons[theSaison-1].getFairRatingTVdb()
        noteBetaSeries = theSerie.saisons[theSaison-1].getFairRatingBetaSeries()
        noteMoviedb = theSerie.saisons[theSaison-1].getFairRatingMoviedb()
        noteIMdb = theSerie.saisons[theSaison-1].getFairRatingIMdb()

        // Calcul des moyennes des saisons précédentes
        var totBetaSeriesMoy : Int = 0
        var totTraktMoy : Int = 0
        var totTVdbMoy : Int = 0
        var totMoviedbMoy : Int = 0
        var totIMdbMoy : Int = 0
        var nbSeasons = 0

        for loopSaison in theSerie.saisons {
            if (loopSaison.saison < theSaison) {
                totBetaSeriesMoy = totBetaSeriesMoy + loopSaison.getFairRatingBetaSeries()
                totTraktMoy = totTraktMoy + loopSaison.getFairRatingTrakt()
                totTVdbMoy = totTVdbMoy + loopSaison.getFairRatingTVdb()
                totMoviedbMoy = totMoviedbMoy + loopSaison.getFairRatingMoviedb()
                totIMdbMoy = totIMdbMoy + loopSaison.getFairRatingIMdb()
                nbSeasons = nbSeasons + 1
            }
        }

        moyTrakt = computeValue(noteCurrentSeason : noteTrakt, totalPrevSeasons : totTraktMoy, nbPrevSeasons : nbSeasons)
        moyTVdb = computeValue(noteCurrentSeason : noteTVdb, totalPrevSeasons : totTVdbMoy, nbPrevSeasons : nbSeasons)
        moyBetaSeries = computeValue(noteCurrentSeason : noteBetaSeries, totalPrevSeasons : totBetaSeriesMoy, nbPrevSeasons : nbSeasons)
        moyMoviedb = computeValue(noteCurrentSeason : noteMoviedb, totalPrevSeasons : totMoviedbMoy, nbPrevSeasons : nbSeasons)
        moyIMdb = computeValue(noteCurrentSeason : noteIMdb, totalPrevSeasons : totIMdbMoy, nbPrevSeasons : nbSeasons)
    }
    
    
    func computeValue(noteCurrentSeason : Int, totalPrevSeasons : Int, nbPrevSeasons : Int) -> Int
    {
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
    
    
    func backgroundSaisons()
    {
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
    

    func traceAllSaisons() {
        var offset : CGFloat = 0.0
        
        for i in 0..<theSaison-1 {
            offset = (largeur * (CGFloat(i)+0.5) / CGFloat(theSaison))
            //traceUneSaison(offsetX: offset, note: theSerie.saisons[i].getFairRatingTVdb(), color: colorTVdb, diametre : 3.0)
            traceUneSaison(offsetX: offset, note: theSerie.saisons[i].getFairRatingTrakt(), color: colorTrakt, diametre : 3.0)
            traceUneSaison(offsetX: offset, note: theSerie.saisons[i].getFairRatingBetaSeries(), color: colorBetaSeries, diametre : 3.0)
            //traceUneSaison(offsetX: offset, note: theSerie.saisons[i].getFairRatingMoviedb(), color: colorMoviedb, diametre : 3.0)
            traceUneSaison(offsetX: offset, note: theSerie.saisons[i].getFairRatingIMdb(), color: colorIMDB, diametre : 3.0)
            
            //traceUnTrait(index : i, nbItem : theSaison, note1 : theSerie.saisons[i].getFairRatingTVdb(), note2 : theSerie.saisons[i+1].getFairRatingTVdb(), color: colorTVdb)
            traceUnTrait(index : i, nbItem : theSaison, note1 : theSerie.saisons[i].getFairRatingTrakt(), note2 : theSerie.saisons[i+1].getFairRatingTrakt(), color: colorTrakt)
            traceUnTrait(index : i, nbItem : theSaison, note1 : theSerie.saisons[i].getFairRatingBetaSeries(), note2 : theSerie.saisons[i+1].getFairRatingBetaSeries(), color: colorBetaSeries)
            //traceUnTrait(index : i, nbItem : theSaison, note1 : theSerie.saisons[i].getFairRatingMoviedb(), note2 : theSerie.saisons[i+1].getFairRatingMoviedb(), color: colorMoviedb)
            traceUnTrait(index : i, nbItem : theSaison, note1 : theSerie.saisons[i].getFairRatingIMdb(), note2 : theSerie.saisons[i+1].getFairRatingIMdb(), color: colorIMDB)
        }
        
        offset = (largeur * (CGFloat(theSaison-1)+0.5) / CGFloat(theSaison))
        //traceUneSaison(offsetX: offset, note: theSerie.saisons[theSaison-1].getFairRatingTVdb(), color: colorTVdb, diametre : 8.0)
        traceUneSaison(offsetX: offset, note: theSerie.saisons[theSaison-1].getFairRatingTrakt(), color: colorTrakt, diametre : 8.0)
        traceUneSaison(offsetX: offset, note: theSerie.saisons[theSaison-1].getFairRatingBetaSeries(), color: colorBetaSeries, diametre : 8.0)
        //traceUneSaison(offsetX: offset, note: theSerie.saisons[theSaison-1].getFairRatingMoviedb(), color: colorMoviedb, diametre : 8.0)
        traceUneSaison(offsetX: offset, note: theSerie.saisons[theSaison-1].getFairRatingIMdb(), color: colorIMDB, diametre : 8.0)
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
        //traceUnPoint(noteX: noteTVdb,           noteY: moyTVdb,        color: colorTVdb)
        traceUnPoint(noteX: noteTrakt,          noteY: moyTrakt,       color: colorTrakt)
        traceUnPoint(noteX: noteBetaSeries,     noteY: moyBetaSeries,  color: colorBetaSeries)
        //traceUnPoint(noteX: noteMoviedb,        noteY: moyMoviedb,     color: colorMoviedb)
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
}
