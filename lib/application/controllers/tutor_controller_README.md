# Tutor Controller

The `TutorController` manages tutor-related functionality including chat threads and API interactions.

## Features

- **Thread Management**: Fetch, create, and manage chat threads
- **Pagination Support**: Load threads in batches with cursor-based pagination
- **Message Pagination**: Seamless lazy loading of messages with scroll-based triggers
- **Real-time State**: Observable state management using GetX
- **Error Handling**: Comprehensive error handling and user feedback
- **Authentication**: Automatic token management for API requests

## Usage

### Initialization

The controller is automatically initialized in `main.dart`:

```dart
Get.put(TutorController());
```

### Accessing the Controller

```dart
final TutorController tutorController = Get.find<TutorController>();
```

### Available Properties

- `threads`: Observable list of Thread objects
- `isLoading`: Loading state indicator for initial load
- `isLoadingMore`: Loading state indicator for thread pagination
- `hasMore`: Whether there are more threads to load
- `nextCursor`: Cursor for the next page of threads
- `messages`: Observable list of Message objects
- `isLoadingMessages`: Loading state indicator for initial message load
- `isLoadingMoreMessages`: Loading state indicator for message pagination
- `hasMoreMessages`: Whether there are more messages to load
- `nextMessageCursor`: Cursor for the next page of messages
- `totalMessageCount`: Total number of messages in the current thread
- `errorMessage`: Current error message if any

### Available Methods

#### Thread Management

##### `fetchThreads()`
Fetches the first page of threads from the API. Called automatically on controller initialization.

##### `loadMoreThreads()`
Loads the next page of threads using cursor-based pagination. Appends new threads to the existing list.

##### `refreshThreads()`
Refreshes the threads list from the API, resetting pagination state.

##### `clearThreads()`
Clears all threads and resets pagination state.

#### Message Management

##### `fetchThreadMessages(String threadId)`
Fetches the first page of messages for a specific thread.

##### `loadMoreMessages()`
Loads the next page of messages using cursor-based pagination. Prepend new messages to the existing list.

##### `refreshMessages()`
Refreshes the messages list for the active thread, resetting pagination state.

#### Thread Operations

##### `createThread(String initialMessage)`
Creates a new thread with the given initial message.

##### `sendMessage(String message)`
Sends a message to the active thread.

##### `setActiveThread(Thread thread)`
Sets a thread as active and loads its messages.

##### `clearActiveThread()`
Clears the active thread and resets message state.

##### `getThreadById(String threadId)`
Returns a specific thread by ID.

##### `getSortedThreads()`
Returns threads sorted by last message date (newest first).

##### `clearError()`
Clears the current error message.

## Pagination Implementation

The controller implements cursor-based pagination for both threads and messages:

### Thread Pagination

1. **Initial Load**: `fetchThreads()` loads the first 10 threads
2. **Load More**: `loadMoreThreads()` loads the next 10 threads using the `nextCursor`
3. **State Management**: Tracks `hasMore` and `nextCursor` for pagination state
4. **UI Integration**: The drawer shows a "Load More" button when more threads are available

### Message Pagination

1. **Initial Load**: `fetchThreadMessages()` loads the first 10 messages
2. **Lazy Loading**: `loadMoreMessages()` loads the next 10 messages when user scrolls to top
3. **State Management**: Tracks `hasMoreMessages` and `nextMessageCursor` for pagination state
4. **UI Integration**: Automatically triggers when user scrolls to the top of the message list

### Pagination Flow

```dart
// Thread pagination
await tutorController.fetchThreads();
if (tutorController.hasMore.value) {
  await tutorController.loadMoreThreads();
}

// Message pagination (automatic on scroll)
// The UI automatically calls loadMoreMessages() when user scrolls to top
await tutorController.fetchThreadMessages(threadId);

// Refresh to reset pagination
await tutorController.refreshThreads();
await tutorController.refreshMessages();
```

## API Endpoints

The controller uses the following endpoints through `TutorService`:

- `GET /threads?limit=10&cursor=abc123` - Fetch threads with pagination
- `GET /threads/{threadId}/messages?limit=10&cursor=abc123` - Fetch messages with pagination
- `GET /courses/{courseId}/messages?limit=10&cursor=abc123` - Fetch course messages with pagination
- `POST /threads` - Create a new thread
- `POST /threads/{threadId}/messages` - Send a message to a thread

## Data Models

### Thread
```dart
class Thread {
  final String threadId;
  final String initialMessage;
  final DateTime lastMessageAt;
  final int messageCount;
  final String? courseId;
  final String? courseTitle;
}
```

### ThreadsResponse
```dart
class ThreadsResponse {
  final List<Thread> threads;
  final bool hasMore;
  final String? nextCursor;
}
```

### ThreadMessagesResponse
```dart
class ThreadMessagesResponse {
  final String threadId;
  final List<Message> messages;
  final bool hasMore;
  final String? nextCursor;
  final int? totalCount;
}
```

## UI Integration

The controller is integrated with the tutor interface to provide seamless pagination:

### Thread List (Drawer)
- Shows a loading indicator during initial load
- Displays threads in a scrollable list
- Shows a "Load More" button when more threads are available
- Supports pull-to-refresh functionality
- Handles loading states for both initial load and pagination

### Message List (Chat)
- Shows a loading indicator during initial load
- Displays messages in a reverse chronological order
- Automatically loads more messages when user scrolls to the top
- Shows a loading indicator at the top when loading more messages
- Maintains scroll position during lazy loading
- Handles loading states for both initial load and pagination
