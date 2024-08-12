class AddressVerificationHandlerService
  def initialize(address_params)
    @address_params = address_params
  end

  def call
    address = Address.find_by(@address_params)

    if address
      handle_existing_address(address)
    else
      handle_new_address
    end
  end

  private

  def handle_existing_address(address)
    if address.is_verified?
      address_lines_builder(address)
    else
      { status: address.verification_status, message: address.verification_status_message, address_id: address.id}
    end
  end

  def handle_new_address
    @new_address = Address.new(@address_params)

    if @new_address.save
      # binding.pry

      address_verification_result = AddressVerificationService.new(address_verification_builder).verify_address
      process_address_verification_result(@new_address, address_verification_result)
    else
      { status: :error, message: @new_address.errors.full_messages.to_sentence }
    end
  end

  def address_verification_builder
    {
      regionCode: @new_address.country,
      addressLines: [address_lines_builder(@new_address)]
    }.stringify_keys
  end

  def address_lines_builder(address)
    address_lines = [address.line1.strip]
    address_lines << address.line2.strip if address.line2.present?
    address_lines << address.city.strip
    address_lines << address.state.strip
    address_lines << address.zip_code.strip
    address_lines.join(" ")
  end

  def process_address_verification_result(address, address_verification_result)
    case address_verification_result[:status]
    when "ERROR"
      address.mark_unable_to_perform_verification!
      address_verification_result
    when "FIX", "CONFIRM"
      address.mark_verification_pending!
      address_verification_result.merge(address_id: address.id, address: address_lines_builder(address))
    when "VERIFIED"
      address.update!(address_verification_result[:verified_address_params])
      address.mark_verification_successful!
    end
  end
end
