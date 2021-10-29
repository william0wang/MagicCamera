//
//  VideoView.swift
//  MagicCamera
//
//  Created by William on 2021/3/24.
//

import SwiftUI

struct VideoView: View {
    var body: some View {
        let fileUrl = Bundle.main.url(forResource: "face", withExtension: "mp4")
        VideoPlayerContainerView(url: fileUrl!)
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView().frame(width:100, height:100)
    }
}
