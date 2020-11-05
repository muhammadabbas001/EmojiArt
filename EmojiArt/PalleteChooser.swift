import SwiftUI

struct PalleteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    @State private var showPalleteEditor = false
    
    var body: some View {
        HStack{
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: {EmptyView()})
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    self.showPalleteEditor = true
            }
                .sheet(isPresented: $showPalleteEditor) {
                    PalleteEditor(chosenPalette: self.$chosenPalette, isShowing: self.$showPalleteEditor)
                        .environmentObject(self.document)
                        .frame(minWidth: 300, minHeight: 500)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PalleteEditor: View{
    @EnvironmentObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    @State private var palleteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View{
        VStack{
            ZStack{
                Text("Some Pallete").font(.headline).padding()
                HStack{
                    Spacer()
                    Button(action: {
                        self.isShowing = false
                    }, label: {Text("Done")}).padding()
                }
            }
            Form{
                Section{
                    TextField("Palette Editor", text: $palleteName, onEditingChanged: { began in
                        if !began{
                            self.document.renamePalette(self.chosenPalette, to: self.palleteName)
                        }
                    })
                    TextField("Add Emojis", text: $emojisToAdd, onEditingChanged: { began in
                        if !began{
                            self.chosenPalette = self.document.addEmoji(self.emojisToAdd, toPalette: self.chosenPalette)
                            self.emojisToAdd = ""
                        }
                    })
                }
                Section{
                    Grid(chosenPalette.map {String($0)}, id: \.self){emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                            .onTapGesture {
                                self.chosenPalette = self.document.removeEmoji(emoji , fromPalette: self.chosenPalette)
                        }
                    }
                    .frame(height: self.height)
                }
            }
        }
        .onAppear{
            self.palleteName = self.document.paletteNames[self.chosenPalette] ?? ""
        }
    }
    
    //MARK: - Drawing Constants
    
    var height : CGFloat{
        CGFloat((chosenPalette.count - 1) / 6) * 70 + 70
    }
    let fontSize: CGFloat = 40
}

struct PalleteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PalleteChooser(document: EmojiArtDocument(), chosenPalette: Binding.constant(""))
    }
}
