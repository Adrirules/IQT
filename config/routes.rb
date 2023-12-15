Rails.application.routes.draw do
  get 'questions/new'
  # Utilise devise_for pour générer les routes de devise pour les utilisateurs
  devise_for :users

  # Définit la route racine ("/") vers le contrôleur pages#home
  root to: "pages#home"

  # Ajoute les routes pour les pages about et contact
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"

  # Ajoute les routes pour le CRUD de la ressource IqTest
  resources :iqtests do
    resources :questions, only: [:new, :edit, :create]
  end
  resources :questions, only: [:destroy]
end

