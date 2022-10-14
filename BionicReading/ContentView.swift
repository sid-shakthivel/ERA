//
//  ContentView.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 29/09/2022.
//

import SwiftUI
import CoreData

class UserCustomisations: ObservableObject {
    @Published var selectedTextSize: Int = 20
    @Published var selectedTextColour: Color = .orange
    @Published var selectedBackgroundColour: Color = .blue
    @Published var selectedFont: UIFont = UIFont.systemFont(ofSize: 20)
    @Published var selectedHeadingFont: UIFont = UIFont.systemFont(ofSize: 40)
    @Published var isBionicReading: Bool = false
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct ContentView: View {
    @State var selectedFont: UIFontDescriptor
    
    @StateObject var userSettings = UserCustomisations()
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Easy Reading Assistant")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .textCase(.uppercase)

                    Spacer()
                    
                    Image("setting")
                }
                .padding()
                
                Group {
                    Text("Document Heading")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .font(.system(size: 24))
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        Text("Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet.")
                            .foregroundColor(.black)
                            .fontWeight(.regular)
                            .font(.system(size: 16))
                            .lineSpacing(10)
                    }
                }
                .padding()
                
                Group {
                    VStack {
                        Button {
                            
                        } label: {
                            HStack {
                                Image("scan")
                                
                                Text("Scan Document")
                                    .foregroundColor(.black)
                                    .textCase(.uppercase)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 14))
                                
                                Image("arrow-right")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                            .padding(.horizontal, 30)
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Image("upload")
                                
                                Text("Upload Document")
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                                    .textCase(.uppercase)
                                    .font(.system(size: 14))
                                
                                Image("arrow-right")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .background(Color.white)
            }
        }
        .background(Color(hex: 0xFFF9F0, alpha: 1))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(selectedFont: UIFontDescriptor(name: "CourierNewPSMT", size: 20)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
