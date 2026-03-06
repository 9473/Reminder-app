import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ReminderStore
    @State private var draftMessage = ""
    @State private var showingAddSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderSection()
            PinnedMessageSection(draftMessage: $draftMessage)
            ReminderListSection()
            FooterSection(showingAddSheet: $showingAddSheet)
        }
        .padding(18)
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
        VStack(alignment: .leading, spacing: 4) {
            Text("给自己的提醒")
                .font(AppFonts.body(size: 22))
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
                .font(AppFonts.body(size: 16))
                .scrollContentBackground(.hidden)
                .padding(10)
                .frame(minHeight: 120)
                .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))

            HStack {
                Spacer()
                Button("保存文段") {
                    store.updatePinnedMessage(draftMessage)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.33, green: 0.41, blue: 0.26))
                .font(AppFonts.body(size: 13))
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
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 14))
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(store.state.items) { item in
                            ReminderRow(
                                item: item,
                                onToggle: { store.toggleKind(for: item) },
                                onDelete: { delete(item) }
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(maxHeight: .infinity)
            }
        }
    }

    private func delete(_ item: ReminderItem) {
        guard let index = store.state.items.firstIndex(of: item) else { return }
        store.removeItems(at: IndexSet(integer: index))
    }
}

private struct FooterSection: View {
    @Binding var showingAddSheet: Bool

    var body: some View {
        HStack {
            Button {
                showingAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.24, green: 0.29, blue: 0.17))

            Text("点击事项切换状态，右侧 trash 删除。")
                .font(AppFonts.body(size: 12))
                .foregroundStyle(.secondary)

            Spacer()

            Button("退出") {
                NSApplication.shared.terminate(nil)
            }
            .font(AppFonts.body(size: 13))
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
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
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
                .font(AppFonts.body(size: 13))

                Button("添加") {
                    store.addItem(text: text, kind: kind)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.24, green: 0.29, blue: 0.17))
                .font(AppFonts.body(size: 13))
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 320)
    }
}
