//
//  GraphEpisode.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit
import SeriesCommon

class GraphEpisode: UIView {
    
    var origineX : CGFloat = 0.0
    var origineY : CGFloat = 0.0
    var hauteur  : CGFloat = 0.0
    var largeur  : CGFloat = 0.0
    var bordure  : CGFloat = 10.0
    
    let colW : CGFloat = 130.0
    let linH : CGFloat = 30.0
    
    var noteTrakt : Int = 0
    var noteTVdb : Int = 0
    var noteBetaSerie : Int = 0
    var noteMovieDB : Int = 0
    var noteIMDB : Int = 0
    var noteRottenTomatoes : Int = 0
    var noteTVMaze : Int = 0
    var noteMetaCritic : Int = 0
    var noteAlloCine : Int = 0

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        origineX = 10.0
        origineY = (self.frame.height - 25.0)
        hauteur  = (self.frame.height - 25.0 - bordure)
        largeur  = (self.frame.width - origineX - bordure)
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = true
        
        // Drawing code here.
        self.background()
    }
    
    
    func sendEpisode(nTrakt:Int, nTVdb:Int, nBetaSeries:Int, nMovieDB:Int, nIMDB:Int, nRottenTomatoes:Int, nTVMaze:Int, nMetaCritic:Int, nAlloCine :Int){
        noteTrakt = nTrakt
        noteTVdb = nTVdb
        noteBetaSerie = nBetaSeries
        noteMovieDB = nMovieDB
        noteIMDB = nIMDB
        noteRottenTomatoes = nRottenTomatoes
        noteTVMaze = nTVMaze
        noteMetaCritic = nMetaCritic
        noteAlloCine = nAlloCine
    }

    
    func background() {
        #imageLiteral(resourceName: "trakt.ico").draw(in: CGRect(x: 0.0, y: 0.0, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "thetvdb.png").draw(in: CGRect(x: 0.0, y: linH, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "betaseries.png").draw(in: CGRect(x: 0.0, y: 2*linH, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "themoviedb.ico").draw(in: CGRect(x: colW, y: 0.0, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "imdb.ico").draw(in: CGRect(x: colW, y: linH, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "rottentomatoes.ico").draw(in: CGRect(x: colW, y: 2*linH, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "tvmaze.ico").draw(in: CGRect(x: 2*colW, y: 0.0, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "metacritic.png").draw(in: CGRect(x: 2*colW, y: linH, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "allocine.ico").draw(in: CGRect(x: 2*colW, y: 2*linH, width: 18.0, height: 18.0))

        traceBarre(note: noteTrakt, color: colorTrakt, colonne:0, ligne:0)
        traceBarre(note: noteTVdb, color: colorTVdb, colonne:0, ligne:1)
        traceBarre(note: noteBetaSerie, color: colorBetaSeries, colonne:0, ligne:2)
        traceBarre(note: noteMovieDB, color: colorMoviedb, colonne:1, ligne:0)
        traceBarre(note: noteIMDB, color: colorIMDB, colonne:1, ligne:1)
        traceBarre(note: noteRottenTomatoes, color: colorRottenTomatoes, colonne:1, ligne:2)
        traceBarre(note: noteTVMaze, color: colorTVmaze, colonne:2, ligne:0)
        traceBarre(note: noteMetaCritic, color: colorMetaCritic, colonne:2, ligne:1)
        traceBarre(note: noteAlloCine, color: colorAlloCine, colonne:2, ligne:2)
    }
    
    
    func traceBarre(note: Int, color: UIColor, colonne:Int, ligne:Int) {
        let path : UIBezierPath = UIBezierPath()
        
        let oriX : CGFloat = 25.0
        let oriY : CGFloat = 11.0
        
        let barreW : CGFloat = 80.0
        let barreH : CGFloat = 6.0

        color.setStroke()
        
        path.move(to: CGPoint(x: oriX+(CGFloat(colonne)*colW), y: oriY+(CGFloat(ligne)*linH)) )
        path.addLine(to: CGPoint(x: oriX+(CGFloat(colonne)*colW)+barreW, y: oriY+(CGFloat(ligne)*linH)) )
        path.addLine(to: CGPoint(x: oriX+(CGFloat(colonne)*colW)+barreW, y: oriY+(CGFloat(ligne)*linH)+barreH) )
        path.addLine(to: CGPoint(x: oriX+(CGFloat(colonne)*colW), y: oriY+(CGFloat(ligne)*linH)+barreH) )
        path.addLine(to: CGPoint(x: oriX+(CGFloat(colonne)*colW), y: oriY+(CGFloat(ligne)*linH)) )
        
        path.stroke()
        
        if (note > 100 ) { return }
        if (note <= 0 ) { return }

        let path2 : UIBezierPath = UIBezierPath()

        color.setStroke()
        color.withAlphaComponent(0.5).setFill()

        path2.move(to: CGPoint(x: oriX+(CGFloat(colonne)*colW), y: oriY+(CGFloat(ligne)*linH)) )
        path2.addLine(to: CGPoint(x: oriX+(CGFloat(colonne)*colW)+(barreW*CGFloat(note)/100.0), y: oriY+(CGFloat(ligne)*linH)) )
        path2.addLine(to: CGPoint(x: oriX+(CGFloat(colonne)*colW)+(barreW*CGFloat(note)/100.0), y: oriY+(CGFloat(ligne)*linH)+barreH) )
        path2.addLine(to: CGPoint(x: oriX+(CGFloat(colonne)*colW), y: oriY+(CGFloat(ligne)*linH)+barreH) )
        path2.addLine(to: CGPoint(x: oriX+(CGFloat(colonne)*colW), y: oriY+(CGFloat(ligne)*linH)) )
        
        path2.stroke()
        path2.fill()

        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8), NSAttributedString.Key.foregroundColor: colorAxis]

        let noteString : NSString = String(note) as NSString
        noteString.draw(in: CGRect(x: oriX+(CGFloat(colonne)*colW)+(barreW*CGFloat(note)/100.0)-5.0, y: CGFloat(ligne)*linH-2.0, width: 20, height: 10), withAttributes: textAttributes)
    }
    
//    func backgroundOld() {
//        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: colorAxis]
//
//        // Lignes
//        colorAxis.setStroke()
//
//        // Cadre
//        let path : UIBezierPath = UIBezierPath()
//        path.move(to: CGPoint(x: origineX, y: origineY))
//        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
//        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
//        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
//        path.addLine(to: CGPoint(x:origineX, y:origineY))
//        path.stroke()
//
//        // Lignes achurées verticales
//        for i:Int in 0 ..< 5 {
//            path.move(to: CGPoint(x: origineX + (largeur * CGFloat(i)/4), y: origineY))
//            path.addLine(to: CGPoint(x: origineX  + (largeur * CGFloat(i)/4), y: origineY - hauteur))
//
//            path.setLineDash([5.0,5.0], count: 2, phase: 5.0)
//            path.stroke()
//
//            let episode : NSString = String(i*25) as NSString
//            episode.draw(in: CGRect(x: origineX + (largeur * CGFloat(i)/4) - 7.0, y: origineY + 5.0, width: 20, height: 10), withAttributes: textAttributes)
//        }
//    }
//
//
//    func traceBarres() {
//        traceUneBarre(theEpisode.getFairRatingTVdb(),       color: colorTVdb,       offset: 5, image : #imageLiteral(resourceName: "thetvdb.png"))
//        traceUneBarre(theEpisode.getFairRatingTrakt(),      color: colorTrakt,      offset: 4, image : #imageLiteral(resourceName: "trakt.ico"))
//        traceUneBarre(theEpisode.getFairRatingBetaSeries(), color: colorBetaSeries, offset: 3, image : #imageLiteral(resourceName: "betaseries.png"))
//        traceUneBarre(theEpisode.getFairRatingIMdb(),       color: colorIMDB,       offset: 2, image : #imageLiteral(resourceName: "imdb.ico"))
//        traceUneBarre(theEpisode.getFairRatingMoviedb(),    color: colorMoviedb,    offset: 1, image : #imageLiteral(resourceName: "themoviedb.ico"))
//    }
//
//
//    func traceUneBarre(_ noteX: Int, color: UIColor, offset: Int, image : UIImage) {
//        let nbSource : CGFloat = 5.0
//        let col : CGFloat = hauteur / (4 * nbSource)
//
//        color.setStroke()
//        color.withAlphaComponent(0.5).setFill()
//
//        let path : UIBezierPath = UIBezierPath()
//
//        path.move(to: CGPoint(x: origineX, y: origineY - (CGFloat(offset - 1) * hauteur / nbSource) - col))
//        path.addLine(to: CGPoint(x: origineX + ( largeur * CGFloat(noteX) / 100), y: origineY - (CGFloat(offset - 1) * hauteur / nbSource) - col))
//        path.addLine(to: CGPoint(x: origineX + ( largeur * CGFloat(noteX) / 100), y: origineY - (CGFloat(offset - 1) * hauteur / nbSource) - (3 * col)))
//        path.addLine(to: CGPoint(x: origineX, y: origineY - (CGFloat(offset - 1) * hauteur / nbSource) - (3 * col)))
//        path.addLine(to: CGPoint(x: origineX, y: origineY - (CGFloat(offset - 1) * hauteur / nbSource) - col))
//
//        path.stroke()
//        path.fill()
//
//        image.draw(in: CGRect(x: origineX + ( largeur * CGFloat(noteX) / 100) - 12.0, y:  origineY - (CGFloat(offset - 1) * hauteur / nbSource) - (3 * col) - 4.0, width: 24.0, height: 24.0))
//    }
}


