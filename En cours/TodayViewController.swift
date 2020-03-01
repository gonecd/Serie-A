//
//  TodayViewController.swift
//  En cours
//
//  Created by Cyril DELAMARE on 10/02/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import NotificationCenter
import SeriesCommon

class TodayViewController: UIViewController, NCWidgetProviding {

    var sharedInfos :[InfosEnCours] = []
    let hauteurParSaison : Int = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == .expanded) {
            preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(10+(hauteurParSaison*sharedInfos.count)))
            fullView(size: CGSize(width: maxSize.width, height: CGFloat(10+(hauteurParSaison*sharedInfos.count))))
        }
        else {
            preferredContentSize = maxSize
            lightView(size: maxSize)
        }
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        
        loadInfos()
        lightView(size: (extensionContext?.widgetMaximumSize(for: .compact))!)

        completionHandler(NCUpdateResult.newData)
    }
    

    func loadInfos() {
        if let data = UserDefaults(suiteName: "group.Series")!.value(forKey:"Series") as? Data {
            sharedInfos = try! PropertyListDecoder().decode(Array<InfosEnCours>.self, from: data)
        }
    }
    

    func fullView(size : CGSize) {
        cleanView()

        for i in 0..<sharedInfos.count {
            let labelSerie = UILabel(frame: CGRect(x: 75, y: 5+(hauteurParSaison*i), width: Int(size.width - 90) , height: 25))
            labelSerie.font = .systemFont(ofSize: 24.0, weight : .heavy)
            labelSerie.textAlignment = .left
            labelSerie.text = sharedInfos[i].serie
            self.view.addSubview(labelSerie)
            
            let labelSaison = UILabel(frame: CGRect(x: Int(size.width - 120), y: 38+(hauteurParSaison*i), width: 40, height: 40))
            labelSaison.font = .systemFont(ofSize: 18.0, weight : .bold)
            labelSaison.backgroundColor = .white
            labelSaison.textColor = .systemBlue
            labelSaison.textAlignment = .center
            labelSaison.text = "S" + String(sharedInfos[i].saison)
            labelSaison.layer.borderColor = UIColor.systemBlue.cgColor
            labelSaison.layer.borderWidth = 2
            labelSaison.layer.cornerRadius = 20
            labelSaison.layer.masksToBounds = true
            self.view.addSubview(labelSaison)
            
            let labelChannel = UILabel(frame: CGRect(x: 90, y: 40+(hauteurParSaison*i), width: 120, height: 15))
            labelChannel.textColor = .systemGray
            labelChannel.font = UIFont.preferredFont(forTextStyle: .footnote)
            labelChannel.textAlignment = .center
            labelChannel.text = sharedInfos[i].channel
            labelChannel.layer.borderColor = UIColor.systemGray.cgColor
            labelChannel.layer.borderWidth = 1
            labelChannel.layer.cornerRadius = 7
            labelChannel.layer.masksToBounds = true
            self.view.addSubview(labelChannel)
            
            let labelAvance = UILabel(frame: CGRect(x: 120, y: 60+(hauteurParSaison*i), width: 200, height: 21))
            labelAvance.font = UIFont.preferredFont(forTextStyle: .footnote)
            labelAvance.textColor = .systemGray
            labelAvance.textAlignment = .left
            labelAvance.text = String(sharedInfos[i].nbWatched) + " eps sur " + String(sharedInfos[i].nbEps)
            self.view.addSubview(labelAvance)
            
            let poster :UIImageView = UIImageView(frame: CGRect(x: 10, y: 10+(hauteurParSaison*i), width: 50, height: 70));
            poster.image = getImage(sharedInfos[i].poster)
            self.view.addSubview(poster)
            
            let grapheVus : GraphViewed = GraphViewed(frame: CGRect(x: 90, y: 60+(hauteurParSaison*i), width: 20, height: 20))
            grapheVus.sendFigures(eps: sharedInfos[i].nbEps, watched: sharedInfos[i].nbWatched, color : UIColor.systemGray)
            grapheVus.setNeedsDisplay()
            self.view.addSubview(grapheVus)
            
            let grapheNotes : GraphRates = GraphRates(frame: CGRect(x: Int(size.width - 60), y: 38+(hauteurParSaison*i), width: 40, height: 40))
            grapheNotes.sendFigures(rateTrakt: sharedInfos[i].rateTrakt, rateBetaSeries: sharedInfos[i].rateBetaSeries, rateMoviedb: sharedInfos[i].rateMovieDB, rateIMdb: sharedInfos[i].rateIMDB, rateTVmaze: sharedInfos[i].rateTVmaze, rateRottenTomatoes: sharedInfos[i].rateRottenTomatoes)
            grapheNotes.setNeedsDisplay()
            self.view.addSubview(grapheNotes)

        }
    }
    
    
    func lightView(size : CGSize) {
        cleanView()
        
        let largeur : Int = Int(88*(size.height-20.0)/126)
        
        for i in 0..<sharedInfos.count {
            let poster :UIImageView = UIImageView(frame: CGRect(x: 10+((largeur+40)*i), y: 10, width: largeur, height: Int(size.height-20.0)));
            poster.image = getImage(sharedInfos[i].poster)
            self.view.addSubview(poster)
            
            let rateSerie = UILabel(frame: CGRect(x: largeur+((largeur+40)*i)-10, y: 5, width: 40, height: 20))
            rateSerie.textColor = .systemBlue
            rateSerie.backgroundColor = .white
            rateSerie.font = .systemFont(ofSize: 12.0, weight : .heavy)
            rateSerie.textAlignment = .center
            rateSerie.text = String(sharedInfos[i].rateGlobal) + " %"
            rateSerie.layer.cornerRadius = 12
            rateSerie.layer.masksToBounds = true
            self.view.addSubview(rateSerie)
            
            let grapheVus : GraphViewed = GraphViewed(frame: CGRect(x: largeur+((largeur+40)*i)-5, y: 32, width: 30, height: 30))
            grapheVus.sendFigures(eps: sharedInfos[i].nbEps, watched: sharedInfos[i].nbWatched, color : .systemBlue)
            grapheVus.setNeedsDisplay()
            self.view.addSubview(grapheVus)
            

        }
    }

    
    func cleanView() {
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    
    func getImage(_ url: String) -> UIImage {
        if (url == "") { return UIImage() }

        let imageData = NSData(contentsOf: URL(string: url)!)
        return UIImage(data: imageData! as Data)!
    }
    
}

class GraphViewed: UIView {
    var nbEps : Int = 1
    var nbWatched : Int = 0
    var couleur : UIColor = UIColor.white
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.isOpaque = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        // Couleur des lignes
        couleur.setStroke()
        if (couleur == .systemBlue) { UIColor.white.setFill() }
        
        let centreX : CGFloat = self.frame.height / 2
        let centreY : CGFloat = self.frame.width / 2
        let rayon : CGFloat = min(centreX, centreY) - 2.0

        // Cercle extérieur
        let cercle : UIBezierPath = UIBezierPath()
        cercle.lineWidth = 1.5
        cercle.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                    radius: rayon,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        cercle.stroke()
        if (couleur == .systemBlue) {
            UIColor.white.setFill()
            cercle.fill()
        }
        
        couleur.setFill()
        // Pie intérieure
        let pie : UIBezierPath = UIBezierPath()
        pie.lineWidth = 0.1
        pie.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                   radius: rayon,
                   startAngle: -1 * .pi / 2,
                   endAngle: (-1 * .pi / 2) + 2 * .pi * CGFloat(Double(nbWatched)/Double(nbEps)),
                   clockwise: true)
        pie.addLine(to: CGPoint(x: centreX, y: centreY))
        pie.addLine(to: CGPoint(x: centreX, y:centreY - rayon))
        pie.fill()
    }
    
    func sendFigures(eps: Int, watched: Int, color: UIColor){
        self.nbEps = eps
        self.nbWatched = watched
        self.couleur = color
    }
}
    
    
class GraphRates: UIView {
    
    let colorTrakt          : UIColor = .systemRed
    let colorBetaSeries     : UIColor = .systemBlue
    let colorIMDB           : UIColor = .systemOrange
    let colorMoviedb        : UIColor = .systemGreen
    let colorTVmaze         : UIColor = .systemTeal
    let colorRottenTomatoes : UIColor = .systemPurple
    
    let colorAxis       : UIColor = .systemGray

    var noteTrakt : Int = 0
    var noteBetaSeries : Int = 0
    var noteIMDB : Int = 0
    var noteRottenTomatoes : Int = 0
    var noteTVmaze : Int = 0
    var noteMoviedb : Int = 0
    
    var origineX : CGFloat = 0.0
    var origineY : CGFloat = 0.0
    var hauteur : CGFloat = 0.0
    var largeur : CGFloat = 0.0
    let bordure : CGFloat = 5.0
    
    var centreX : CGFloat = 0.0
    var centreY : CGFloat = 0.0
    var rayon   : CGFloat = 0.0
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.isOpaque = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        origineX = bordure
        origineY = (self.frame.height - bordure)
        hauteur  = (self.frame.height - bordure - bordure)
        largeur  = (self.frame.width - origineX - bordure)
        
        centreX = self.frame.height / 2
        centreY = self.frame.width / 2
        rayon = min(centreX, centreY) - 1.0
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        // Drawing code here.
        self.backgroundCercles()
        self.traceGrapheCercle()
        self.traceRayons()

    }
    
        
    func sendFigures(rateTrakt : Int, rateBetaSeries : Int, rateMoviedb : Int, rateIMdb : Int, rateTVmaze : Int, rateRottenTomatoes : Int)
    {
        noteTrakt = rateTrakt
        noteBetaSeries = rateBetaSeries
        noteIMDB = rateIMdb
        noteRottenTomatoes = rateRottenTomatoes
        noteTVmaze = rateTVmaze
        noteMoviedb = rateMoviedb
    }
    
    func backgroundCercles()
    {
        // Couleur des lignes
        colorAxis.setStroke()
        UIColor.white.setFill()

        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                    radius: rayon,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        path.stroke()
        path.fill()
    }

    
    func traceRayons()
    {
        let nbSource : CGFloat = 7.0
        
        // Couleur des lignes
        colorAxis.setStroke()
        
        // Couleur des lignes
        colorAxis.setStroke()
        UIColor.white.setFill()
        
        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                    radius: rayon,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        path.stroke()

        path.lineWidth = 0.3
        for i in 1...7 {
            path.move(to: CGPoint(x: centreX + rayon*cos(2 * .pi * CGFloat(i) / nbSource), y:centreY + rayon*sin(2 * .pi * CGFloat(i) / nbSource)))
            path.addLine(to: CGPoint(x: centreX, y: centreY))
            path.stroke()
        }
    }
    
    
    func traceGrapheCercle() {
        traceUnCercle(noteRottenTomatoes, color: colorRottenTomatoes, offset: 1)
        traceUnCercle(noteTrakt,          color: colorTrakt,          offset: 2)
        traceUnCercle(noteBetaSeries,     color: colorBetaSeries,     offset: 3)
        traceUnCercle(noteIMDB,           color: colorIMDB,           offset: 4)
        traceUnCercle(noteMoviedb,        color: colorMoviedb,        offset: 5)
        traceUnCercle(noteTVmaze,         color: colorTVmaze,         offset: 6)
    }
    
    
    func traceUnCercle(_ noteX: Int, color: UIColor, offset: Int) {
        let nbSource : CGFloat = 7.0
        let taille : CGFloat = rayon * CGFloat(noteX) / 100
        
        color.setStroke()
        color.withAlphaComponent(0.5).setFill()
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: centreX, y: centreY),
                    radius: taille,
                    startAngle: 2 * .pi * CGFloat(offset) / nbSource,
                    endAngle: 2 * .pi * CGFloat(offset - 1) / nbSource,
                    clockwise: false)
        path.stroke()
        
        path.move(to: CGPoint(x: centreX + taille*cos(2 * .pi * CGFloat(offset) / nbSource), y:centreY + taille*sin(2 * .pi * CGFloat(offset) / nbSource)))
        path.addLine(to: CGPoint(x: centreX, y: centreY))
        path.addLine(to: CGPoint(x: centreX + taille*cos(2 * .pi * CGFloat(offset - 1) / nbSource), y:centreY + taille*sin(2 * .pi * CGFloat(offset - 1) / nbSource)))
        path.stroke()
        
        path.fill()
    }
    
    
}



