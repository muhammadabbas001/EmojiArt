import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject, Hashable, Identifiable{
    
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool{
        lhs.id == rhs.id
    }
    
    let id: UUID
    
    func hash(into hasher: inout Hasher) {
           hasher.combine(id)
       }
   
    
    static let pallette: String = "🥶👹🤮😉🦊😷"

    
    @Published private var emojiArt: EmojiArt

    private var autosaveCancellable: AnyCancellable?

    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        let defaultKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultKey)) ?? EmojiArt()
        autosaveCancellable = $emojiArt.sink{emojiArt in
//            print("\(emojiArt.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiArt.json, forKey: defaultKey)
        }
        fetchBackGroundImageData()
    }
    
    
    @Published private(set) var backgroundImage: UIImage?
    
    @Published var steadyStateZoomScale: CGFloat = 1.0
    @Published var steadyStatePanOffset: CGSize = .zero
    
    var emojis: [EmojiArt.Emoji]{emojiArt.emojis}
    
    //MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat){
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize){
        if let index = emojiArt.emojis.firstIndex(matching: emoji){
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat){
        if let index = emojiArt.emojis.firstIndex(matching: emoji){
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    var backgroundURL: URL?{
        get{
            emojiArt.backgroundURL
        }
        set{
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackGroundImageData()
        }
    }
    
    private var fetchImageCancellable: AnyCancellable?
    
    private func fetchBackGroundImageData(){
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL{
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map{data, urlResponse in UIImage(data: data)}
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \.backgroundImage , on: self)
        }
    }
}

extension EmojiArt.Emoji{
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}


//    //@Published // workaround for property observer problem with property wrappers
//    private var emojiArt: EmojiArt = EmojiArt(){
//        willSet{
//            objectWillChange.send()
//        }
//        didSet{
//            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)
//        }
//    }
//
//    private static let untitled = "EmojiArtDocument.Untitled"
//
//    init() {
//        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
//        fetchBackGroundImageData()
//    }
