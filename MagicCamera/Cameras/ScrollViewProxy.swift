//
//  ScrollViewProxy.swift
//  MagicCamera
//
//  Created by William on 2021/3/26.
//

import SwiftUI
import Combine

// MARK: Fix for name collision when using SwiftUI 2.0
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias AmzdScrollViewProxy = MyScrollViewProxy
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias AmzdScrollViewReader = ScrollViewReader

// MARK: Platform specifics
#if os(macOS)
public typealias PlatformScrollView = NSScrollView

var visibleSizePath = \PlatformScrollView.documentVisibleRect.size
var adjustedContentInsetPath = \PlatformScrollView.contentInsets
var contentSizePath = \PlatformScrollView.documentView!.frame.size

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension NSScrollView {
    func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        if animated {
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = 0.3
            contentView.scrollToVisible(rect)
            NSAnimationContext.endGrouping()
        } else {
            contentView.scrollToVisible(rect)
        }
    }
    var offsetPublisher: OffsetPublisher {
        publisher(for: \.contentView.bounds.origin).eraseToAnyPublisher()
    }
}

extension NSEdgeInsets {
    /// top + bottom
    var vertical: CGFloat {
        return top + bottom
    }
    /// left + right
    var horizontal: CGFloat {
        return left + right
    }
}
#elseif os(iOS) || os(tvOS)
public typealias PlatformScrollView = UIScrollView

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
var visibleSizePath = \PlatformScrollView.visibleSize
var adjustedContentInsetPath = \PlatformScrollView.adjustedContentInset
var contentSizePath = \PlatformScrollView.contentSize

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension UIScrollView {
    var offsetPublisher: OffsetPublisher {
        publisher(for: \.contentOffset).eraseToAnyPublisher()
    }
}

extension UIEdgeInsets {
    /// top + bottom
    var vertical: CGFloat {
        return top + bottom
    }
    /// left + right
    var horizontal: CGFloat {
        return left + right
    }
}
#endif

// MARK: Helper extensions
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension ScrollView {
    /// Creates a ScrollView with a ScrollViewReader
    public init<ProxyContent: View>(_ axes: Axis.Set = .vertical, showsIndicators: Bool = true, @ViewBuilder content: @escaping (MyScrollViewProxy) -> ProxyContent) where Content == ScrollViewReader<ProxyContent> {
        self.init(axes, showsIndicators: showsIndicators, content: {
            ScrollViewReader(content: content)
        })
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    /// Adds an ID to this view so you can scroll to it with `MyScrollViewProxy.scrollTo(_:alignment:animated:)`
    public func scrollId<ID: Hashable>(_ id: ID) -> some View {
        modifier(ScrollViewProxyPreferenceModifier(id: id))
    }
    
    @available(swift, obsoleted: 1.0, renamed: "scrollId(_:)")
    public func id<ID: Hashable>(_ id: ID, scrollView: MyScrollViewProxy) -> some View { self }
}

// MARK: Preferences
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
struct ScrollViewProxyPreferenceData: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    var geometry: GeometryProxy
    var id: AnyHashable
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
struct ScrollViewProxyPreferenceKey: PreferenceKey {
    static var defaultValue: [ScrollViewProxyPreferenceData] { [] }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
struct ScrollViewProxyPreferenceModifier: ViewModifier {
    let id: AnyHashable
    func body(content: Content) -> some View {
        content.background(GeometryReader { geometry in
            Color.clear.preference(
                key: ScrollViewProxyPreferenceKey.self,
                value: [.init(geometry: geometry, id: self.id)]
            )
        })
    }
}

// MARK: ScrollViewReader
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ScrollViewReader<Content: View>: View {
    private var content: (MyScrollViewProxy) -> Content

    @State private var proxy = MyScrollViewProxy()
    
    public init(@ViewBuilder content: @escaping (MyScrollViewProxy) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(proxy)
            .coordinateSpace(name: proxy.space)
            .transformPreference(ScrollViewProxyPreferenceKey.self) { preferences in
                preferences.forEach { preference in
                    self.proxy.save(geometry: preference.geometry, for: preference.id)
                }
            }
            .onPreferenceChange(ScrollViewProxyPreferenceKey.self) { _ in
                // seems this will not be called due to ScrollView/Preference issues
                // https://stackoverflow.com/a/61765994/3019595
            }
            .introspectScrollView {
                if self.proxy.coordinator.scrollView != $0 {
                    self.proxy.coordinator.scrollView = $0
                    self.proxy.offset = $0.offsetPublisher
                }
            }
    }
}

// MARK: MyScrollViewProxy
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias OffsetPublisher = AnyPublisher<CGPoint, Never>

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct MyScrollViewProxy {
    fileprivate class Coordinator {
        var frames = [AnyHashable: CGRect]()
        weak var scrollView: PlatformScrollView?
    }
    fileprivate var coordinator = Coordinator()
    fileprivate var space: UUID = UUID()

    fileprivate init() {}
    
    /// A publisher that publishes changes to the scroll views offset
    public fileprivate(set) var offset: OffsetPublisher = Just(.zero).eraseToAnyPublisher()

    /// Scrolls to an edge or corner
    public func scrollTo(_ alignment: Alignment, animated: Bool = true) {
        guard let scrollView = coordinator.scrollView else { return }

        let contentRect = CGRect(origin: .zero, size: scrollView.contentSize)
        let visibleFrame = frame(contentRect, with: alignment)
        scrollView.scrollRectToVisible(visibleFrame, animated: animated)
    }

    /// Scrolls the view with ID to an edge or corner
    public func scrollTo<ID: Hashable>(_ id: ID, alignment: Alignment = .top, animated: Bool = true) {
        guard let scrollView = coordinator.scrollView else { return }
        guard let cellFrame = coordinator.frames[id] else {
            return debugPrint("ID (\(id)) not found, make sure to add views with `.id(_:scrollView:)`. Did find: \(coordinator.frames)")
        }

        let visibleFrame = frame(cellFrame, with: alignment)
        scrollView.scrollRectToVisible(visibleFrame, animated: animated)
    }

    private func frame(_ frame: CGRect, with alignment: Alignment) -> CGRect {
        guard let scrollView = coordinator.scrollView else { return frame }

        var visibleSize = scrollView[keyPath: visibleSizePath]
        visibleSize.width -= scrollView[keyPath: adjustedContentInsetPath].horizontal
        visibleSize.height -= scrollView[keyPath: adjustedContentInsetPath].vertical

        var origin = CGPoint.zero
        switch alignment {
        case .center:
            origin.x = frame.midX - visibleSize.width / 2
            origin.y = frame.midY - visibleSize.height / 2
        case .leading:
            origin.x = frame.minX
            origin.y = frame.midY - visibleSize.height / 2
        case .trailing:
            origin.x = frame.maxX - visibleSize.width
            origin.y = frame.midY - visibleSize.height / 2
        case .top:
            origin.x = frame.midX - visibleSize.width / 2
            origin.y = frame.minY
        case .bottom:
            origin.x = frame.midX - visibleSize.width / 2
            origin.y = frame.maxY - visibleSize.height
        case .topLeading:
            origin.x = frame.minX
            origin.y = frame.minY
        case .topTrailing:
            origin.x = frame.maxX - visibleSize.width
            origin.y = frame.minY
        case .bottomLeading:
            origin.x = frame.minX
            origin.y = frame.maxY - visibleSize.height
        case .bottomTrailing:
            origin.x = frame.maxX - visibleSize.width
            origin.y = frame.maxY - visibleSize.height
        default:
            fatalError("Not implemented")
        }

        origin.x = max(0, min(origin.x, scrollView[keyPath: contentSizePath].width - visibleSize.width))
        origin.y = max(0, min(origin.y, scrollView[keyPath: contentSizePath].height - visibleSize.height))
        return CGRect(origin: origin, size: visibleSize)
    }

    fileprivate func save(geometry: GeometryProxy, for id: AnyHashable) {
        coordinator.frames[id] = geometry.frame(in: .named(space))
    }
}
