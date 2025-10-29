
import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatThread.createdAt, order: .reverse) private var threads: [ChatThread]

    @State private var activeThread: ChatThread?
    @State private var draft: String = ""
    @State private var isBusy = false
    @State private var errorText: String?
    @State private var showingHistory = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(activeThread?.title ?? "Keto (On-Device)")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            Button("New Thread") { newThread() }
                            if let t = activeThread {
                                Button("Rename Thread") { renameThread(t) }
                                Button("Delete Thread", role: .destructive) { deleteThread(t) }
                            }
                        } label: {
                            Label("Threads", systemImage: "folder")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("History") { showingHistory = true }.disabled(activeThread == nil)
                    }
                }
                .sheet(isPresented: $showingHistory) {
                    if let t = activeThread {
                        HistoryView(thread: t)
                    }
                }
                .onAppear {
                    if activeThread == nil { activeThread = threads.first ?? createInitialThread() }
                }
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            if let thread = activeThread {
                MessageList(threadID: thread.chatID)
            } else {
                Text("No thread selected.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if let e = errorText {
                Text(e).foregroundStyle(.red).padding(.horizontal)
            }

            Divider()
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Ask for keto ideas…", text: $draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .disabled(isBusy)
                Button(isBusy ? "…" : "Send") { send() }
                    .buttonStyle(.borderedProminent)
                    .disabled(isBusy || draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
    }

    private func send() {
        guard let thread = activeThread else { return }
        let input = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }
        draft = ""; errorText = nil; isBusy = true

        let msg = BaseMessage(text: input, userMessage: true)
        thread.messages.append(msg)
        modelContext.insert(msg)
        
        debugPrint("ChatView.send", thread.chatID, thread.title)
        debugPrint("ChatView.send", msg.messageID, msg.text)
        
        do {
            try modelContext.save() }
        catch {
            errorText = "Save failed: \(error.localizedDescription)"
        }

        Task {
            do {
                if let calc = parseNetCarbDirective(input) {
                    let net = NetCarbsFromTotal(calc.total, calc.fiber, calc.polyols)
                    let reply = """
                    Using your inputs: total=\(calc.total)g, fiber=\(calc.fiber)g, polyols=\(calc.polyols)g → net=\(String(format: "%.1f", net))g.
                    \(try await AI.complete("Given net carbs \(net)g, suggest a matching keto snack."))
                    """
                    persistAssistant(reply, in: thread)
                } else {
                    let reply = try await AI.complete(input)
                    persistAssistant(reply, in: thread)
                }
            } catch {
                errorText = error.localizedDescription
            }
            isBusy = false
        }
    }

    private func persistAssistant(_ text: String, in thread: ChatThread) {
        let a = BaseMessage(text: text, userMessage: false)
        thread.messages.append(a)
        modelContext.insert(a)
        do { try modelContext.save() } catch { errorText = "Save failed: \(error.localizedDescription)" }
    }

    private func createInitialThread() -> ChatThread {
        let t = ChatThread(title: "Keto Chat")
        modelContext.insert(t)
        try? modelContext.save()
        
        debugPrint("ChatView.createInitialThread", t.chatID, t.title)

        return t
    }
    
    private func newThread() { activeThread = createInitialThread() }
    private func renameThread(_ t: ChatThread) {
        t.title = Date.now.formatted(date: .abbreviated, time: .shortened)
        try? modelContext.save()
    }
    private func deleteThread(_ t: ChatThread) {
        modelContext.delete(t); try? modelContext.save(); activeThread = threads.first
    }
}

struct MessageList: View {
    @Environment(\.modelContext) private var modelContext
    let threadID: UUID

    @State private var thread: ChatThread?

    var body: some View {
        Group {
            if let thread {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(thread.messages.sorted(by: { $0.createdAt < $1.createdAt })) { msg in
                                messageView(for: msg)
                                    .id(msg.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: thread.messages.count) { _, _ in
                        if let last = thread.messages.sorted(by: { $0.createdAt < $1.createdAt }).last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task(id: threadID) { // re-fetch whenever ID changes
            await loadThread()
        }
    }

    @MainActor
    private func loadThread() async {
        // Fetch by predicate matching your unique id
        let descriptor = FetchDescriptor<ChatThread>(
            predicate: #Predicate { $0.chatID == threadID }
        )
        
        thread = try? modelContext.fetch(descriptor).first
        
        debugPrint("MessageList.loadThread", thread?.chatID, thread?.title)

    }

    @ViewBuilder
    private func messageView(for msg: BaseMessage) -> some View {
        let text = msg.text
        let isUserMessage = msg.userMessage
        
        VStack(alignment: isUserMessage ? .trailing : .leading) {
            Text(text)
                .textSelection(.enabled)
                .padding(12)
                .background((isUserMessage) ? .blue.opacity(0.15) : .gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(maxWidth: .infinity, alignment: (isUserMessage) ? .trailing : .leading)
        }
    }
}

struct HistoryView: View {
    var thread: ChatThread
    
    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Title", value: thread.title)
                LabeledContent("Messages", value: "\(thread.messages.count)")
                LabeledContent("Created", value: thread.createdAt.formatted())
            }
            Section("Messages") {
                ForEach(thread.messages.sorted(by: { $0.createdAt < $1.createdAt })) { m in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(m.userMessage ? "You" : "Assistant")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(m.text)
                    }
                }
            }
        }
        .navigationTitle("History")
    }
}

// MARK: - Small directive parser
private func parseNetCarbDirective(_ s: String) -> (total: Double, fiber: Double, polyols: Double)? {
    let parts = s.split(separator: " ")
    guard parts.count == 4, parts[0].lowercased() == "netcarbs",
          let t = Double(parts[1]), let f = Double(parts[2]), let p = Double(parts[3]) else {
        return nil
    }
    return (t, f, p)
}
