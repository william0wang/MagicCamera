//
//  ProImageView.swift
//  MagicCamera
//
//  Created by William on 2020/12/22.
//

import SwiftUI

struct ProBadge: View {
    let pro: Bool
    
    var body: some View {
        Group {
            if pro {
                Text("VIP")
                    .bold()
                    .font(.system(size: 15))
                    .frame(width: 40, height: 20)
                    .foregroundColor(.white)
                    .background(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
        }
    }
}

struct ProImageAutoView: View {
    var name: String
    var pro: Bool
    var title: String
    var body: some View {
        VStack {
            loadImage(name:name)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(ProBadge(pro: pro).offset(x: -55, y: -65))
            Text(NSLocalizedString(title, comment: ""))
        }
    }
    
    public init(name: String, title: String = "") {
        self.name = name
        self.title = title
        self.pro = DefaultsKeys.IsFxTry(name: title)
    }
}

struct ProImageView: View {
    var name: String
    var title: String
    var pro: Bool
    var filter: MTFilter?
    var resize: CGSize?
    var body: some View {
        VStack {
            loadImage(name:name, filter: filter, resize: resize)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(ProBadge(pro: pro).offset(x: -55, y: -65))
            Text(NSLocalizedString(title, comment: ""))
        }
    }
    
    public init(name: String, title: String = "", pro : Bool = true, filter:MTFilter? = nil, resize: CGSize? = nil) {
        self.name = name
        self.title = title
        self.pro = pro
        self.filter = filter
        self.resize = resize
    }
}

struct ProImageView_Previews: PreviewProvider {
    static var previews: some View {
        ProImageView(name: "face.jpg", title: "美颜相机")
    }
}
