//
//  AufgabeNächsteAufgabe.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 19.08.2024.
//

import SwiftUI
import SwiftData

struct AufgabeNaechsteAufgabe: View {
    @Bindable var aufgabe: AufgabeModel
    @State private var editAufgabe: Bool = false
    
    @State private var small : Bool = UIDevice.current.userInterfaceIdiom == .phone && Axis.Set.horizontal == .horizontal
    
    
    var body: some View {
        
        HStack{
            TextField("Aufgabe", text: $aufgabe.aufgabe , axis: .vertical)
                .lineLimit(10)
                .frame(width: small ? 200 : 600)
                .padding(7)
                .foregroundColor(.black)
                
                .background(Color("ColorInspiration").opacity(0.5))
                .clipShape(ChatBubbleLeft())
                .padding(.horizontal)
            Spacer()
        }
        HStack{
            Spacer()
            TextField("Antwort", text: $aufgabe.antwort, axis: .vertical)
                .lineLimit(10)
                .padding(7)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                
                .padding(7)
            Button {
                // aufgabe.erledigt.toggle()
                aufgabe.erledigt = true 
            } label: {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color("ColorÜberwindung"))
                        .padding(.horizontal)
                }
        }
        .background(Color.gray.opacity(0.3))
    }
}


#Preview {
    let container = VorhabenModel.preview
    let Vorhabens = try! container.mainContext.fetch(
        FetchDescriptor<VorhabenModel>(predicate: #Predicate { Vorhaben in
            Vorhaben.bezeichnung == "iLifeDesign"
        }))
    
    return AufgabeNaechsteAufgabe(aufgabe: Vorhabens[0].aufgaben![0])
}
