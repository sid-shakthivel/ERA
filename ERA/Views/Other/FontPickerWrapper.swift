//
//  FontPickerWrapper.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 06/11/2022.
//

import SwiftUI
import UIKit

struct FontPickerWrapper: View {
    @Binding var isShowingFontPicker: Bool
    @EnvironmentObject var settings: UserPreferences
    
    var body: some View {
        VStack {
            HStack {
                Text("Font Picker")
                    .font(Font(settings.subheadingFont))
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    isShowingFontPicker.toggle()
                }, label: {
                    Text("Cancel")
                })
            }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top)
                .padding(.trailing)
                .padding(.leading)
                
            CustomFontPicker(settings: _settings)
        }
    }
}

struct CustomFontPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIFontPickerViewController
    @EnvironmentObject var settings: UserPreferences
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIFontPickerViewController {
        let configuration = UIFontPickerViewController.Configuration()
        configuration.includeFaces = false
        let vc = UIFontPickerViewController(configuration: configuration)
        vc.delegate = context.coordinator
        return vc
    }
    
    func makeCoordinator() -> CustomFontPicker.CustomFontPickerCoordinator {
        return CustomFontPickerCoordinator(self)
    }
    
    public class CustomFontPickerCoordinator: NSObject, UIFontPickerViewControllerDelegate {
        var parent: CustomFontPicker
        
        init (_ parent: CustomFontPicker) {
            self.parent = parent
        }
        
        public func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        public func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
            
            guard let descriptor = viewController.selectedFontDescriptor else { return }
            
//            DispatchQueue.main.async {
//                self.parent.settings.paragraphFont = UIFont(descriptor: descriptor, size: CGFloat(parent.settings.paragraphFontSize))
//                self.parent.settings.headingFont = UIFont(descriptor: descriptor, size: CGFloat(Double(parent.settings.paragraphFontSize) * 1.5))
//                self.parent.settings.subheadingFont = UIFont(descriptor: descriptor, size: CGFloat(Double(parent.settings.paragraphFontSize) * 1.25))
//                self.parent.settings.subParagaphFont = UIFont(descriptor: descriptor, size: CGFloat(Double(parent.settings.paragraphFontSize) * 0.75))
//
//                self.parent.presentationMode.wrappedValue.dismiss()
//            }
            
            guard let descriptor = viewController.selectedFontDescriptor else { return }

            parent.settings.paragraphFont = UIFont(descriptor: descriptor, size: CGFloat(parent.settings.paragraphFontSize))
            parent.settings.headingFont = UIFont(descriptor: descriptor, size: CGFloat(Double(parent.settings.paragraphFontSize) * 1.5))
            parent.settings.subheadingFont = UIFont(descriptor: descriptor, size: CGFloat(Double(parent.settings.paragraphFontSize) * 1.25))
            parent.settings.subParagaphFont = UIFont(descriptor: descriptor, size: CGFloat(Double(parent.settings.paragraphFontSize) * 0.75))

            parent.settings.saveSettings(userPreferences: parent.settings)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }

    func bold() -> UIFont? {
        guard let boldDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) else {
            return nil
        }

        return UIFont(descriptor: boldDescriptor, size: pointSize)
        
        
//        return withTraits(traits: .traitBold)
    }
}
