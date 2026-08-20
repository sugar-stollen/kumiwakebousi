Rails.application.routes.draw do
  get '/kumiwake', to: 'kumiwake#index'

  get "kumiwake/input",
      to: "kumiwake#input",
      as: :kumiwake_input

  post "kumiwake/save_names",
       to: "kumiwake#save_names",
       as: :kumiwake_save_names

  post "kumiwake/reset_history", 
       to: "kumiwake#reset_history"

  get "kumiwake/group_names",
      to: "kumiwake#group_names",
      as: :kumiwake_group_names

  post "kumiwake/save_group_names",
       to: "kumiwake#save_group_names",
       as: :kumiwake_save_group_names

  get "kumiwake/result",
      to: "kumiwake#result",
      as: :kumiwake_result

  get "kumiwake/history",
      to: "kumiwake#history",
      as: :kumiwake_history

  post "kumiwake/draw",
     to: "kumiwake#draw",
     as: :kumiwake_draw
     
  post "kumiwake/continue_normal",
     to: "kumiwake#continue_normal",
     as: :kumiwake_continue_normal

  post "kumiwake/finish",
     to: "kumiwake#finish",
     as: :kumiwake_finish
     
  get 'kumiwake/finish', 
    to: 'kumiwake#finish'

  get 'home/index'

  get "up" => "rails/health#show",
      as: :rails_health_check

  root "home#index"

  post "csv/import", 
    to: "csv#import", 
    as: :csv_import

    get "csv/export",
        to: "csv#export",
        as: :csv_export

end