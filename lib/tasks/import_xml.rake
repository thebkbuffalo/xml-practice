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

    # simple lil method to get data from xml node
    def get_data(node)
      return node&.children&.text&.strip
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
          # creating the filer organization first
          new_filer_organization = Organization.create(name: filer_name, ein: filer_ein, is_filer: true)
          # creating the filer orgs address
          new_filer_organization.addresses.create(
            address: filer_address_line_1,
            city: filer_city,
            state: filer_state,
            zip_code: filer_zipcode,
            country: "US"
          )
          filer_ein_numbers.push(filer_ein)
        end
        # here we check if the new filer exists or if we need to pull the filer based on their EIN
        current_org = if new_filer_organization.present?
          new_filer_organization
        else
          Organization.find_by(ein: filer_ein)
        end
        tax_year = return_header.search('taxyr').any? ? get_data(return_header.search('taxyr')) : get_data(return_header.search('taxyear'))
        # here we check to see if the filing org has a tax submission of the same year, 
        #if they don't we create a new filing, if they do we just return the filing from that year to use later.
        if !current_org.filings.collect(&:tax_period).include?(tax_year)
          new_filing = current_org.filings.create(tax_period: tax_year, xml_url: "https://www.instrumentl.com")
        else
          new_filing = current_org.filings.find_by(tax_period: tax_year)
        end
      rescue => error
        puts('filer creation' + error.message.to_s)
      end

      # receiver organization, their address, and award creation 
      awards_list = return_data.search('recipienttable')
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
            # now we create the receiver org
            new_organization = Organization.create(name: name, ein: recipient_ein, is_receiver: true)
            # next we create said orgs address
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
        # here we check for an existing new orgniazation, if one doesnt exist we find the relevant org by EIN
        if new_organization.present?
          new_org_id = new_organization.id
        else
          new_org_id = Organization.receiver_orgs.find_by(ein: recipient_ein).id
        end
        amount = award.search('amountofcashgrant').any? ? get_data(award.search('amountofcashgrant')) : get_data(award.search('cashgrantamt'))
        purpose = award.search('purposeofgrant').any? ? get_data(award.search('purposeofgrant')) : get_data(award.search('purposeofgranttxt'))
        irs_section = award.search('ircsection').any? ? get_data(award.search('ircsection')) : get_data(award.search('ircsectiondesc'))
        # here we create the award with the proper filing and org associations
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
    end
  end
end
