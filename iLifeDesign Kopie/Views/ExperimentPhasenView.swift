//
//  VorhabenGridView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 09.08.2024.
//

import SwiftUI
import SwiftData

struct VorhabenPhasenView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var refresh = false
    @State private var newVorhaben = VorhabenModel()
    @State private var isNewVorhaben = false
    
    var body: some View {
        NavigationStack {
            let fiveColumns = [GridItem(),
                               GridItem(),
                               GridItem(),
                               GridItem(),
                               GridItem()]
            
            LazyVGrid(columns: fiveColumns, spacing: 50) {
                subPhaseView(phase: 0 )
                subPhaseView(phase: 1)
                Text("")
                subPhaseView(phase: 5)
                Text("")
                subPhaseView(phase: 2)
                Text("")
                VStack{
                    subPhaseView(phase: 4)
                    subPhaseView(phase: 8)
                }
                Text("")
                subPhaseView(phase: 6)
                Text("")
                subPhaseView(phase: 3)
                Text("")
                subPhaseView(phase: 7)
                subPhaseView(phase: 9)
            }
            .navigationTitle("Phasen")
            .toolbar{
                Button("", systemImage: "arrow.clockwise") {
                    refresh.toggle()
                }
                Button("", systemImage: "plus") {
                    newVorhaben = VorhabenModel()
                    modelContext.insert(newVorhaben)
                    addStandardAufgaben(Vorhaben: newVorhaben)
                    isNewVorhaben = true
                    refresh.toggle()
                }
            }
            .background(
                Image("Loop0").resizable().scaledToFill()
            )
            .id(refresh)
            
        }
        .sheet(isPresented: $isNewVorhaben){
            ModernVorhabenEditor(Vorhaben: newVorhaben, isNew: true)
        }
        .onAppear(){
            refresh.toggle()
        }
        
        
    }
}



struct subPhaseView : View{
    @Environment(\.modelContext) private var modelContext
    
    let phase: Int
    
    private let phone : Bool = UIDevice.current.userInterfaceIdiom == .phone
    private let hoch : Bool =  UIDevice.current.orientation == .portrait
    private let sortDescriptors = [ SortDescriptor(\VorhabenModel.priority, order: .reverse) ]
    private var Vorhabens: [VorhabenModel] {
        let predicate = #Predicate<VorhabenModel> { Vorhaben in
            Vorhaben.phase == phase}
        let fetch = FetchDescriptor(predicate: predicate, sortBy: sortDescriptors)
        return try! modelContext.fetch(fetch)
    }
    
    var body: some View {
        VStack{
            ForEach(Vorhabens){ Vorhaben in
                
                NavigationLink(destination: ModernVorhabenEditor(Vorhaben: Vorhaben) ) {
                    Label(phone && hoch ? "" : Vorhaben.bezeichnung,  systemImage: Vorhaben.viewIcon)
                        .fontWeight(Vorhaben.priority > 2 ? .bold : .regular)
                        .foregroundColor(Vorhaben.viewColor)
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.white).shadow(radius:5, x:5, y:5))
                    
                }
            }
        }
        .frame(height: phone ? 20: 100)
        
    }
    
}



#Preview {
    
    VorhabenPhasenView()
        .modelContainer(VorhabenModel.preview)
}
