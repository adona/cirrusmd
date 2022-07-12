require_relative '../patient'
require 'pry'

RSpec.describe Patient do
  let(:patient) {
    Patient.new({
      "first_name" => " Brent ",
      "last_name" => "Wilson  ",
      "dob" => " 1/1/1988 ",
      "member_id" => "  349090 ",
      "effective_date" => " 9/30/19 ",
      "expiry_date" => " 9-30-2020 ",
      "phone_number" => "  (303) 887 3456 "
    })
  }

  #### Test individual transforms and validators

  context "#trim_whitespace" do
    it "trims whitespaces from each Patient data field" do
      patient.trim_whitespace
      expect(patient.data["first_name"]).to eq("Brent")
      expect(patient.data["last_name"]).to eq("Wilson")
      expect(patient.data["dob"]).to eq("1/1/1988")
      expect(patient.data["member_id"]).to eq("349090")
      expect(patient.data["effective_date"]).to eq("9/30/19")
      expect(patient.data["expiry_date"]).to eq("9-30-2020")
      expect(patient.data["phone_number"]).to eq("(303) 887 3456")
    end

    it "ignores missing values" do
      patient.data["phone_number"] = nil
      patient.trim_whitespace
      expect(patient.data["phone_number"]).to be nil
    end
  end

  context "#transform_phone_number" do
    it "removes non-numeric phone # delimiters such as (, -" do
      patient.transform_phone_number
      expect(patient.data["phone_number"]).to eq("+13038873456")
    end

    it "for 10 digit numbers, adds the country code (+1)" do
      patient.data["phone_number"] = "3038873456"
      patient.transform_phone_number
      expect(patient.data["phone_number"]).to eq("+13038873456")
    end

    it "for 11 digit numbers, where the first digit is 1, adds the + to signify country code" do
      patient.data["phone_number"] = "13038873456"
      patient.transform_phone_number
      expect(patient.data["phone_number"]).to eq("+13038873456")
    end

    it "for 11 digit numbers, where the first digit is NOT 1, does not add the + to signify country code" do
      patient.data["phone_number"] = "23038873456"
      patient.transform_phone_number
      expect(patient.data["phone_number"]).to eq("23038873456")
    end

    it "for phone numbers with lengths other than 10 or 11, returns the number without adding the country code" do
      patient.data["phone_number"] = "(303) 887 345"
      patient.transform_phone_number
      expect(patient.data["phone_number"]).to eq("303887345")
    end

    it "ignores missing values" do
      patient.data["phone_number"] = nil
      patient.transform_phone_number
      expect(patient.data["phone_number"]).to be nil
    end
  end

  context "#transform_date" do
    # TODO
  end

  context "#validate_required_fields" do
    it "returns true if all the required fields (first_name, last_name, dob, member_id, effective_date) are present" do
      expect(patient.validate_required_fields).to be true
    end

    it "returns true even if a non-required field is missing" do
      patient.data["phone_number"] = nil
      expect(patient.validate_required_fields).to be true
    end

    it "returns false if any of the required fields are missing" do
      patient.data["dob"] = nil
      expect(patient.validate_required_fields).to be false
    end
  end

  context "#validate_phone_number" do
    it "returns true for 12 digit phone #s starting with the +1 country code" do
      patient.data["phone_number"] = "+13038873456"
      expect(patient.validate_phone_number).to be true
    end

    it "returns false for phone #s of lengths other than 12" do
      patient.data["phone_number"] = "+1303887345"
      expect(patient.validate_phone_number).to be false
    end

    it "returns false for phone #s which do not start with the +1 country code" do
      patient.data["phone_number"] = "3038873456"
      expect(patient.validate_phone_number).to be false
    end

    it "returns false for phone #s which contain other delimiters" do
      patient.data["phone_number"] = "+1(303)88734"
      expect(patient.validate_phone_number).to be false
    end
  end

  ### Test the "integration" #clean and #valid? methods
  context "#clean" do
    it "trims whitespace" do
      patient.clean
      expect(patient.data["last_name"]).to eq("Wilson")
    end

    it "transforms phone # to E.164 format" do
      patient.clean
      expect(patient.data["phone_number"]).to eq("+13038873456")
    end

    it "converts all date fields to ISO8601 format (YYYY-MM-DD)" do
      patient.clean
      expect(patient.data["dob"]).to eq("1988-01-01")
      expect(patient.data["effective_date"]).to eq("2019-09-30")
      expect(patient.data["expiry_date"]).to eq("2020-09-30")
    end
  end

  context "#valid?" do
    # TODO
  end
end
