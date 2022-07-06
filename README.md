# README

## Installation

`bundle install`

## Prepare DB

`rake db:migrate; rake db:seed`

## Running the server

`rails s`

## Endpoints

`curl --header 'Accept: application/json' 'http://localhost:3003/api/organizations' | jq`
`curl --header 'Accept: application/json' 'http://localhost:3003/api/organizations/1' | jq`
`curl --header 'Accept: application/json' 'http://localhost:3003/api/organizations/1/filings' | jq`
`curl --header 'Accept: application/json' 'http://localhost:3003/api/organizations/1/filings/1' | jq`
`curl --header 'Accept: application/json' 'http://localhost:3003/api/organizations/1/filings/1/awards' | jq`
`curl --header 'Accept: application/json' 'http://localhost:3003/api/organizations/1/filings/1/awards/1' | jq`
`curl --header 'Accept: application/json' 'http://localhost:3003/api/organizations/1/addresses' | jq`
`curl --header 'Accept: application/json' 'http://localhost:3003/api/organizations/1/addresses/1' | jq`
