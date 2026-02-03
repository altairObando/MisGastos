//
//  CategoriesView.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/2/26.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @State private var showError: Bool = false
    @State private var selected: Category?
    @State private var moveToUpdate: Bool = false
    @State private var searchText: String = String();
    var body: some View {
        VStack {
            List{
                ForEach(categories.sorted{ item1, item2 in
                    item1.isIncome && !item2.isIncome
                }){ cat in
                    CategoryItem(cat: cat, onEdit: onEdit, onDelete: onDelete)
                }
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .foregroundStyle(.white)
        }
        .onAppear{
            selected = nil;
            moveToUpdate = false;
        }
        .sheet(isPresented: $showError){
            VStack(alignment: .leading, spacing: 10){
                Text("Error")
                    .font(.subheadline.bold())
                Text("Error al eliminar la categoria seleccionada")
                    .font(.subheadline)
            }.padding()
                .presentationBackground(.bgColorLigth)
                .foregroundStyle(.white)
            .presentationDetents([.height(100)])
        }
        .globalBackground()
        .navigationTitle("Categorias")
        .toolbar{
            ToolbarItem(placement: .topBarTrailing){
                Button("New", systemImage:"plus"){
                    selected = nil
                    moveToUpdate = true
                }
            }
        }
        .navigationDestination(isPresented: $moveToUpdate){
            AddOrUpdateCategory(cat: selected)
        }
        .searchable(
            text: $searchText,
            placement: .toolbarPrincipal,
            prompt:"Buscar categoria"
        )
    }
    func onEdit( _ category : Category){
        selected = category;
        moveToUpdate = true;
    }
    func onDelete(_ category: Category){
        withAnimation {
            modelContext.delete(category)
            do{
                try modelContext.save()
            }catch{
                showError = true;
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    showError = false;
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        Text("Loading")
            .navigationDestination(isPresented: .constant(true)){
                CategoriesView()
            }
    }.modelContainer(for: [Expense.self, Category.self], inMemory: true){ result in
        switch result {
            case .success( let container): setupDefaultData(container: container)
            case .failure(let error): print(error.localizedDescription)
        }
    }
}
