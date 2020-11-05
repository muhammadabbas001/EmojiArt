//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Muhammad Abbas on 11/2/20.
//  Copyright © 2020 iParagons. All rights reserved.
//

import SwiftUI


struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View{
        Group{
            if uiImage != nil{
                Image(uiImage: uiImage!)
            }
        }
    }
}
