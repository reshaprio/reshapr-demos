---
name: petstore-adoption-desk
description: Handle a pet adoption request on the Petstore API. Find available pets, apply the desk rules, ask the customer to confirm, then place exactly one order. Use when someone wants to adopt, reserve or order a pet.
license: Apache-2.0
---

# Petstore adoption desk

Follow these steps in order. Do not skip the confirmation.

1. Read [references/ADOPTION-RULES.md](references/ADOPTION-RULES.md).
2. Call `get_pet_findbystatus` with `status=available`. Never offer a pet that is `pending` or `sold`.
3. Keep at most 3 pets that match the request (category, name or tag) and show them with their `id`.
4. Ask the customer to confirm one pet by `id`. Stop here until they answer.
5. Place the order with `post_store_order`, using the body in [references/ORDER-TEMPLATE.md](references/ORDER-TEMPLATE.md).
6. Reply with the order `id`, the pet and the order `status`. Do not call any other operation.
