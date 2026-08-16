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

  post "kumiwake/draw",
     to: "kumiwake#draw",
     as: :kumiwake_draw
     
  post "kumiwake/continue_normal",
     to: "kumiwake#continue_normal",
     as: :kumiwake_continue_normal

  post "kumiwake/finish",
     to: "kumiwake#finish",
     as: :kumiwake_finish
     
  get 'home/index'

  get "up" => "rails/health#show",
      as: :rails_health_check

  root "home#index"
end