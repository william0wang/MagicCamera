//
//  HeaderView.swift
//  MagicCamera
//
//  Created by William on 2021/3/26.
//

import SwiftUI

public struct HeaderZStack: View {
    @Environment(\.presentationMode) var presentationMode
    private let items: [AnyView]
    private var title: String
    let width = UIScreen.main.bounds.width

    public init<A: View>(title: String = "", @ViewBuilder content: () -> A) { // this init will be used for any non-supported number of TupleView
        self.items = [AnyView(content())]
        self.title = title
    }

    // MARK: TupleView support

    public init<A: View, B: View>(title: String = "", @ViewBuilder content: () -> TupleView<(A, B)>) {
        let views = content().value
        self.items = [AnyView(views.0), AnyView(views.1)]
        self.title = title
    }

    public init<A: View, B: View, C: View>(title: String = "", @ViewBuilder content: () -> TupleView<(A, B, C)>) {
        let views = content().value
        self.items = [AnyView(views.0), AnyView(views.1), AnyView(views.2)]
        self.title = title
    }

    public init<A: View, B: View, C: View, D: View>(title: String = "", @ViewBuilder content: () -> TupleView<(A, B, C, D)>) {
        let views = content().value
        self.items = [AnyView(views.0), AnyView(views.1), AnyView(views.2), AnyView(views.3)]
        self.title = title
    }

    // MARK: ForEach support

    public init<Data, Content: View, ID : Hashable>(title: String = "", @ViewBuilder content: () -> ForEach<Data, ID, Content>) {
        let views = content()
        self.items = views.data.map({ AnyView(views.content($0)) })
        self.title = title
    }

    public var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("BACK")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }).frame(width: 80, height:30)
                Spacer()
                Text(NSLocalizedString(title, comment: "")).foregroundColor(Color(hex:"#825A5A") ?? .black)
                    .bold()
                    .font(.system(size: 20))
                Spacer()
                loadImage(name:"logo_zw.png").resizable()
                    .frame(width:29, height:25)
                    .padding(.trailing, 25)
            }.frame(width:width)
            ZStack {
                ForEach(0..<items.count) { index in
                    self.items[index]
                }
            }
        }
        .navigationBarHidden(true)
        .background(loadImage(name:"gb.jpg").resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all))
    }
}

public struct HeaderStack: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var loading: Bool
    private let items: [AnyView]
    private var title: String
    private var restore: Bool
    private var action: () -> Void
    let width = UIScreen.main.bounds.width

    public init<A: View>(title: String = "", restore: Bool = false, action: @escaping () -> Void = {},  loading:Binding<Bool> = .constant(false), @ViewBuilder content: () -> A) { // this init will be used for any non-supported number of TupleView
        self.items = [AnyView(content())]
        self.title = title
        self.restore = restore
        self.action = action
        self._loading = loading
    }

    // MARK: TupleView support

    public init<A: View, B: View>(title: String = "", restore: Bool = false, action: @escaping () -> Void = {}, loading:Binding<Bool> = .constant(false), @ViewBuilder content: () -> TupleView<(A, B)>) {
        let views = content().value
        self.items = [AnyView(views.0), AnyView(views.1)]
        self.title = title
        self.restore = restore
        self.action = action
        self._loading = loading
    }

    public init<A: View, B: View, C: View>(title: String = "", restore: Bool = false, action: @escaping () -> Void = {}, loading:Binding<Bool> = .constant(false), @ViewBuilder content: () -> TupleView<(A, B, C)>) {
        let views = content().value
        self.items = [AnyView(views.0), AnyView(views.1), AnyView(views.2)]
        self.title = title
        self.restore = restore
        self.action = action
        self._loading = loading
    }

    public init<A: View, B: View, C: View, D: View>(title: String = "", restore: Bool = false, action: @escaping () -> Void = {}, loading:Binding<Bool> = .constant(false), @ViewBuilder content: () -> TupleView<(A, B, C, D)>) {
        let views = content().value
        self.items = [AnyView(views.0), AnyView(views.1), AnyView(views.2), AnyView(views.3)]
        self.title = title
        self.restore = restore
        self.action = action
        self._loading = loading
    }

    // MARK: ForEach support

    public init<Data, Content: View, ID : Hashable>(title: String = "", restore: Bool = false, action: @escaping () -> Void = {}, loading:Binding<Bool> = .constant(false), @ViewBuilder content: () -> ForEach<Data, ID, Content>) {
        let views = content()
        self.items = views.data.map({ AnyView(views.content($0)) })
        self.title = title
        self.restore = restore
        self.action = action
        self._loading = loading
    }
    
    public var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("BACK")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }).frame(width: 80, height:30)
                    Spacer()
                    Text(NSLocalizedString(title, comment: "")).foregroundColor(Color(hex:"#825A5A") ?? .black)
                        .bold()
                        .font(.system(size: 20))
                    Spacer()
                    if restore {
                        Button(action: self.action, label: {
                            Text("RestoreBuy")
                                .font(.system(size: 16))
                                .foregroundColor(Color(.black))
                        })
                        .padding(.trailing, 20)
                    } else {
                        loadImage(name:"logo_zw.png").resizable()
                            .frame(width:29, height:25)
                            .padding(.leading, 31)
                            .padding(.trailing, 20)
                    }
                }.frame(width:width)
                ForEach(0..<items.count) { index in
                    self.items[index]
                }
            }.disabled(loading)
            if loading {
                LoadingView()
            }
        }
        .navigationBarHidden(true)
        .background(loadImage(name:"gb.jpg").resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all))
    }
}



public struct HeaderStackAction: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var loading: Bool
    private let items: [AnyView]
    private var title: String
    private var restore: Bool
    private var actionBack: () -> Void
    private var action: () -> Void
    let width = UIScreen.main.bounds.width

    public init<A: View>(title: String = "", actionBack: @escaping () -> Void = {}, restore: Bool = false, action: @escaping () -> Void = {},  loading:Binding<Bool> = .constant(false), @ViewBuilder content: () -> A) { // this init will be used for any non-supported number of TupleView
        self.items = [AnyView(content())]
        self.title = title
        self.restore = restore
        self.action = action
        self.actionBack = actionBack
        self._loading = loading
    }

    // MARK: TupleView support

    public init<A: View, B: View>(title: String = "", actionBack: @escaping () -> Void = {}, restore: Bool = false, action: @escaping () -> Void = {}, loading:Binding<Bool> = .constant(false), @ViewBuilder content: () -> TupleView<(A, B)>) {
        let views = content().value
        self.items = [AnyView(views.0), AnyView(views.1)]
        self.title = title
        self.restore = restore
        self.action = action
        self.actionBack = actionBack
        self._loading = loading
    }

    public init<A: View, B: View, C: View>(title: String = "", actionBack: @escaping () -> Void = {}, restore: Bool = false, action: @escaping () -> Void = {}, loading:Binding<Bool> = .constant(false), @ViewBuilder content: () -> TupleView<(A, B, C)>) {
        let views = content().value
        self.items = [AnyView(views.0), AnyView(views.1), AnyView(views.2)]
        self.title = title
        self.restore = restore
        self.action = action
        self.actionBack = actionBack
        self._loading = loading
    }

    public init<A: View, B: View, C: View, D: View>(title: String = "", actionBack: @escaping () -> Void = {}, restore: Bool = false, action: @escaping () -> Void = {}, loading:Binding<Bool> = .constant(false), @ViewBuilder content: () -> TupleView<(A, B, C, D)>) {
        let views = content().value
        self.items = [AnyView(views.0), AnyView(views.1), AnyView(views.2), AnyView(views.3)]
        self.title = title
        self.restore = restore
        self.action = action
        self.actionBack = actionBack
        self._loading = loading
    }

    // MARK: ForEach support

    public init<Data, Content: View, ID : Hashable>(title: String = "", actionBack: @escaping () -> Void = {}, restore: Bool = false, action: @escaping () -> Void = {}, loading:Binding<Bool> = .constant(false), @ViewBuilder content: () -> ForEach<Data, ID, Content>) {
        let views = content()
        self.items = views.data.map({ AnyView(views.content($0)) })
        self.title = title
        self.restore = restore
        self.action = action
        self.actionBack = actionBack
        self._loading = loading
    }
    
    public var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: self.actionBack, label: {
                        Text("BACK")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }).frame(width: 80, height:30)
                    Spacer()
                    Text(NSLocalizedString(title, comment: "")).foregroundColor(Color(hex:"#825A5A") ?? .black)
                        .bold()
                        .font(.system(size: 20))
                    Spacer()
                    if restore {
                        Button(action: self.action, label: {
                            Text("RestoreBuy")
                                .font(.system(size: 16))
                                .foregroundColor(Color(.black))
                        })
                        .padding(.trailing, 20)
                    } else {
                        loadImage(name:"logo_zw.png").resizable()
                            .frame(width:29, height:25)
                            .padding(.leading, 31)
                            .padding(.trailing, 20)
                    }
                }.frame(width:width)
                ForEach(0..<items.count) { index in
                    self.items[index]
                }
            }.disabled(loading)
            if loading {
                LoadingView()
            }
        }
        .navigationBarHidden(true)
        .background(loadImage(name:"gb.jpg").resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all))
    }
}
