module tip_jar_live::tip_jar_live;

use sui::coin::{Self, Coin};
use sui::sui::SUI;

public struct TipJar has key {
    id: UID,
    balance: u64,
    total_tips: u64,
    owner: address,
}

fun init(ctx: &mut TxContext) {
    let jar = TipJar {
        id: object::new(ctx),
        balance: 0,
        total_tips: 0,
        owner: ctx.sender(),
    };

    sui::transfer::share_object(jar);
}

public fun tip(jar: &mut TipJar, amount: Coin<SUI>) {
    jar.balance = jar.balance + coin::value(&amount);
    jar.total_tips = jar.total_tips + 1;

    sui::transfer::public_transfer(amount, jar.owner);
}
