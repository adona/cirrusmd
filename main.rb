require 'csv'
require_relative 'patient'

def read_data(fname)
  data = CSV.parse(
    File.read(fname),
    headers: true,
    header_converters: lambda { |h| h.strip.gsub(/[\u200B-\u200D\uFEFF]/, '') }
  )
  data.map(&:to_h)
end

def preprocess_data(raw_data)
  data = []
  for entry in raw_data do
    patient = Patient.new(entry)
    patient.clean
    patient.data["valid"] = patient.valid?
    data << patient.data
  end
  data
end

def save_data(data, fname)
  CSV.open(fname, "w") do |csv|
    csv << data.first.keys
    for row in data do
      csv << row.values
    end
  end

end

def generate_and_save_report(data, fname_input, fname_output, fname_report)
  n_patients = data.size
  n_valid_patients = data.filter{|patient| patient["valid"]}.size
  n_invalid_patients = n_patients - n_valid_patients

  File.open(fname_report, "w") do |file|
    file.puts "Data pre-processed successfully at " + Time.now.strftime("%d/%m/%Y %H:%M")
    file.puts "Input file: #{fname_input}"
    file.puts "Output file: #{fname_output}"
    file.puts "Report file: #{fname_output}"
    file.puts "Total patients: #{n_patients}"
    file.puts "Valid patients: #{n_valid_patients}"
    file.puts "Invalid patients: #{n_invalid_patients}"
  end
end


fname_input = "data/input.csv"
fname_output = "data/output.csv"
fname_report = "data/report.txt"

raw_data = read_data(fname_input)
data = preprocess_data(raw_data)
save_data(data, fname_output)
generate_and_save_report(data, fname_input, fname_output, fname_report)
