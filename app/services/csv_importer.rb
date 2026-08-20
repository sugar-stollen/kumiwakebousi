require "csv"

class CsvImporter
  def initialize(file)
    @file = file
  end

  def call
    csv = CSV.read(@file.path, headers: true)

    csv.filter_map do |row|
      name = row["名前"] || row[0]
      name.presence
    end
  end
end