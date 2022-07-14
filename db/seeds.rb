# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
organization = Organization.create(name: "Gabe's Org", ein: "123412345", is_filer: true)
Address.create(organization: organization, address: "123 1ST ST", city: "OAKLAND", state: "CA", country: "US", zip_code: "94611")
filing = Filing.create(organization: organization, tax_period: "20201001", xml_url: "https://www.instrumentl.com")
receiver = Organization.create(name: "Receiver", is_receiver: true)
award = Award.create(filing: filing, receiver: receiver, cash_amount: 1234567, purpose: "For Fun")
