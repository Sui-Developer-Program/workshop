module guestbook_contract::guestbook_contract;

use std::string::{Self, String};
use sui::coin::Coin;
use sui::sui::SUI;

const MAX_LENGTH: u64 = 100;

const EInvalidLength: u64 = 1;

public struct Message has store {
    sender: address,
    content: String,
}

public struct GuestBook has key, store {
    id: UID,
    messages: vector<Message>,
    number_of_messages: u64,
}

fun init(ctx: &mut TxContext) {
    let guestbook = GuestBook {
        id: object::new(ctx),
        messages: vector::empty<Message>(),
        number_of_messages: 0,
    };

    sui::transfer::share_object(guestbook);
}

public fun post_message(guestbook: &mut GuestBook, message: Message, ctx: &mut TxContext) {
    let length = string::length(&message.content);
    assert!(length > 0 && length <= MAX_LENGTH, EInvalidLength);

    vector::push_back(&mut guestbook.messages, message);
    guestbook.number_of_messages = guestbook.number_of_messages + 1;
}

public fun create_message(message: vector<u8>, ctx: &mut TxContext): Message {
    let message_string = string::utf8(message);
    let length = string::length(&message_string);
    assert!(length > 0 && length <= MAX_LENGTH, EInvalidLength);

    Message {
        sender: ctx.sender(),
        content: string::utf8(message),
    }
}
