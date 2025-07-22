import SwiftUI

struct ChatView: View {
    let otherUser: User
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @State private var showImagePicker = false
    @State private var showEmojiPicker = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            messagesListView
            
            // Message Input
            messageInputView
        }
        .background(Constants.Colors.background)
        .navigationTitle(otherUser.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { /* Video call */ }) {
                    Image(systemName: "video")
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
        }
        .onAppear {
            setupChat()
        }
        .onDisappear {
            chatService.stopListeningForMessages()
        }
    }
    
    // MARK: - Messages List View
    private var messagesListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: Constants.Spacing.sm) {
                    if chatService.isLoading {
                        loadingMessages
                    } else {
                        ForEach(chatService.messages, id: \.id) { message in
                            MessageBubbleView(
                                message: message,
                                isFromCurrentUser: message.senderId == FirebaseManager.shared.currentUser?.id
                            )
                            .id(message.id)
                        }
                    }
                }
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
            }
            .onChange(of: chatService.messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    // MARK: - Message Input View
    private var messageInputView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: Constants.Spacing.sm) {
                // Emoji Button
                Button(action: { showEmojiPicker.toggle() }) {
                    Image(systemName: "face.smiling")
                        .font(.title3)
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
                
                // Text Input
                HStack {
                    TextField("Type a message...", text: $messageText, axis: .vertical)
                        .focused($isTextFieldFocused)
                        .textFieldStyle(PlainTextFieldStyle())
                        .lineLimit(1...6)
                        .font(Constants.Fonts.body)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    // Media Button
                    Button(action: { showImagePicker = true }) {
                        Image(systemName: "paperclip")
                            .font(.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
                .background(Constants.Colors.secondaryBackground)
                .cornerRadius(Constants.CornerRadius.large)
                
                // Send Button
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(messageText.isEmpty ? Constants.Colors.border : Constants.Colors.primaryBlue)
                        .cornerRadius(16)
                }
                .disabled(messageText.isEmpty)
                .scaleEffect(messageText.isEmpty ? 0.8 : 1.0)
                .animation(Constants.Animation.quick, value: messageText.isEmpty)
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.sm)
            
            // Emoji Picker
            if showEmojiPicker {
                emojiPickerView
            }
        }
        .background(Constants.Colors.background)
    }
    
    // MARK: - Emoji Picker View
    private var emojiPickerView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.sm) {
                ForEach(frequentlyUsedEmojis, id: \.self) { emoji in
                    Button(action: { addEmoji(emoji) }) {
                        Text(emoji)
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(Constants.Colors.secondaryBackground)
                            .cornerRadius(Constants.CornerRadius.small)
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
        }
        .frame(height: 60)
        .background(Constants.Colors.lightGray.opacity(0.3))
    }
    
    // MARK: - Loading Messages
    private var loadingMessages: some View {
        ForEach(0..<8, id: \.self) { index in
            MessageSkeletonView(isFromCurrentUser: index % 2 == 0)
        }
    }
    
    // MARK: - Helper Properties
    private var frequentlyUsedEmojis: [String] {
        ["😊", "👍", "❤️", "😂", "🎉", "👏", "🔥", "💯", "😍", "🤔", "👌", "💪"]
    }
    
    // MARK: - Actions
    private func setupChat() {
        chatService.createOrGetChatRoom(with: otherUser) { chatRoomId in
            if let chatRoomId = chatRoomId {
                chatService.fetchMessages(for: chatRoomId)
                chatService.startListeningForMessages(in: chatRoomId)
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = messageText
        messageText = ""
        
        withAnimation(Constants.Animation.quick) {
            chatService.sendMessage(content: message)
        }
    }
    
    private func addEmoji(_ emoji: String) {
        messageText += emoji
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = chatService.messages.last {
            withAnimation(Constants.Animation.quick) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - Message Bubble View
struct MessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
                messageBubble
            } else {
                HStack(alignment: .bottom, spacing: Constants.Spacing.xs) {
                    // Profile Image
                    AsyncImage(url: URL(string: message.senderProfileImageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Constants.Colors.lightGray)
                            .overlay(
                                Text(message.senderName.initials)
                                    .font(Constants.Fonts.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                            )
                    }
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                    
                    messageBubble
                }
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, Constants.Spacing.xs)
    }
    
    private var messageBubble: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: Constants.Spacing.xs) {
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                if !isFromCurrentUser {
                    Text(message.senderName)
                        .font(Constants.Fonts.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                        .padding(.horizontal, Constants.Spacing.sm)
                        .padding(.top, Constants.Spacing.xs)
                }
                
                Text(message.content)
                    .font(Constants.Fonts.body)
                    .foregroundColor(isFromCurrentUser ? .white : Constants.Colors.label)
                    .padding(.horizontal, Constants.Spacing.sm)
                    .padding(.bottom, Constants.Spacing.xs)
                    .multilineTextAlignment(.leading)
                
                // Message status and time
                HStack(spacing: Constants.Spacing.xs) {
                    Text(message.createdAt.formatForChat())
                        .font(Constants.Fonts.caption2)
                        .foregroundColor(isFromCurrentUser ? .white.opacity(0.8) : Constants.Colors.secondaryLabel)
                    
                    if isFromCurrentUser {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, Constants.Spacing.sm)
                .padding(.bottom, Constants.Spacing.xs)
            }
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                    .fill(isFromCurrentUser ? Constants.Colors.primaryBlue : Constants.Colors.secondaryBackground)
            )
            .cornerRadius(Constants.CornerRadius.large, corners: isFromCurrentUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
        }
    }
}

// MARK: - Message Skeleton View
struct MessageSkeletonView: View {
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
                Rectangle()
                    .fill(Constants.Colors.lightGray)
                    .frame(width: 200, height: 40)
                    .cornerRadius(Constants.CornerRadius.large)
                    .shimmer(isLoading: true)
            } else {
                Circle()
                    .fill(Constants.Colors.lightGray)
                    .frame(width: 28, height: 28)
                    .shimmer(isLoading: true)
                
                Rectangle()
                    .fill(Constants.Colors.lightGray)
                    .frame(width: 180, height: 40)
                    .cornerRadius(Constants.CornerRadius.large)
                    .shimmer(isLoading: true)
                
                Spacer()
            }
        }
        .padding(.horizontal, Constants.Spacing.md)
    }
}

// MARK: - Chat List View
struct ChatListView: View {
    @StateObject private var chatService = ChatService()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    TextField("Search messages", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
                .background(Constants.Colors.secondaryBackground)
                .cornerRadius(Constants.CornerRadius.medium)
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.top, Constants.Spacing.sm)
                
                // Conversations List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if chatService.isLoading {
                            ForEach(0..<6, id: \.self) { _ in
                                ConversationSkeletonView()
                            }
                        } else {
                            ForEach(filteredConversations, id: \.id) { conversation in
                                NavigationLink(destination: ChatView(otherUser: conversation.otherUser)) {
                                    ConversationRowView(conversation: conversation)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .refreshable {
                    await refreshConversations()
                }
            }
            .background(Constants.Colors.background)
            .navigationTitle("Messages")
            .onAppear {
                chatService.fetchConversations()
            }
        }
    }
    
    private var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return chatService.conversations
        } else {
            return chatService.conversations.filter { conversation in
                conversation.otherUser.fullName.localizedCaseInsensitiveContains(searchText) ||
                conversation.lastMessage?.content.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    @MainActor
    private func refreshConversations() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        chatService.refreshConversations()
    }
}

// MARK: - Conversation Row View
struct ConversationRowView: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            // Profile Image
            AsyncImage(url: URL(string: conversation.otherUser.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Constants.Colors.lightGray)
                    .overlay(
                        Text(conversation.otherUser.fullName.initials)
                            .font(Constants.Fonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.primaryBlue)
                    )
            }
            .frame(width: 52, height: 52)
            .clipShape(Circle())
            .overlay(
                // Online indicator
                Circle()
                    .fill(conversation.otherUser.isOnline ? Constants.Colors.success : .clear)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    )
                , alignment: .bottomTrailing
            )
            
            // Message Content
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                HStack {
                    Text(conversation.otherUser.fullName)
                        .font(Constants.Fonts.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                    
                    Spacer()
                    
                    if let lastMessage = conversation.lastMessage {
                        Text(lastMessage.createdAt.formatForChat())
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
                
                HStack {
                    if let lastMessage = conversation.lastMessage {
                        Text(lastMessage.content)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .lineLimit(1)
                    } else {
                        Text("No messages yet")
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .italic()
                    }
                    
                    Spacer()
                    
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(Constants.Fonts.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Constants.Colors.primaryBlue)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.vertical, Constants.Spacing.sm)
        .background(Constants.Colors.background)
    }
}

// MARK: - Conversation Skeleton View
struct ConversationSkeletonView: View {
    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            Circle()
                .fill(Constants.Colors.lightGray)
                .frame(width: 52, height: 52)
                .shimmer(isLoading: true)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                HStack {
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(width: 120, height: 16)
                        .shimmer(isLoading: true)
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(width: 40, height: 12)
                        .shimmer(isLoading: true)
                }
                
                Rectangle()
                    .fill(Constants.Colors.lightGray)
                    .frame(width: 200, height: 14)
                    .shimmer(isLoading: true)
            }
        }
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.vertical, Constants.Spacing.sm)
    }
}

#Preview {
    ChatListView()
} 