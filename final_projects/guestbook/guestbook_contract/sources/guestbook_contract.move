/// Module: guestbook_contract
/// On-chain guestbook allowing users to leave messages
module guestbook_contract::guestbook_contract;

use std::string::String;
use sui::event;

/// Error codes
const EMessageTooLong: u64 = 1;
const EEmptyMessage: u64 = 2;

/// Maximum message length (100 characters)
const MAX_MESSAGE_LENGTH: u64 = 100;

/// Message struct containing sender address and message content
public struct Message has copy, drop, store {
    sender: address,
    message: String,
}

/// The main Guestbook shared object that stores all messages
public struct Guestbook has key {
    id: UID,
    messages: vector<Message>,
    total_messages: u64,
}

/// Event emitted when a message is posted
public struct MessagePosted has copy, drop {
    sender: address,
    message: String,
    total_messages: u64,
}

/// Event emitted when guestbook is created
public struct GuestbookCreated has copy, drop {
    guestbook_id: ID,
}

/// Initialize the guestbook - creates a shared Guestbook object
#[allow(unused_function)]
fun init(ctx: &mut TxContext) {
    let guestbook = Guestbook {
        id: object::new(ctx),
        messages: vector::empty<Message>(),
        total_messages: 0,
    };

    let guestbook_id = object::id(&guestbook);

    // Emit creation event
    event::emit(GuestbookCreated {
        guestbook_id,
    });

    // Share the guestbook so anyone can post messages
    transfer::share_object(guestbook);
}

/// Public method to create a Message struct (for frontend PTB usage)
public fun create_message(sender: address, message: String): Message {
    let message_length = message.length();

    // Validate message is not empty
    assert!(message_length > 0, EEmptyMessage);

    // Validate message length
    assert!(message_length <= MAX_MESSAGE_LENGTH, EMessageTooLong);

    Message {
        sender,
        message,
    }
}

/// Post a message to the guestbook
public fun post_message(guestbook: &mut Guestbook, message: Message) {
    // Add message to the guestbook
    vector::push_back(&mut guestbook.messages, message);

    // Update total message count
    guestbook.total_messages = guestbook.total_messages + 1;

    // Emit event for frontend tracking
    event::emit(MessagePosted {
        sender: message.sender,
        message: message.message,
        total_messages: guestbook.total_messages,
    });
}

/// Get all messages from the guestbook
public fun get_messages(guestbook: &Guestbook): vector<Message> {
    guestbook.messages
}

/// Get the total number of messages
public fun get_message_count(guestbook: &Guestbook): u64 {
    guestbook.total_messages
}

/// Get message content by sender address
public fun get_message_sender(message: &Message): address {
    message.sender
}

/// Get message content
public fun get_message_content(message: &Message): String {
    message.message
}
