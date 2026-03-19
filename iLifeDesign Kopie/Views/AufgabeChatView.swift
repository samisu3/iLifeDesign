//
//  AufgabeChatView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 04.08.2024.
//

import SwiftUI
import SwiftData

struct ChatBubbleLeft: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Blasenform
        path.move(to: CGPoint(x: rect.minX + 20, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - 20, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 20), control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 20))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - 20, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + 20, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - 20), control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 20))
        path.addQuadCurve(to: CGPoint(x: rect.minX + 20, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        
        // Ecke hinzufügen
       
        path.move(to: CGPoint(x: rect.minX  ,  y: rect.maxY - 10 ))
        path.addLine(to: CGPoint(x: rect.minX - 5 , y: rect.maxY ))
        path.addLine(to: CGPoint(x: rect.minX + 20 , y: rect.maxY + 10))
        return path
    }
}


struct ChatBubbleRight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Blasenform
        path.move(to: CGPoint(x: rect.minX + 20, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - 20, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 20), control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 20))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - 20, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + 20, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - 20), control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 20))
        path.addQuadCurve(to: CGPoint(x: rect.minX + 20, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        
        // Ecke hinzufügen
       
        path.move(to: CGPoint(x: rect.maxX  ,  y: rect.maxY - 10 ))
        path.addLine(to: CGPoint(x: rect.maxX - 10 , y: rect.maxY ))
        path.addLine(to: CGPoint(x: rect.maxX + 20 , y: rect.maxY + 10))
        return path
    }
}

struct AufgabeChatView: View {
    @Bindable var aufgabe: AufgabeModel
    @State private var editAufgabe: Bool = false
    
    var body: some View {
        Grid{
            GridRow{
           
                TextField("Aufgabe", text: $aufgabe.aufgabe , axis: .vertical)
                    .foregroundColor(.black)
                    .padding(7)
                    .background(Color("ColorInspiration").opacity(0.5))
                    .clipShape(ChatBubbleLeft())
                    .gridCellColumns(2)
                    
                Color.white
                    .gridCellUnsizedAxes(.vertical)
                    .gridCellColumns(1)
            }
            .padding(.horizontal)
            GridRow{
                Color.white
                    .gridCellColumns(1)
                    .gridCellUnsizedAxes(.vertical)
                TextField("Antwort", text: $aufgabe.antwort, axis: .vertical)
                    .foregroundColor(.white)
                    .padding(7)
                    .background(Color("ColorFeedback").opacity(0.7))
                    .clipShape(ChatBubbleRight())
                    .gridCellColumns(2)
                    
            }
            .padding(.horizontal)
        }
        
        
    }
}



#Preview {
    let container = VorhabenModel.preview
    let Vorhabens = try! container.mainContext.fetch(
        FetchDescriptor<VorhabenModel>(predicate: #Predicate { Vorhaben in
            Vorhaben.bezeichnung == "iLifeDesign"
        }))
    
    return AufgabeChatView(aufgabe: Vorhabens[0].aufgaben![0])
}

