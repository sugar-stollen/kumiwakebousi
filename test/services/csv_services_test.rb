require 'test_helper'
require 'csv'
require 'tempfile'

class CsvServicesTest < ActiveSupport::TestCase
  test 'imports nonblank names from the Japanese name column' do
    file = Tempfile.new(['participants', '.csv'])
    file.write("名前,備考\n太郎,参加\n,欠席\n次郎,参加\n")
    file.close

    assert_equal %w[太郎 次郎], CsvImporter.new(file).call
  ensure
    file&.unlink
  end

  test 'exports group names and participant names as UTF-8 CSV with BOM' do
    groups = [[build(:participant, name: '太郎')], [build(:participant, name: '次郎')]]

    csv = CsvExporter.new(groups: groups, group_names: ['赤組']).call
    rows = CSV.parse(csv.delete_prefix("\uFEFF"), headers: true)

    assert csv.start_with?("\uFEFF")
    assert_equal [%w[赤組 太郎], %w[2組 次郎]], rows.map(&:fields)
  end
end
