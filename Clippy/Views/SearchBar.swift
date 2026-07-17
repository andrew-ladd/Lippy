import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var showCategoryBar: Bool
    @Binding var selectedCategory: ClipboardCategory?
    @State private var isEditing = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.leading, 8)
                .imageScale(.medium)
            
            TextField("Search", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 7)
                .onTapGesture {
                    isEditing = true
                }
                .onChange(of: text) {
                    NotificationCenter.default.post(name: NSNotification.Name("SearchTextChanged"), object: nil)
                }
                .onSubmit {
                    NotificationCenter.default.post(name: NSNotification.Name("SearchTextChanged"), object: nil)
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    NotificationCenter.default.post(name: NSNotification.Name("SearchTextChanged"), object: nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .imageScale(.medium)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.trailing, 4)
            }
            
            // Category filter toggle button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showCategoryBar.toggle()
                    if !showCategoryBar {
                        selectedCategory = nil
                    }
                }
            }) {
                Image(systemName: showCategoryBar ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(showCategoryBar ? .accentColor : .secondary)
                    .padding(.trailing, 8)
                    .imageScale(.medium)
            }
            .buttonStyle(BorderlessButtonStyle())
            .help("Toggle Category Filter")
        }
        .modifier(GlassCardModifier(cornerRadius: 12))
    }
}

// MARK: - Reusable Liquid Glass modifier with fallback

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 12
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.thickMaterial)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.25), lineWidth: 0.5)
                )
        }
    }
}

struct GlassInteractiveModifier: ViewModifier {
    var cornerRadius: CGFloat = 12
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.thickMaterial)
                        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.25), lineWidth: 0.5)
                )
        }
    }
}

struct GlassCapsuleModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .glassEffect(.regular, in: .capsule)
        } else {
            content
                .background(
                    Capsule()
                        .fill(.thickMaterial)
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.25), lineWidth: 0.5)
                )
        }
    }
}

// Glass modifier for clipboard item cards. The material and shadow remain stable
// while interaction state is drawn with inexpensive overlays.
struct GlassItemModifier: ViewModifier {
    var isPointerHovered: Bool
    var isKeyboardSelected: Bool
    var cornerRadius: CGFloat = 12
    @Environment(\.colorScheme) private var colorScheme

    init(
        isPointerHovered: Bool,
        isKeyboardSelected: Bool = false,
        cornerRadius: CGFloat = 12
    ) {
        self.isPointerHovered = isPointerHovered
        self.isKeyboardSelected = isKeyboardSelected
        self.cornerRadius = cornerRadius
    }

    // Keep pointer-only call sites concise. Keyboard-aware rows should use the
    // explicit initializer above so selection is not mistaken for hover.
    init(isHovered: Bool, cornerRadius: CGFloat = 12) {
        self.init(
            isPointerHovered: isHovered,
            isKeyboardSelected: false,
            cornerRadius: cornerRadius
        )
    }
    
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray.opacity(colorScheme == .dark ? 0.18 : 0.10))
                )
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
                .modifier(
                    ItemInteractionOverlay(
                        isPointerHovered: isPointerHovered,
                        isKeyboardSelected: isKeyboardSelected,
                        cornerRadius: cornerRadius,
                        baseBorderOpacity: 0
                    )
                )
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray.opacity(colorScheme == .dark ? 0.18 : 0.10))
                )
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.1),
                    radius: 3,
                    x: 0,
                    y: 1
                )
                .modifier(
                    ItemInteractionOverlay(
                        isPointerHovered: isPointerHovered,
                        isKeyboardSelected: isKeyboardSelected,
                        cornerRadius: cornerRadius,
                        baseBorderOpacity: colorScheme == .dark ? 0.25 : 0.20
                    )
                )
        }
    }
}

private struct ItemInteractionOverlay: ViewModifier {
    let isPointerHovered: Bool
    let isKeyboardSelected: Bool
    let cornerRadius: CGFloat
    let baseBorderOpacity: Double

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        Color.gray.opacity(baseBorderOpacity),
                        lineWidth: 0.5
                    )
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.accentColor.opacity(0.15))
                    .opacity(isPointerHovered ? 1 : 0)
                    .animation(.easeOut(duration: 0.08), value: isPointerHovered)
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.accentColor.opacity(0.10))
                    .opacity(isKeyboardSelected ? 1 : 0)
                    .animation(
                        .interactiveSpring(
                            response: 0.12,
                            dampingFraction: 0.9,
                            blendDuration: 0.06
                        ),
                        value: isKeyboardSelected
                    )
                    .allowsHitTesting(false)
            }
    }
}
