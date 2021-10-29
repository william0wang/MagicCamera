//
//  ProSelectView.swift
//  MagicCamera
//
//  Created by William on 2020/12/22.
//

import SwiftUI

struct ProSelectView: View {
    var name: String
    var title: String
    var pro: Bool
    var filter: MTFilter?
    var resize: CGSize?
    @Binding var selectedName : String
    var body: some View {
        VStack {
            if selectedName == title {
                loadImage(name:name, filter: filter, resize: resize)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow, lineWidth: 4))
                    .overlay(ProBadge(pro: pro).offset(x: -20, y: -28))
                    .padding(.top, 10)
            } else {
                loadImage(name:name, filter: filter, resize: resize)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(ProBadge(pro: pro).offset(x: -20, y: -28))
                    .padding(.top, 10)
            }
            Text(NSLocalizedString(title, comment: ""))
        }
    }
    
    public init(name: String, title: String = "", selected: Binding<String> = .constant(""), pro: Bool = true, filter:MTFilter? = nil, resize: CGSize? = nil) {
        self._selectedName = selected
        self.name = name
        self.title = title
        self.pro = pro
        self.filter = filter
        self.resize = resize
    }
}

struct ProSelectAutoView: View {
    var name: String
    var title: String
    var pro: Bool
    @Binding var selectedName : String
    var body: some View {
        VStack {
            if selectedName == title {
                loadImage(name:name)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow, lineWidth: 4))
                    .overlay(ProBadge(pro: pro).offset(x: -20, y: -28))
                    .padding(.top, 10)
            } else {
                loadImage(name:name)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(ProBadge(pro: pro).offset(x: -20, y: -28))
                    .padding(.top, 10)
            }
            Text(NSLocalizedString(title, comment: ""))
        }
    }
    
    public init(name: String, title: String = "", selected: Binding<String> = .constant("")) {
        self._selectedName = selected
        self.name = name
        self.title = title
        self.pro = DefaultsKeys.IsFxTry(name: title)
    }
}

struct ProSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ProSelectView(name: "face.jpg", title: "美颜相机", selected: .constant("美颜相机"))
    }
}
