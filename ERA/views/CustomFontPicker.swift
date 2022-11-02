//
//  CustomFontPicker.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 09/10/2022.
//

import SwiftUI
import Foundation

struct CustomFontPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIFontPickerViewController
    @EnvironmentObject var settings: UserCustomisations
    
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
        
            parent.settings.paragraphFont = UIFont(descriptor: descriptor, size: CGFloat(parent.settings.paragraphFontSize))
            parent.settings.headingFont = UIFont(descriptor: descriptor, size: CGFloat(Double(parent.settings.paragraphFontSize) * 1.5))
            parent.settings.subheadingFont = UIFont(descriptor: descriptor, size: CGFloat(Double(parent.settings.paragraphFontSize) * 1.25))
            parent.settings.subParagaphFont = UIFont(descriptor: descriptor, size: CGFloat(Double(parent.settings.paragraphFontSize) * 0.75))
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
