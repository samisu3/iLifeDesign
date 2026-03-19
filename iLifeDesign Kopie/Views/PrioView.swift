//
//  Untitled.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 30.09.2024.
//

import SwiftUI

struct PrioView: View {
    let prio: Int
    let size: CGFloat
    
    var body: some View {
        HStack{
            ForEach(1..<6){ i in
                Image(systemName: i <= prio ? "star.fill" : "star")
                    .foregroundColor(i <= prio ? Color.yellow :  Color.gray.opacity(0.4))
                    .frame(width: i <= prio ? size + 1 : size, height: i <= prio ? size + 1 : size)
                    .padding(.horizontal, 1)
            }
        }
    }
}


#Preview {
    
    PrioView(prio: 2, size: 10)
    
}
