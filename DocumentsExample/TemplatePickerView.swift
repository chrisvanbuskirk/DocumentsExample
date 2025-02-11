import SwiftUI

struct TemplatePickerView: View {
    let completion: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose a Template")
                .font(.system(size: 24, weight: .bold))
            
            TemplateButton(
                title: "Plain Text Template",
                subtitle: "Start with a basic text document"
            ) {
                completion("exampletext", "TextTemplate")
                dismiss()
            }
            
            TemplateButton(
                title: "Rich Text Template",
                subtitle: "Start with a formatted document"
            ) {
                completion("sampledoc", "RichTemplate")
                dismiss()
            }
            
            Button("Cancel") {
                completion("", "")
                dismiss()
            }
        }
        .padding()
    }
}

struct TemplateButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
} 