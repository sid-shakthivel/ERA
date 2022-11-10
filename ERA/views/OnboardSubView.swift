//
//  OnboardView.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 27/10/2022.
//

import SwiftUI

struct OnboardingData: Hashable, Identifiable {
    let id: Int
    let backgroundImage: String
    let mainText: String
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct OnboardSubView: View {
    var data: OnboardingData
    var id: Int
    @State var isAnimating = true
    
    func modifyText(text: String) -> LocalizedStringKey {
        var markdownStringArray: [String] = []
        
        for substring in text.split(separator: " ") {
            markdownStringArray.append(enhanceText(text: String(substring)))
        }

        return LocalizedStringKey(markdownStringArray.joined(separator: " "))
    }
    
    @EnvironmentObject var userSettings: UserCustomisations
    
    var body: some View {
        VStack() {
            Spacer()
            
            Image(data.backgroundImage)
                .resizable()
                .scaledToFit()
                .padding()
            
            Spacer()

            Text(modifyText(text: data.mainText))
                .foregroundColor(Color(hex: 0x000000))
                .font(.system(size: 24))
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
            
            if (id == 2) {
                NavigationLink(destination: Home(showMenu: true).preferredColorScheme(.light).environmentObject(userSettings)) {
                    Text("Welcome to ERA")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color(hex: 0xCB4E25, alpha: 1))
                        .font(.system(size: 18))
                        .clipShape(Capsule())
                        .fontWeight(.semibold)
                }
                .padding()
            }
            
            Spacer()
        }
        .onAppear(perform: {
            isAnimating = false
            withAnimation(.easeOut(duration: 0.5)) {
                self.isAnimating = true
            }
        })
    }
}

//struct OnboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardSubView()
//    }
//}
