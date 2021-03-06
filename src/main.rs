use tide::log;
use tide::prelude::*;
use tide::Request;

#[derive(Debug, Deserialize)]
struct Animal {
    name: String,
    legs: u8,
}

#[async_std::main]
async fn main() -> tide::Result<()> {
    log::start();
    log::info!("Starting...");

    let mut app = tide::new();

    app.at("/orders/shoes").post(order_shoes);
    app.listen("127.0.0.1:8080").await?;
    Ok(())
}

async fn order_shoes(mut req: Request<()>) -> tide::Result {
    let Animal { name, legs } = req.body_json().await?;
    log::info!("Animal is {}", name);
    Ok(format!("Hello, {}! I've put in an order for {} shoes", name, legs).into())
}
