# Tutor Controller

The `TutorController` manages tutor-related functionality including chat threads and API interactions.

## Features

- **Thread Management**: Fetch, create, and manage chat threads
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
- `isLoading`: Loading state indicator
- `hasMore`: Whether there are more threads to load
- `errorMessage`: Current error message if any

### Available Methods

#### `fetchThreads()`
Fetches all threads from the API. Called automatically on controller initialization.

#### `createThread(String initialMessage)`
Creates a new thread with the given initial message.

#### `refreshThreads()`
Refreshes the threads list from the API.

#### `getThreadById(String threadId)`
Returns a specific thread by ID.

#### `getSortedThreads()`
Returns threads sorted by last message date (newest first).

#### `clearError()`
Clears the current error message.

## API Endpoints

The controller uses the following endpoints through `TutorService`:

- `GET /threads` - Fetch all threads
- `POST /threads` - Create a new thread
- `GET /threads/{threadId}/messages` - Get messages for a thread
- `POST /threads/{threadId}/messages` - Send a message to a thread

## Data Models

### Thread
```dart
class Thread {
  final String threadId;
  final String initialMessage;
  final DateTime lastMessageAt;
  final int messageCount;
}
```

### ThreadsResponse
```dart
class ThreadsResponse {
  final List<Thread> threads;
  final bool hasMore;
}
```

## UI Integration

The controller is integrated with the tutor drawer (`LumiDrawer`) to display chat history. The drawer automatically:

- Shows loading state while fetching threads
- Displays error messages if API calls fail
- Shows "No chat history" when no threads exist
- Lists threads sorted by recent activity
- Provides refresh functionality

## Error Handling

The controller handles various error scenarios:

- Authentication failures
- Network errors
- API errors
- Invalid responses

All errors are stored in `errorMessage` and can be displayed to the user.
