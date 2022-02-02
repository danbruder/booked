use std::convert::Infallible;

use scraper::{Html, Selector};
use serde::{Deserialize, Serialize};
use serde_json::json;
use urlencoding::encode;
use warp::Filter;

#[derive(Deserialize)]
struct SearchQuery {
    s: String,
}

#[tokio::main]
async fn main() {
    let index = warp::fs::file("assets/public/index.html");
    let assets = warp::fs::dir("assets/public");
    let api = warp::path!("api" / "search")
        .and(warp::query::<SearchQuery>())
        .and_then(search_route);

    println!("Running on 0.0.0.0:3030");
    warp::serve(api.or(assets).or(index))
        .run(([0, 0, 0, 0], 3030))
        .await;
}

async fn search_route(s: SearchQuery) -> Result<impl warp::Reply, Infallible> {
    // Now let's goooooo
    match do_search(s).await {
        Ok(result) => Ok(warp::reply::json(&result)),
        Err(err) => Ok(warp::reply::json(&json!({ "error": format!("{}", err) }))),
    }
}

#[derive(Debug, Serialize)]
struct SearchResult {
    image_url: String,
    url: String,
    title: String,
}

async fn do_search(SearchQuery { s }: SearchQuery) -> anyhow::Result<Vec<SearchResult>> {
    let encoded = encode(&s);
    let html = reqwest::get(format!("https://www.amazon.com/s?k={}", encoded))
        .await?
        .text()
        .await?;

    parse_doc(&html)
}

fn parse_doc(doc: &str) -> anyhow::Result<Vec<SearchResult>> {
    let sel_result = Selector::parse("[data-component-type=\"s-search-result\"]").unwrap();
    let sel_img = Selector::parse(".s-image").unwrap();
    let sel_title = Selector::parse("h2 > a > span").unwrap();
    let sel_url = Selector::parse("h2 a").unwrap();
    let document = Html::parse_document(doc);

    let results = document
        .select(&sel_result)
        .into_iter()
        .filter_map(|result| {
            let image_url = result.select(&sel_img).next().unwrap().value().attr("src");
            let url = result.select(&sel_url).next().unwrap().value().attr("href");
            let title = result
                .select(&sel_title)
                .next()
                .unwrap()
                .text()
                .collect::<Vec<_>>()
                .join("");
            match (image_url, url) {
                (Some(i), Some(u)) => Some(SearchResult {
                    image_url: i.to_string(),
                    url: format!("https://www.amazon.com{}", u),
                    title,
                }),
                _ => None,
            }
        })
        .collect::<Vec<_>>();

    Ok(results)
}
