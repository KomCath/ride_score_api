class AddressVerificationHandlerService
  def initialize(address_params)
    @address_params = address_params.transform_values { |v| v.upcase.squish }
  end

  def call
    address = Address.where(@address_params).take

    if address
      handle_existing_address(address)
    else
      handle_new_address
    end
  end

  private

  def handle_existing_address(address)
    if address.is_verified?
      address.verified_address
    else
      {
        status: address.verification_status,
        message: address.verification_status_message,
        address_id: address.id
      }
    end
  end

  def handle_new_address
    @new_address = Address.new(@address_params)

    if @new_address.save
      address_verification_result = AddressVerificationService.new(address_verification_builder).verify_address
      process_address_verification_result(address_verification_result)
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

  def process_address_verification_result(address_verification_result)
    case address_verification_result[:status]
    when "ERROR"
      @new_address.update!(verification_status_message: address_verification_result[:message])
      @new_address.mark_unable_to_perform_verification!
      {
        status: @new_address.verification_status,
        message: @new_address.verification_status_message,
        address_id: @new_address.id
      }
    when "FIX", "CONFIRM"
      @new_address.update!(verification_status_message: address_verification_result[:message])
      @new_address.mark_verification_pending!
      { 
        status: @new_address.verification_status,
        message: @new_address.verification_status_message,
        address_id: @new_address.id
      }
    when "VERIFIED"
      @new_address.update!(address_verification_result[:verified_address_params])
      @new_address.mark_verification_successful!
      @new_address.verified_address
    end
  end
end
