//
//  GraphEpisode.swift
//  Seriez
//
//  Created by Cyril Delamare on 30/04/2017.
//  Copyright © 2017 Home. All rights reserved.
//
import UIKit

class GraphEpisode: UIView {
    
    let linH : CGFloat = 35.0
    
    var noteTrakt : Int = 0
    var noteBetaSerie : Int = 0
    var noteMovieDB : Int = 0
    var noteIMDB : Int = 0
    var noteTVMaze : Int = 0
    var noteSensCritique : Int = 0

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        self.background()
    }
    
    
    func sendEpisode(ep: Episode){
        noteTrakt = ep.ratingTrakt
        noteBetaSerie = ep.ratingBetaSeries
        noteMovieDB = ep.ratingMoviedb
        noteIMDB = ep.ratingIMdb
        noteTVMaze = ep.ratingTVMaze
        noteSensCritique = ep.ratingSensCritique
    }


    func background() {
        #imageLiteral(resourceName: "trakt.ico").draw(in: CGRect(x: 0.0, y: 2.0, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "betaseries.png").draw(in: CGRect(x: 0.0, y: 2.0+linH, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "themoviedb.ico").draw(in: CGRect(x: 0.0, y: 2.0+2*linH, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "imdb.ico").draw(in: CGRect(x: 0.0, y: 2.0+3*linH, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "tvmaze.ico").draw(in: CGRect(x: 0.0, y: 2.0+4*linH, width: 18.0, height: 18.0))
        #imageLiteral(resourceName: "senscritique.png").draw(in: CGRect(x: 0.0, y: 2.0+5*linH, width: 18.0, height: 18.0))

        traceBarre(note: noteTrakt, color: colorTrakt, colonne:0, ligne:0)
        traceBarre(note: noteBetaSerie, color: colorBetaSeries, colonne:0, ligne:1)
        traceBarre(note: noteMovieDB, color: colorMoviedb, colonne:0, ligne:2)
        traceBarre(note: noteIMDB, color: colorIMDB, colonne:0, ligne:3)
        traceBarre(note: noteTVMaze, color: colorTVmaze, colonne:0, ligne:4)
        traceBarre(note: noteSensCritique, color: colorSensCritique, colonne:0, ligne:5)
    }
    
    
    func traceBarre(note: Int, color: UIColor, colonne:Int, ligne:Int) {
        let path : UIBezierPath = UIBezierPath()
        let oriX : CGFloat = 30.0
        let oriY : CGFloat = 11.0
        let barreW : CGFloat = 220.0
        let barreH : CGFloat = 8.0

        color.setStroke()
        
        path.move(to: CGPoint(x: oriX, y: oriY+(CGFloat(ligne)*linH)) )
        path.addLine(to: CGPoint(x: oriX+barreW, y: oriY+(CGFloat(ligne)*linH)) )
        path.addLine(to: CGPoint(x: oriX+barreW, y: oriY+(CGFloat(ligne)*linH)+barreH) )
        path.addLine(to: CGPoint(x: oriX, y: oriY+(CGFloat(ligne)*linH)+barreH) )
        path.addLine(to: CGPoint(x: oriX, y: oriY+(CGFloat(ligne)*linH)) )
        
        path.stroke()
        
        if (note > 100 ) { return }
        if (note <= 0 ) { return }

        let path2 : UIBezierPath = UIBezierPath()

        color.setStroke()
        color.withAlphaComponent(0.5).setFill()

        path2.move(to: CGPoint(x: oriX, y: oriY+(CGFloat(ligne)*linH)) )
        path2.addLine(to: CGPoint(x: oriX+(barreW*CGFloat(note)/100.0), y: oriY+(CGFloat(ligne)*linH)) )
        path2.addLine(to: CGPoint(x: oriX+(barreW*CGFloat(note)/100.0), y: oriY+(CGFloat(ligne)*linH)+barreH) )
        path2.addLine(to: CGPoint(x: oriX, y: oriY+(CGFloat(ligne)*linH)+barreH) )
        path2.addLine(to: CGPoint(x: oriX, y: oriY+(CGFloat(ligne)*linH)) )
        
        path2.stroke()
        path2.fill()

        let textAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 9), NSAttributedString.Key.foregroundColor: color]

        let noteString : NSString = String(note) as NSString
        noteString.draw(in: CGRect(x: oriX+(barreW*CGFloat(note)/100.0)-5.0, y: CGFloat(ligne)*linH-2.0, width: 20, height: 10), withAttributes: textAttributes)
    }
    
}


