Rails.application.routes.draw do
  root 'lol#home'
  get "week", to: "lol#week"
end
