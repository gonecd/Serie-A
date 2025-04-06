//
//  WidegtView.swift
//  Mon activitéExtension
//
//  Created by Cyril DELAMARE on 09/10/2021.
//  Copyright © 2021 Home. All rights reserved.
//

import Foundation
import SwiftUI


struct MonActiviteView : View {
    let entry: MonActiviteData
    var lien1 : String = "UneSerie://NonRien"
    var lien2 : String = "UneSerie://NonRien"
    var lien3 : String = "UneSerie://NonRien"
    
    init(entry: MonActiviteData) {
        self.entry = entry
        
        if (entry.data1.serie != noSerie.serie) { lien1 = "UneSerie://ASuivre1" }
        if (entry.data2.serie != noSerie.serie) { lien2 = "UneSerie://ASuivre2" }
        if (entry.data3.serie != noSerie.serie) { lien3 = "UneSerie://ASuivre3" }
    }
    
    
    func MyBloc(lien : String, poster: UIImage, data : Data4MonActivite) -> AnyView {
        if (data.serie == "N/A") { return AnyView(EmptyView()) }
        
        return AnyView( Link(destination: URL(string: lien)!) {
            HStack(alignment: .center) {
                Image(uiImage: poster).resizable().frame(width: 60, height: 80, alignment: .center)
                Text("  ")
                VStack(alignment: .leading) {
                    Text(data.serie).font(.system(size: 20, weight: .heavy)).lineLimit(1).foregroundColor(.black)
                    Text("Saison " + String(data.saison)).font(.footnote).foregroundColor(.black)
                    
                    HStack(alignment: .top) {
                        ZStack() {
                            Circle().fill(Color.blue).frame(width: 15, height: 15)
                            PieSegment(start: .degrees(360.0*Double(data.nbWatched)/Double(data.nbEps)-90.0), end: .degrees(-90)).fill(Color.white).frame(width: 13, height: 13)
                        }
                        Text(String(data.nbWatched) + " éps vus sur " + String(data.nbEps)).font(.footnote).foregroundColor(.blue)
                    }
                }
                Spacer()
                Image(uiImage: getLogoDiffuseur(diffuseur: data.channel)).resizable().frame(width: 40, height: 40, alignment: .center)
            }
        })
    }
    
    
    var body: some View {
        HStack {
            Text("Une Série ?").font(.system(size: 20, weight: .heavy))
            Spacer(minLength: 1)
            Text("Saisons en cours").font(.system(size: 14))
            Image(uiImage: #imageLiteral(resourceName: "120.png")).resizable().frame(width: 30, height: 30, alignment: .trailing)
        }
        
        Spacer()
        MyBloc(lien: lien1, poster: entry.poster1, data: entry.data1)
        Spacer()
        MyBloc(lien: lien2, poster: entry.poster2, data: entry.data2)
        Spacer()
        MyBloc(lien: lien3, poster: entry.poster3, data: entry.data3)
    }
    
}


struct PieSegment: Shape {
    var start: Angle
    var end: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.midX, startAngle: start, endAngle: end, clockwise: false)
        return path
    }
}

func getLogoDiffuseur(diffuseur: String) -> UIImage {
    switch (diffuseur) {
    case "Netflix": return #imageLiteral(resourceName: "netflix.jpg")
    case "Canal+": return #imageLiteral(resourceName: "canal plus.jpg")
    case "Apple TV+": return #imageLiteral(resourceName: "apple tv.jpg")
    case "Disney+": return #imageLiteral(resourceName: "disney.jpg")
    case "Amazon": return #imageLiteral(resourceName: "prime video.jpg")
    case "Prime Video": return #imageLiteral(resourceName: "prime video.jpg")
    case "Max": return #imageLiteral(resourceName: "max.jpg")
    case "Paramount+": return #imageLiteral(resourceName: "paramount.jpg")
    case "OCS": return #imageLiteral(resourceName: "ocs.jpg")
    case "M6+": return #imageLiteral(resourceName: "M6.jpg")
    case "TF1+": return #imageLiteral(resourceName: "tf1.jpg")
    case "Arte": return #imageLiteral(resourceName: "arte.jpg")
    case "france.tv": return #imageLiteral(resourceName: "francetv.jpg")
    case "": return UIImage()

    default:
        print("Logo diffuseur inconnu = \(diffuseur)")
        return UIImage()
    }
    
}

