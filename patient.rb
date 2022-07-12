require 'date'

class Patient
  attr_accessor :raw_data, :data

  def initialize(raw_data)
    @raw_data = raw_data
    @data = raw_data
  end

  def clean
    trim_whitespace
    transform_phone_number
    transform_all_date_fields
  end

  def valid?
    validate_required_fields &&
      validate_phone_number
  end

  ### TRANSFORMS

  def trim_whitespace
    data.each do |k, v|
      data[k] = v && v.strip
    end
  end

  def transform_phone_number
    # Convert to E.164 format
    phone = data["phone_number"]
    return unless phone

    phone = phone.gsub(/[^0-9]/i, "")
    if phone.length == 10
      phone = "+1" + phone
    elsif phone.length == 11 && phone[0] == "1"
      phone = "+" + phone
    end
    data["phone_number"] = phone
  end

  DATE_FORMATS = {
    "%m/%d/%y" => /\A\d{1,2}\/\d{1,2}\/\d{1,2}\z/,
    "%m/%d/%Y" => /\A\d{1,2}\/\d{1,2}\/\d{4}\z/,
    "%m-%d-%y" => /\A\d{1,2}-\d{1,2}-\d{1,2}\z/,
    "%m-%d-%Y" => /\A\d{1,2}-\d{1,2}-\d{4}\z/,
    "%Y-%m-%d" => /\A\d{4}-\d{1,2}-\d{1,2}\z/
  }

  def transform_date(date)
    # Convert to ISO8601 format (YYYY-MM-DD)
    return unless date

    parsed = nil
    DATE_FORMATS.each do |format, regex|
      begin
        if date.match(regex)
          # NOTE: We first do a regex match here to address the following default Date.strptime behavior:
          # Date.strptime("01/02/1920", "%m/%d/%y") is incorrectly parsed as "2019-01-02", instead of recognizing this is
          # not a 2-digit year, and moving on to the next format to correctly parse it as "1920-01-02"
          # Similarly, Date.strptime("01/02/19", "%m/%d/%Y") is incorrectly parsed as "0019-01-02", instead of recognizing
          # this is not a 4-digit year, and using the alternative format to correctly parse it as "2019-01-02"
          # TODO: Revisit and see if there's a more elegant solution.
          parsed = Date.strptime(date, format)
          break
        end
      rescue ArgumentError
      end
    end

    parsed.iso8601
  end

  DATE_FIELDS = ["dob", "effective_date", "expiry_date"]

  def transform_all_date_fields
    DATE_FIELDS.each do |field|
      data[field] = transform_date(data[field])
    end
  end

  # VALIDATIONS

  REQUIRED_FIELDS = ["first_name", "last_name", "dob", "member_id", "effective_date"]

  def validate_required_fields
    !data.values_at(*REQUIRED_FIELDS).include?(nil)
  end

  def validate_phone_number
    phone = data["phone_number"]
    phone.nil? || (phone.length == 12 && phone[0..1] == "+1" && !phone[2..].match(/\d{10}/).nil?)
  end

end
