use diesel::prelude::*;
use diesel::pg::PgConnection;
use anyhow::Result;
use crate::models::{NewPost, Post};
use crate::schema::posts;

pub fn create_post(conn: &mut PgConnection, title: &str, body: &str) -> Result<()> {
    let new_post = NewPost { title, body };

    diesel::insert_into(posts::table)
        .values(&new_post)
        .execute(conn)
        .expect("Error saving new post");
    Ok(())
}

pub fn show_posts(conn: &mut PgConnection) -> Vec<Post> {
    use crate::schema::posts::dsl::*;

    posts.filter(is_published.eq(true))
        .limit(5)
        .load::<Post>(conn)
        .expect("Error loading posts")
}

pub fn publish_post(conn: &mut PgConnection, id: i32) -> Post {
    use crate::schema::posts::dsl::{posts, is_published};

    diesel::update(posts.find(id))
        .set(is_published.eq(true))
        .get_result::<Post>(conn)
        .expect(&format!("Unable to find post {}", id))
}