class AddressVerificationBuilder

  def self.build(address)
    new(address).build
  end

  def initialize(address)
    raise ArgumentError, "Address cannot be nil" if address.nil?
    raise ArgumentError, "Expected an Address object" unless address.is_a?(Address)
    @address = address
  end

  def build
    {
      regionCode: @address.country,
      addressLines: [format_address_lines],
      locality: @address.city,
      administrativeArea: @address.state,
      postalCode: @address.zip_code
    }.stringify_keys
  end

  private

  def format_address_lines
    address_lines = [@address.line1.strip]
    address_lines << @address.line2.strip if @address.line2.present?
    address_lines.join(" ")
  end
end
