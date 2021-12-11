//
//  GraphEpisode.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit

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
    
    
    func sendEpisode(ep: Episode){
        noteTrakt = ep.ratingTrakt
        noteTVdb = ep.ratingTVdb
        noteBetaSerie = ep.ratingBetaSeries
        noteMovieDB = ep.ratingMoviedb
        noteIMDB = ep.ratingIMdb
        noteRottenTomatoes = ep.ratingRottenTomatoes
        noteTVMaze = ep.ratingTVMaze
        noteMetaCritic = ep.ratingMetaCritic
        noteAlloCine = 0
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
    
}


