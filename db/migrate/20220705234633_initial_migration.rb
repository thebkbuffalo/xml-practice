class InitialMigration < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :ein

      t.timestamps
      t.index :ein, unique: true
    end

    create_table :addresses do |t|
      t.references :organization, null: false

      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
    end

    create_table :filings do |t|
      t.references :organization, null: false

      t.string :tax_period, null: false
      t.string :xml_url, null: false, unique: true

      t.timestamps
    end
    add_index :filings, [:organization_id, :tax_period] #, unique: true

    create_table :awards do |t|
      t.references :filing, null: false
      t.references :receiver, class_name: "Organization", foreign_key: { to_table: :organizations }, null: false

      t.string :purpose
      t.string :irs_section
      t.bigint :cash_amount, null: false, default: 0
      t.bigint :non_cash_amount, null: false, default: 0

      t.timestamps
    end
  end
end
