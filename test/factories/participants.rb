FactoryBot.define do
  factory :participant, class: Hash do
    sequence(:id) { |number| number }
    sequence(:name) { |number| "参加者#{number}" }

    initialize_with { { 'id' => id, 'name' => name } }
  end
end
