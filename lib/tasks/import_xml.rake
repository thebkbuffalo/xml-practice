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

    def create_receiver_org_award_and_addy(award)
      # binding.pry
    end
    
    # array of created filer ein numbers to check to make sure we're not trying to create the same organization
    filer_ein_numbers = []
    irs_forms.each do |form|
      doc = Nokogiri::HTML(URI.open(form))
      return_header = doc.root.search('returnheader')
      return_data = doc.root.search('returndata')
      # filer is the organization giving money. this should be created first in the process so the orgs receiving/awards/filings can be properly associated
      filer = return_header.search('filer')
      begin
        filer_ein = filer.search('ein').first.children.text
        if !filer_ein_numbers.include?(filer_ein)
           # gets filer name from either businessnameline1 or businessnameline1txt
          filer_name = filer.search('businessnameline1').any? ? get_data(filer.search('businessnameline1')) : get_data(filer.search('businessnameline1txt'))
          # gets address based on usaddress or addressus
          filer_address = filer.search('usaddress').any? ? filer.search('usaddress') : filer.search('addressus')
          # gets first line of address based on AddressLine1 or AddressLine1Txt
          filer_address_line_1 = filer_address.search('addressline1').any? ? 
            get_data(filer_address.search('addressline1')) : get_data(filer_address.search('addressline1txt'))
          # gets filer city based on City or CityNm
          filer_city = filer_address.search('city').any? ? get_data(filer_address.search('city')) : get_data(filer_address.search('citynm'))
          # gets filer state based on State or StateAbbreviationCd
          filer_state = filer_address.search('state').any? ? get_data(filer_address.search('state')) : get_data(filer_address.search('stateabbreviationcd'))
          # gets filer zipcode based on ZIPcode or ZIPCd
          filer_zipcode = filer_address.search('zipcd').any? ? get_data(filer_address.search('zipcd')) : get_data(filer_address.search('zipcode'))
          new_filer_organization = Organization.create(name: filer_name, ein: filer_ein)
          new_filer_organization.addresses.create(
            address: filer_address_line_1,
            city: filer_city,
            state: filer_state,
            zip_code: filer_zipcode,
            country: "US"
          )
          filer_ein_numbers.push(filer_ein)
          tax_year = return_header.search('taxyr').any? ? get_data(return_header.search('taxyr')) : get_data(return_header.search('taxyear'))
          if new_filer_organization.present?
            new_filer_organization.filings.create(tax_period: tax_year, xml_url: "https://www.instrumentl.com")
          else
            org = Organization.find_by(ein: filer_ein)
            org.filings.create(tax_period: tax_year, xml_url: 'https://www.instrumentl.com')
          end

        end

      rescue => error
        puts(error)
      end

      awards_list = return_data.search('recipienttable')
      awards_list.each do |award|
        begin
          create_receiver_org_award_and_addy(award)
        rescue
          puts("something went wrong")
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
