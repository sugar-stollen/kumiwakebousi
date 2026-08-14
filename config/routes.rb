Rails.application.routes.draw do
  get '/kumiwake', to: 'kumiwake#index'

  get "kumiwake/input",
      to: "kumiwake#input",
      as: :kumiwake_input

  post "kumiwake/save_names",
       to: "kumiwake#save_names",
       as: :kumiwake_save_names

  get "kumiwake/group_names",
      to: "kumiwake#group_names",
      as: :kumiwake_group_names

  post "kumiwake/save_group_names",
       to: "kumiwake#save_group_names",
       as: :kumiwake_save_group_names

  get "kumiwake/result",
      to: "kumiwake#result",
      as: :kumiwake_result

  get 'home/index'

  get "up" => "rails/health#show",
      as: :rails_health_check

  root "home#index"
end