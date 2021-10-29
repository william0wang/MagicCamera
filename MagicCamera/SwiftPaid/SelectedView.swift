//
//  SelectedView.swift
//  MagicCamera
//
//  Created by William on 2021/5/17.
//

import SwiftUI

struct SelectedView: View {
    @Binding var selected: Bool
    @Binding var disSelected: Bool
    var title: String
    var sale: String
    var price: String
    var priceOrg: String
    
    var body: some View {
        Button(action: {
            self.selected = true
            self.disSelected = false
            },label: {
                ZStack{
                    if selected {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex:"#000000") ?? Color.black, style: StrokeStyle(lineWidth: 1)
                            )
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex:"#fd87ae") ?? Color.pink))
                            .frame(width: 135, height: 150)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex:"#000000") ?? Color.black, style: StrokeStyle(lineWidth: 1)
                            )
                            .frame(width: 135, height: 150)
                    }
                    
                    VStack {
                        HStack{
                            Text(NSLocalizedString(sale, comment: ""))
                                .font(.system(size: 22))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .rotationEffect(Angle(degrees: -30))
                            Spacer()
                        }
                        Spacer()
                    }.frame(width: 165, height: 150)
                    
                    VStack {
                        Spacer()
                        Text(NSLocalizedString(title, comment: ""))
                            .font(.system(size: 20))
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.black)
                        Spacer()
                        Text(NSLocalizedString(price, comment: ""))
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                        Spacer()
                        Text(NSLocalizedString(priceOrg, comment: ""))
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                            .strikethrough(true, color: Color.black)
                        Spacer()
                    }.frame(width: 135, height: 150)
                }
            })
    }
}


struct SelectedTestView: View {
    @State var select = true
    @State var select2 = false
    var body: some View {
        HStack {
            Spacer()
            SelectedView(selected:$select, disSelected:$select2, title: "年卡", sale:"今日特惠", price:"¥ 198", priceOrg:"原价 ¥ 398")
            Spacer()
            SelectedView(selected:$select2, disSelected: $select, title: "月卡", sale:"本月特惠", price:"¥ 48", priceOrg:"原价 ¥ 108")
            Spacer()
        }
    }
}

struct SelectedView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedTestView()
    }
}
