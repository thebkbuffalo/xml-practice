# README

## Installation

`bundle install`

## Prepare DB

`rake db:migrate; rake db:seed`

## Running the server

`rails s`

## Endpoints

### Organizations List

`curl 'http://localhost:3000/api/organizations.json'`

### Organization By ID

`curl 'http://localhost:3000/api/organizations/1.json'`

### Organization Filings

`curl 'http://localhost:3000/api/organizations/1/filings.json'`

### Organization Filings by ID

`curl 'http://localhost:3000/api/organizations/1/filings/1.json'`

### Awards by Filing

`curl 'http://localhost:3000/api/organizations/1/filings/1/awards.json'`

### Award by ID

`curl 'http://localhost:3000/api/organizations/1/filings/1/awards/1.json'`

### Organization Addresses

`curl 'http://localhost:3000/api/organizations/1/addresses.json'`

### Organization Address by ID

`curl 'http://localhost:3000/api/organizations/1/addresses/1.json'`

### Total time: 12 hours

## Background Information

Every year, US Nonprofit organizations submit tax returns to the IRS. The returns are converted into XML and made available by the IRS. These tax returns contain information about the nonprofit’s giving and/or receiving for the tax period. For this coding challenge, we will focus on the nonprofit’s attributes and the awards that they gave or received in a particular tax year.

## Key Definitions

- Filers are nonprofit organizations that submit tax return data to the IRS.
- Awards are grants given by the filer to nonprofit organizations in a given year.
- Recipients are nonprofit organizations who have received awards given by a filer.
- Filings are the individual tax returns submitted by filers to the IRS for a given tax period. A filing contains awards given by the filer to recipients.

Example: “The filer’s 2015 filing declares that they gave 18 awards to 12 different recipients totalling $118k in giving”

## Backend Requirements

**Build a Rails web application that parses IRS XML and stores data into a database**

- Parse and store ein, name, address, city, state, zip code info for both filers and recipients
- Parse and store award attributes, such as purpose, cash amount, and tax period.
- Generate/extend the API to access the data. This API should support
  - Serialized filers
  - Serialized filings by filer
  - Serialized awards by filing
  - Serialized recipients
- Consider additional request parameters by endpoint (e.g. filter recipients by filing, filter recipients by state, filter recipients by cash amount, etc).
- Be sure to read the [Frontend Requirements](#frontend-requirements) when building and extending the API!
- Bonus points for deploying to Heroku

## Filing Urls

- http://s3.amazonaws.com/irs-form-990/201132069349300318_public.xml
- http://s3.amazonaws.com/irs-form-990/201612429349300846_public.xml
- http://s3.amazonaws.com/irs-form-990/201521819349301247_public.xml
- http://s3.amazonaws.com/irs-form-990/201641949349301259_public.xml
- http://s3.amazonaws.com/irs-form-990/201921719349301032_public.xml
- http://s3.amazonaws.com/irs-form-990/201831309349303578_public.xml
- http://s3.amazonaws.com/irs-form-990/201823309349300127_public.xml
- http://s3.amazonaws.com/irs-form-990/201401839349300020_public.xml
- http://s3.amazonaws.com/irs-form-990/201522139349100402_public.xml
- http://s3.amazonaws.com/irs-form-990/201831359349101003_public.xml

## Paths and Keys in XMLs for Related Data\*

- Filing Path: `Return/ReturnHeader`
  - Tax Period: `{TaxYear,TaxYr}`
- Filer Path: `Return/ReturnHeader/Filer`
  - EIN: `EIN`
  - Name: `{Name,BusinessName}/{BusinessNameLine1,BusinessNameLine1Txt}`
  - Address: `{USAddress,AddressUS}`
  - Line 1: `{AddressLine1,AddressLine1Txt}`
  - City: `{City,CityNm}`
  - State: `{State,StateAbbreviationCd}`
  - Zip: `{ZIPCode,ZIPCd}`
- Award List Path: `Return/ReturnData/IRS990ScheduleI/RecipientTable`

  - EIN: `{EINOfRecipient,RecipientEIN}`
  - Recipient Name: `{RecipientNameBusiness,RecipientBusinessName}/{BusinessNameLine1,BusinessNameLine1Txt}`
  - Recipient Address: `{USAddress,AddressUS}`
    - Line 1: `{AddressLine1,AddressLine1Txt}`
    - City: `{City,CityNm}`
    - State: `{State,StateAbbreviationCd}`
    - Zip: `{ZIPCode,ZIPCd}`
  - Award Amount: `{AmountOfCashGrant,CashGrantAmt}`

\* Paths may vary by schema version

## Frontend Requirements

Go ahead and show off a little bit! Build something great that utilizes the API. Build a UI that enables the user to explore the historical awards of a filer. What information is relevant? How should they navigate the data? Obviously, you don’t have infinite time, so feel free to stub out functionality or leave comments for things you didn’t get to finish. We understand!

The only requirements for the frontend are that you leverage your new API in Javascript (please, no Backbone.js).

## How to deliver your code

Please fork this repo into a private Github repository and share access with the following Github accounts.

@eyupatis
@gsinkin-instrumentl
@furkan-instrumentl
@hope-instrumentl
@instrumentl707

## Questions or Issues

Please don’t hesitate to contact engineering@instrumentl.com
