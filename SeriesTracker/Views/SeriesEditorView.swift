import SwiftUI
import SwiftData

struct SeriesEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var series: Series
    @State private var showingNewAuthorSheet = false
    @State private var newAuthorName = ""
    
    @Query(sort: \Author.name) private var authors: [Author]
    
    private var editorTitle: String
    private var buttonName: String
    private var isNewSeries: Bool
   
    // Single initializer that handles both new and existing series
    init(series: Series? = nil) {
        if let existingSeries = series {
            _series = State(initialValue: existingSeries)
            editorTitle = "Edit Series"
            buttonName = "Update Series"
            isNewSeries = false
        } else {
            // Create a new series with a default author when none is provided
            let defaultAuthor = Author(name: "")
            let newSeries = Series(name: "", author: defaultAuthor)
            _series = State(initialValue: newSeries)
            editorTitle = "Add Series"
            buttonName = "Add Series"
            isNewSeries = true
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Series Details")) {
                    TextField("Series Name", text: $series.name)
                    
                    // Author picker with add new option
                    authorSelectionView
                }
                
                Section {
                    Button(buttonName) {
                        saveOrUpdateSeries()
                    }
                    .disabled(series.name.isEmpty)
                }
            }
            .navigationTitle(editorTitle)
            .navigationBarItems(trailing:
                                    Button("Cancel") {
                dismiss()
            })
            .sheet(isPresented: $showingNewAuthorSheet) {
                NavigationView {
                    Form {
                        Section {
                            TextField("Author Name", text: $newAuthorName)
                        }
                    }
                    .navigationTitle("New Author")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingNewAuthorSheet = false
                        },
                        trailing: Button("Add") {
                            addNewAuthor()
                        }
                            .disabled(newAuthorName.isEmpty)
                    )
                }
            }
        }
    }
    
    private var authorSelectionView: some View {
        Menu {
            // Existing authors
            ForEach(authors) { author in
                Button(action: {
                    series.author = author
                }) {
                    HStack {
                        Text(author.name)
                        if author.id == series.author.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            Divider()
            
            // Add new author option
            Button(action: {
                showingNewAuthorSheet = true
            }) {
                Label("Add New Author", systemImage: "plus.circle")
            }
        } label: {
            HStack {
                Text("Author")
                Spacer()
                Text(series.author.name.isEmpty ? "Select Author" : series.author.name)
                    .foregroundColor(series.author.name.isEmpty ? .gray : .primary)
            }
        }
    }
    
    private func addNewAuthor() {
        let newAuthor = Author(name: newAuthorName)
        modelContext.insert(newAuthor)
        series.author = newAuthor
        
        // Reset and dismiss
        newAuthorName = ""
        showingNewAuthorSheet = false
    }
    
    private func saveOrUpdateSeries() {
        // Validate series name
        guard !series.name.isEmpty else { return }
        
        do {
            if series.id == UUID() {
                if isNewSeries {
                    modelContext.insert(series)
                }
                // This is a new series
                //modelContext.insert(series)
            }
            // Existing series will be updated automatically by SwiftData
            
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving series: \(error)")
        }
    }
}


#Preview("No Authors") {
    let preview = Preview([Author.self])
    SeriesEditorView()
        .modelContainer(preview.container)
}

#Preview("Add Series") {
    let authorDB = Author.authorDatabase(author: Author(name: "Unknown"))
    SeriesEditorView()
        .modelContainer(authorDB)
}

#Preview("Edit Series") {
    let series = Series.randomSeries()
    let authorDB = Author.authorDatabase(author: series.author)
    SeriesEditorView(series: series)
        .modelContainer(authorDB)
}
