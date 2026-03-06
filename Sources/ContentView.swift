import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ReminderStore
    @State private var draftMessage = ""
    @State private var showingAddSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HeaderSection()
            PinnedMessageSection(draftMessage: $draftMessage)
            ReminderListSection()
            FooterSection(showingAddSheet: $showingAddSheet)
        }
        .padding(18)
        .frame(width: 390, height: 560)
        .background(Color(red: 0.96, green: 0.94, blue: 0.89))
        .onAppear {
            draftMessage = store.state.pinnedMessage
        }
        .sheet(isPresented: $showingAddSheet) {
            AddReminderSheet(isPresented: $showingAddSheet)
                .environmentObject(store)
        }
    }
}

private struct HeaderSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Reminder")
                .font(AppFonts.body(size: 23))
            Text("顶部文段固定显示，下面记录已经做过的事和待办。")
                .font(AppFonts.body(size: 12))
                .foregroundStyle(.secondary)
        }
    }
}

private struct PinnedMessageSection: View {
    @EnvironmentObject private var store: ReminderStore
    @Binding var draftMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("置顶文段")
                .font(AppFonts.body(size: 14))

            TextEditor(text: $draftMessage)
                .font(AppFonts.body(size: 15))
                .scrollContentBackground(.hidden)
                .padding(8)
                .frame(height: 92)
                .background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 14))

            HStack {
                Spacer()
                PressableActionButton(title: "保存文段", tint: Color(red: 0.33, green: 0.41, blue: 0.26)) {
                    ClickFeedback.perform()
                    store.updatePinnedMessage(draftMessage)
                }
            }
        }
    }
}

private struct ReminderListSection: View {
    @EnvironmentObject private var store: ReminderStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reminder List")
                .font(AppFonts.body(size: 14))

            if store.state.items.isEmpty {
                Text("还没有事项，点底部的 + 添加。")
                    .font(AppFonts.body(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 14))
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(store.state.items) { item in
                            ReminderRow(
                                item: item,
                                onToggle: {
                                    ClickFeedback.perform()
                                    store.toggleKind(for: item)
                                },
                                onDelete: {
                                    ClickFeedback.perform()
                                    delete(item)
                                }
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func delete(_ item: ReminderItem) {
        guard let index = store.state.items.firstIndex(of: item) else { return }
        store.removeItems(at: IndexSet(integer: index))
    }
}

private struct FooterSection: View {
    @Binding var showingAddSheet: Bool

    var body: some View {
        HStack(spacing: 14) {
            Button {
                ClickFeedback.perform()
                showingAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(SquareProminentButtonStyle())

            Text("点击事项切换状态，右侧 trash 删除。")
                .font(AppFonts.body(size: 12))
                .foregroundStyle(.secondary)

            Spacer()

            Button("退出") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(SecondaryActionButtonStyle())
        }
    }
}

private struct ReminderRow: View {
    let item: ReminderItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: onToggle) {
                HStack(alignment: .top, spacing: 10) {
                    Text(item.kind.symbol)
                        .font(AppFonts.body(size: 18))
                        .foregroundStyle(item.kind == .done ? Color.black : Color.secondary)

                    Text(item.text)
                        .font(AppFonts.body(size: 15))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(RowButtonStyle())

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(TrashButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct AddReminderSheet: View {
    @EnvironmentObject private var store: ReminderStore
    @Binding var isPresented: Bool

    @State private var text = ""
    @State private var kind: ReminderKind = .todo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("添加事项")
                .font(AppFonts.body(size: 20))

            TextField("写下提醒或已完成事项", text: $text)
                .font(AppFonts.body(size: 15))
                .textFieldStyle(.roundedBorder)

            Picker("类型", selection: $kind) {
                ForEach(ReminderKind.allCases) { kind in
                    Text("\(kind.symbol) \(kind.title)").tag(kind)
                }
            }
            .pickerStyle(.segmented)
            .font(AppFonts.body(size: 13))

            HStack {
                Spacer()

                Button("取消") {
                    isPresented = false
                }
                .buttonStyle(SecondaryActionButtonStyle())

                Button("添加") {
                    ClickFeedback.perform()
                    store.addItem(text: text, kind: kind)
                    isPresented = false
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 320)
        .background(Color(red: 0.97, green: 0.95, blue: 0.91))
    }
}

private struct PressableActionButton: View {
    let title: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(PrimaryActionButtonStyle(tint: tint))
    }
}

private struct PrimaryActionButtonStyle: ButtonStyle {
    var tint = Color(red: 0.24, green: 0.29, blue: 0.17)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.body(size: 13))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(tint.opacity(configuration.isPressed ? 0.9 : 1.0), in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(Color.white)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

private struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.body(size: 13))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(configuration.isPressed ? 0.12 : 0.07), in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.primary)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

private struct SquareProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(Color(red: 0.20, green: 0.29, blue: 0.12).opacity(configuration.isPressed ? 0.88 : 1.0), in: RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

private struct RowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 2)
            .background(Color.black.opacity(configuration.isPressed ? 0.06 : 0.0), in: RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

private struct TrashButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.secondary)
            .background(Color.black.opacity(configuration.isPressed ? 0.08 : 0.0), in: RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

private enum ClickFeedback {
    static func perform() {
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .default)
    }
}
