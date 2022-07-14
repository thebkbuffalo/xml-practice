namespace :import_xml do
  desc "imports currenty existing xml docs"
  task batch_import: :environment do

    irs_forms = [
      'http://s3.amazonaws.com/irs-form-990/201132069349300318_public.xml',
      'http://s3.amazonaws.com/irs-form-990/201612429349300846_public.xml',
      'http://s3.amazonaws.com/irs-form-990/201521819349301247_public.xml',
      'http://s3.amazonaws.com/irs-form-990/201641949349301259_public.xml',
      'http://s3.amazonaws.com/irs-form-990/201921719349301032_public.xml',
      'http://s3.amazonaws.com/irs-form-990/201831309349303578_public.xml',
      'http://s3.amazonaws.com/irs-form-990/201823309349300127_public.xml',
      'http://s3.amazonaws.com/irs-form-990/201401839349300020_public.xml',
      'http://s3.amazonaws.com/irs-form-990/201522139349100402_public.xml',
      'http://s3.amazonaws.com/irs-form-990/201831359349101003_public.xml'
    ]

    def get_data(node)
      return node&.children&.text&.strip
    end

    def create_receiver_org_award_and_addy(award, filing_id)
      
    end
    
    # array of created filer ein numbers to check to make sure we're not trying to create duplicates
    filer_ein_numbers = []
    # array of created recipient eins for checking against current one in iteration so we don't attempt to create duplicates
    recpient_eins_list = []
    irs_forms.each do |form|
      doc = Nokogiri::HTML(URI.open(form))
      return_header = doc.root.search('returnheader')
      return_data = doc.root.search('returndata')
      # filer is the organization giving money. this should be created first in the process so the orgs receiving/awards/filings can be properly associated
      filer = return_header.search('filer')
      # below we're pulling out filer data to create the filing organization, their address, and the filing object.
      begin
        filer_ein = filer.search('ein').first.children.text
        # check to see if the filer already exists
        if !filer_ein_numbers.include?(filer_ein)
          filer_name = filer.search('businessnameline1').any? ? get_data(filer.search('businessnameline1')) : get_data(filer.search('businessnameline1txt'))
          filer_address_line_1 = filer.search('addressline1').any? ? get_data(filer.search('addressline1')) : get_data(filer.search('addressline1txt'))
          filer_city = filer.search('city').any? ? get_data(filer.search('city')) : get_data(filer.search('citynm'))
          filer_state = filer.search('state').any? ? get_data(filer.search('state')) : get_data(filer.search('stateabbreviationcd'))
          filer_zipcode = filer.search('zipcd').any? ? get_data(filer.search('zipcd')) : get_data(filer.search('zipcode'))
          new_filer_organization = Organization.create(name: filer_name, ein: filer_ein, is_filer: true)
          new_filer_organization.addresses.create(
            address: filer_address_line_1,
            city: filer_city,
            state: filer_state,
            zip_code: filer_zipcode,
            country: "US"
          )
          
          # new_filing = new_filer_organization.filings.create(tax_period: tax_year, xml_url: 'https://www.instrumentl.com')
          filer_ein_numbers.push(filer_ein)
        end
        tax_year = return_header.search('taxyr').any? ? get_data(return_header.search('taxyr')) : get_data(return_header.search('taxyear'))
        if new_filer_organization.present?
          new_filing = new_filer_organization.filings.create(tax_period: tax_year, xml_url: "https://www.instrumentl.com")
        else
          org = Organization.filer_orgs.find_by(ein: filer_ein)
          new_filing = org.filings.create(tax_period: tax_year, xml_url: 'https://www.instrumentl.com')
        end
      rescue => error
        puts('filer creation' + error.message.to_s)
      end

      # receiver organization, their address, and award creation 
      awards_list = return_data.search('recipienttable')
      puts(new_filing.id)
      awards_list.each do |award|
        begin
          recipient_ein = award.search('einofrecipient').any? ? get_data(award.search('einofrecipient')) : get_data(award.search('recipientein'))
          # check to see if recipient already exists
          if !recpient_eins_list.include?(recipient_ein)
            name = award.search('businessnameline1').any? ? get_data(award.search('businessnameline1')) : get_data(award.search('businessnameline1txt'))
            address_line_1 = award.search('addressline1').any? ? get_data(award.search('addressline1')) : get_data(award.search('addressline1txt'))
            city = award.search('city').any? ? get_data(award.search('city')) : get_data(award.search('citynm'))
            state = award.search('state').any? ? get_data(award.search('state')) : get_data(award.search('stateabbreviationcd'))
            zip = award.search('zipcode').any? ? get_data(award.search('zipcode')) : get_data(award.search('zipcd'))
            new_organization = Organization.create(name: name, ein: recipient_ein, is_receiver: true)
            new_organization.addresses.create(
              address: address_line_1,
              city: city,
              state: state,
              zip_code: zip,
              country: 'US'
            )
            recpient_eins_list.push(recipient_ein)
          end
        rescue => error
          puts('new rec org --- ' + error.message.to_s)
        end
        if new_organization.present?
          new_org_id = new_organization.id
        else
          new_org_id = Organization.receiver_orgs.find_by(ein: recipient_ein).id
        end
        amount = award.search('amountofcashgrant').any? ? get_data(award.search('amountofcashgrant')) : get_data(award.search('cashgrantamt'))
        purpose = award.search('purposeofgrant').any? ? get_data(award.search('purposeofgrant')) : get_data(award.search('purposeofgranttxt'))
        irs_section = award.search('ircsection').any? ? get_data(award.search('ircsection')) : get_data(award.search('ircsectiondesc'))
        begin
          Award.create(
            filing_id: new_filing.id,
            receiver_id: new_org_id,
            purpose: purpose,
            irs_section: irs_section,
            cash_amount: amount,
            non_cash_amount: 0.00,
          )
        rescue => error
          puts('award error --- ' + error.message.to_s)
        end
      end


      # puts('----------')
      # puts(tax_year)
      # puts(filer_ein)
      # puts(filer_name)
      # puts(filer_address_line_1)
      # puts(filer_city)
      # puts(filer_state)
      # puts(filer_zipcode)
      # puts('------------')

    end
  end

end
