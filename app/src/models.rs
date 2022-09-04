use serde::{Serialize, Deserialize};
use crate::schema::posts;
use diesel::prelude::*;

#[derive(Debug, Serialize, Deserialize, Queryable)]
pub struct Post {
   pub id: i32,
   pub title: String,
   pub body: String,
   pub is_published: bool,
}

#[derive(Insertable)]
#[diesel(table_name = posts)]
pub struct NewPost<'a> {
   pub title: &'a str,
   pub body: &'a str,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RequestPost {
   pub title: String,
   pub body: String,
}