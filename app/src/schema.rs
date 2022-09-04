// @generated automatically by Diesel CLI.

diesel::table! {
    posts (id) {
        id -> Int4,
        title -> Text,
        body -> Text,
        is_published -> Bool,
    }
}
