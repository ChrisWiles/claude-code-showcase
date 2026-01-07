---
name: django-channels
description: Django Channels patterns for WebSocket communication, real-time features, and async consumers. Use when implementing WebSockets, chat features, or real-time updates.
---

# Django Channels Patterns

## Project Setup

```python
# config/asgi.py
import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

django_asgi = get_asgi_application()

from apps.chat import routing  # Import after Django setup

application = ProtocolTypeRouter({
    "http": django_asgi,
    "websocket": AuthMiddlewareStack(
        URLRouter(routing.websocket_urlpatterns)
    ),
})

# config/settings.py
INSTALLED_APPS = [
    "daphne",  # Add before django.contrib.staticfiles
    "channels",
    ...
]

ASGI_APPLICATION = "config.asgi.application"
CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {"hosts": [("127.0.0.1", 6379)]},
    },
}
```

## URL Routing

```python
# apps/chat/routing.py
from django.urls import re_path
from apps.chat import consumers

websocket_urlpatterns = [
    re_path(r"ws/chat/(?P<room_name>\w+)/$", consumers.ChatConsumer.as_asgi()),
    re_path(r"ws/notifications/$", consumers.NotificationConsumer.as_asgi()),
]
```

## Basic Consumer

```python
# apps/chat/consumers.py
import json
from channels.generic.websocket import AsyncWebsocketConsumer

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_name = self.scope["url_route"]["kwargs"]["room_name"]
        self.room_group_name = f"chat_{self.room_name}"

        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        await self.accept()

    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data["message"]

        # Send to room group
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                "type": "chat_message",
                "message": message,
                "username": self.scope["user"].username,
            }
        )

    async def chat_message(self, event):
        """Handle chat_message event from group."""
        await self.send(text_data=json.dumps({
            "message": event["message"],
            "username": event["username"],
        }))
```

## Authenticated Consumer

```python
class AuthenticatedConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope["user"]

        if not self.user.is_authenticated:
            await self.close()
            return

        self.user_group = f"user_{self.user.id}"

        await self.channel_layer.group_add(
            self.user_group,
            self.channel_name
        )
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, "user_group"):
            await self.channel_layer.group_discard(
                self.user_group,
                self.channel_name
            )
```

## Notification Consumer

```python
class NotificationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        user = self.scope["user"]
        if not user.is_authenticated:
            await self.close()
            return

        self.group_name = f"notifications_{user.id}"

        await self.channel_layer.group_add(
            self.group_name,
            self.channel_name
        )
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, "group_name"):
            await self.channel_layer.group_discard(
                self.group_name,
                self.channel_name
            )

    async def notification(self, event):
        """Send notification to WebSocket."""
        await self.send(text_data=json.dumps({
            "type": "notification",
            "title": event["title"],
            "message": event["message"],
            "url": event.get("url"),
        }))
```

## Sending from Views/Tasks

```python
# apps/notifications/services.py
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

def send_notification(user_id: int, title: str, message: str) -> None:
    """Send notification to user's WebSocket."""
    channel_layer = get_channel_layer()

    async_to_sync(channel_layer.group_send)(
        f"notifications_{user_id}",
        {
            "type": "notification",
            "title": title,
            "message": message,
        }
    )

# Usage in view
def create_comment(request, post_id):
    comment = Comment.objects.create(...)

    # Notify post author
    send_notification(
        post.author_id,
        title="New Comment",
        message=f"{request.user.username} commented on your post"
    )

    return redirect("posts:detail", pk=post_id)
```

## Database Access in Consumers

```python
from channels.db import database_sync_to_async

class ChatConsumer(AsyncWebsocketConsumer):
    @database_sync_to_async
    def save_message(self, room_name: str, username: str, message: str):
        from apps.chat.models import Message, Room

        room = Room.objects.get(name=room_name)
        return Message.objects.create(
            room=room,
            username=username,
            content=message,
        )

    @database_sync_to_async
    def get_recent_messages(self, room_name: str, limit: int = 50):
        from apps.chat.models import Message

        messages = Message.objects.filter(
            room__name=room_name
        ).order_by("-created_at")[:limit]

        return list(messages.values("username", "content", "created_at"))

    async def connect(self):
        # ... connect logic ...

        # Send recent messages on connect
        messages = await self.get_recent_messages(self.room_name)
        await self.send(text_data=json.dumps({
            "type": "history",
            "messages": messages,
        }))
```

## Client-Side JavaScript

```javascript
// Basic WebSocket connection
const ws = new WebSocket(
    `ws://${window.location.host}/ws/chat/${roomName}/`
);

ws.onopen = () => {
    console.log("WebSocket connected");
};

ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    console.log("Received:", data);
};

ws.onclose = () => {
    console.log("WebSocket closed");
};

// Send message
ws.send(JSON.stringify({
    message: "Hello!"
}));
```

### With HTMX Integration

```html
<div id="messages" hx-ext="ws" ws-connect="/ws/chat/{{ room_name }}/">
    <div id="message-list">
        <!-- Messages appear here -->
    </div>

    <form ws-send>
        <input name="message" placeholder="Type a message...">
        <button type="submit">Send</button>
    </form>
</div>
```

## Testing Consumers

```python
import pytest
from channels.testing import WebsocketCommunicator
from apps.chat.consumers import ChatConsumer

@pytest.mark.asyncio
async def test_chat_consumer_connect():
    communicator = WebsocketCommunicator(
        ChatConsumer.as_asgi(),
        "/ws/chat/test-room/"
    )

    connected, _ = await communicator.connect()
    assert connected

    await communicator.disconnect()

@pytest.mark.asyncio
async def test_chat_consumer_send_message():
    communicator = WebsocketCommunicator(
        ChatConsumer.as_asgi(),
        "/ws/chat/test-room/"
    )

    await communicator.connect()

    # Send message
    await communicator.send_json_to({"message": "Hello"})

    # Receive response
    response = await communicator.receive_json_from()
    assert response["message"] == "Hello"

    await communicator.disconnect()
```

## Running Channels

```bash
# Development with Daphne
uv run daphne config.asgi:application

# Or with uvicorn
uv run uvicorn config.asgi:application --reload
```

## Anti-Patterns

```python
# BAD: Sync database call in async consumer
async def receive(self, text_data):
    Message.objects.create(...)  # Blocks event loop!

# GOOD: Use database_sync_to_async
async def receive(self, text_data):
    await self.save_message(...)

# BAD: Not handling disconnection
async def disconnect(self, close_code):
    pass  # Leaves user in groups!

# GOOD: Clean up on disconnect
async def disconnect(self, close_code):
    await self.channel_layer.group_discard(
        self.group_name,
        self.channel_name
    )
```

## Integration with Other Skills

- **celery-patterns**: Trigger WebSocket updates from tasks
- **pytest-django-patterns**: Testing WebSocket consumers
- **htmx-alpine-patterns**: HTMX WebSocket extension
