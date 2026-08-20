require "csv"

class CsvExporter
	def initialize(groups:, group_names:)
		@groups = groups
		@group_names = group_names
	end

	def call
		bom = "\uFEFF"

    bom + CSV.generate do |csv|
      
			csv << ["組", "名前"]

			@groups.each_with_index do |group, index|
				group_name = @group_names[index].presence || "#{index + 1}組"

				group.each do |member|
					csv << [group_name, member["name"] || member[:name]]
				end
			end
		end
	end
end
