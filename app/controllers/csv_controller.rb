class CsvController < ApplicationController
  def export
    groups = restore_groups(session[:current_groups] || latest_past_groups)

    if groups.blank?
      redirect_to kumiwake_path, alert: "組み分け結果がありません"
      return
    end

    csv = CsvExporter.new(
      groups: groups,
      group_names: session[:group_names] || []
    ).call

    send_data csv,
              filename: "kumiwake.csv",
              type: "text/csv; charset=utf-8",
              disposition: "attachment"
  end

  def import
    file = params[:file]

    if file.blank?
      redirect_to kumiwake_input_path, alert: "CSVファイルを選択してください"
      return
    end

    names = CsvImporter.new(file).call

    if names.empty?
      redirect_to kumiwake_input_path, alert: "名前が見つかりませんでした"
      return
    end

    session[:names] = names.each_with_index.map do |name, index|
      {
        "id" => index + 1,
        "name" => name
      }
    end

    clear_round_state
    session[:from_name_input] = true

    redirect_to kumiwake_path
  end

  private

  def latest_past_groups
    result = Array(session[:past_results]).compact.last
    result&.dig("groups") || result&.dig(:groups)
  end

  def restore_groups(groups)
    return nil if groups.nil?

    members_by_id = Array(session[:names]).each_with_object({}) do |member, members|
      id = member["id"] || member[:id]
      members[id.to_i] = member
    end

    Array(groups).map do |group|
      Array(group).filter_map do |member|
        if member.is_a?(Hash)
          member
        else
          members_by_id[member.to_i]
        end
      end
    end
  end

  def clear_round_state
    session.delete(:group_history)
    session.delete(:current_groups)
    session.delete(:draw_count)
    session.delete(:round_number)
    session.delete(:past_results)
    session.delete(:kumiwake_limit_reached)
    session.delete(:magic_mode)
    session.delete(:_switch_complete)
  end
end