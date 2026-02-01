//
//  BudgetItem.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/1/26.
//
import SwiftUI

struct BudgetItem: View {
    @State private var showOptions : Bool = false;
    var bud: Budget
    var fColor: Color
    var thresholds: [(threshold: Double, color: Color, label: String)];
    var callBack: ((_ budget: Budget, _ action: BudgetAction)-> Void)?
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.2))
                .shadow( color: .bgColorLigth.opacity(0.2),radius: 5,x: 0,y: 3)
            VStack(alignment: .leading, spacing: 10 ){
                HStack {
                    Image(systemName: bud.category.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .padding(12)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(fColor)
                    VStack(alignment: .leading){
                        Text(bud.category.name)
                            .font(.title3.bold())
                        HStack{
                            Text("Quedan")
                            Text(bud.available, format: .currency(code: "NIO"))
                        }.font(.footnote)
                    }
                    Spacer()
                    VStack(alignment: .trailing){
                        Text(bud.category.totalSpent,format: .currency(code: "NIO")).font(.title3.bold())
                        Text(bud.amount,format: .currency(code: "NIO")).font(.footnote)
                    }
                }
                CustomProgressBar(
                    progress: bud.consumedPercentage,
                    height: 10,
                    cornerRadius: 10,
                    showPercentage: true,
                    showThresholds: false,
                    thresholds: thresholds
                )
            }
            .foregroundStyle(.white)
            .padding()
            .confirmationDialog("Seleccione una opción", isPresented: $showOptions){
                Button("Editar", role: .confirm){
                    callBack?(bud, .detail)
                }
                Button("Archivar", role: .confirm){
                    callBack?(bud, .archive)
                }
                Button("Eliminar", role: .destructive){
                    callBack?(bud, .delete)
                }
                Button("Cancelar", role: .cancel){
                    callBack?(bud, .cancel)
                }
            }
            .onTapGesture {
                withAnimation{
                    showOptions.toggle()
                }
            }
        }
    }
}
enum BudgetAction: Hashable {
    case archive
    case detail
    case delete
    case cancel
}
