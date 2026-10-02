# frozen_string_literal: true

class CsvController < ApplicationController
  include KumiwakeSessionState

  def export
    groups = restore_groups(session[:current_groups] || latest_past_groups)
    return redirect_to kumiwake_path, alert: '組み分け結果がありません' if groups.blank?

    send_csv(groups)
  end

  def import
    return redirect_to_input_with_alert if params[:file].blank?

    roster = ParticipantRoster.new(CsvImporter.new(params[:file]).call)
    return redirect_to kumiwake_input_path unless roster.valid?

    store_roster(roster)
    redirect_to kumiwake_path
  end

  private

  def send_csv(groups)
    csv = CsvExporter.new(
      groups: groups,
      group_names: session[:group_names] || []
    ).call

    send_data csv,
              filename: 'kumiwake.csv',
              type: 'text/csv; charset=utf-8',
              disposition: 'attachment'
  end

  def redirect_to_input_with_alert
    redirect_to kumiwake_input_path, alert: 'CSVファイルを選択してください'
  end

  def store_roster(roster)
    session[:names] = roster.to_session
    clear_round_state
    session[:from_name_input] = true
  end

  def latest_past_groups
    result = Array(session[:past_results]).compact.last
    result&.dig('groups') || result&.dig(:groups)
  end
end
