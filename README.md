invoiced-ruby
========

This repository contains the Ruby client library for the [Invoiced](https://invoiced.com) API.

## Installing

The Invoiced gem can be installed liked this:

```
gem install invoiced
```

It can be added to your Gemfile:

```
source 'https://rubygems.org'

gem 'invoiced'
```

## Requirements

- >= Ruby 1.9.3
- rest_client, json, and active_support gems

## Usage

First, you must instantiate a new client

```ruby
require 'invoiced'

invoiced = Invoiced::Client.new("{API_KEY}")
```

Then, API calls can be made like this:
```ruby
invoice = invoiced.Invoice.retrieve("{INVOICE_ID}")

transaction = invoiced.Transaction.create(:invoice => invoice.id, :amount => invoice.balance, :method => "check")
```

## Developing

The gem can be built with:

```
gem build invoiced.gemspec
```

The test suite can be ran with `rake test`