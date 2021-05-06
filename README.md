# YaMDS

This is a test project for Yandex Mobile Development School 2021.

The App dislays stock market data about company including current price, basic financials and logo.

# Table of Contents
1. [Features](#Features)
2. [API](#API)
3. [Used Libraries](#Used-3rd-party-Libs)

# Features

### Basic
- `Search` through tickers and company names

<img src="Screenshots/search_1.PNG" alt="search_1" width="250"/>  <img src="Screenshots/search_2.PNG" alt="search_2" width="250"/>

- List of `Favourite` companies

<img src="Screenshots/favourites.PNG" alt="favourites" width="250"/>

### Additional
- `Detail View` with several financials for chosen company

<img src="Screenshots/detail.PNG" alt="detail" width="250"/>

- `Light/Dark appearance` inheriting from device theme

<img src="Screenshots/stocks.PNG" alt="light" width="250"/>  <img src="Screenshots/stocks_dark.PNG" alt="dark" width="250"/>

- `Alert notification` on errors (including connection loss and API requests limit)

<img src="Screenshots/alert.PNG" alt="alert" width="250"/>

- Stock price `live updates` via WebSockets

- `Caching` company cards in memory with CoreData

- Simple `animation` for favourite buttons

# API
### Stock data obtained from [Finnhub Stock API](https://finnhub.io/docs/api).
Used requests:
- [Company Profile 2](https://finnhub.io/docs/api/company-profile2)
- [Basic Financials](https://finnhub.io/docs/api/company-basic-financials)
- [Quote](https://finnhub.io/docs/api/quote)

### Source of company logos:
- Link from Finnhub response
- [UpLead](https://docs.uplead.com/#company-logo-api)

### ~~Company summary block for Detail View~~ (not activated in final build)
- [MBOUM API](https://mboum.com/api/documentation#profile)

# Used 3rd party Libs
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [Starscream](https://github.com/daltoniam/Starscream)
