//
//  ImageSaveView.swift
//  MagicCamera
//
//  Created by William on 2021/5/24.
//

import SwiftUI

struct ImageSaveView: View {
    @Binding var savePopupOk: Bool
    @Binding var saveError : Error?
    
    var body: some View {
        VStack {
            if savePopupOk {
                Text("保存图片成功!").foregroundColor(.white).padding(.bottom, 10)
                Text("已经保存图片到相册").foregroundColor(.white)
            } else {
                Text("保存图片失败!").foregroundColor(.white).padding(.bottom, 10)
                Text(saveError?.localizedDescription ?? "").foregroundColor(.white)
            }
        }
        .frame(width: 240, height: 90)
        .background(Color(.gray))
        .cornerRadius(15.0)
    }
}

struct ImageSaveView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSaveView(savePopupOk: .constant(true), saveError: .constant(nil))
    }
}
