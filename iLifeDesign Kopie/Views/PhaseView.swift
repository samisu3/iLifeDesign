//
//  Untitled.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 30.09.2024.
//

import SwiftUI

struct PhaseView: View {
    let phase: Int
    
    var body: some View {
        
        HStack{
            Spacer()
            ForEach(1..<9){ i in
                Image(systemName: VorhabenPhaseIcon[i]!)
                    .foregroundColor(i == phase ? Color.white :  PhaseColor[i]!)
                    .background(
                        Circle()
                            .fill(i == phase ? PhaseColor[i]! : Color.white)
                          .frame(width: 25, height: 25)
                    )
                    .frame(width: 24, height: 24)
                Spacer()
            }
        }
        .background(RoundedRectangle(cornerRadius: 7).foregroundColor(Color.gray).frame(height: 1))
        .font(.caption)
    }
    
}


#Preview {
    PhaseView(phase: 2)
}
