Rails.application.routes.draw do
  # Utilise devise_for pour générer les routes de devise pour les utilisateurs
  devise_for :users

  # Définit la route racine ("/") vers le contrôleur pages#home
  root to: "pages#home"

  # Ajoute les routes pour les pages about et contact
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"

  # Définir la route pour les options
  get 'iqtests/:iqtest_id/questions/:question_id/options/new', to: 'options#new', as: 'iqtest_question_option_new'

  # Ajoute une route pour la suppression d'une option
  delete 'iqtests/:iqtest_id/questions/:question_id/options/:id', to: 'options#destroy', as: 'iqtest_question_option_destroy'

  # Ajoute les routes pour le CRUD de la ressource IqTest
  resources :iqtests do
    resources :questions, only: [:new, :edit, :create, :show] do
      resources :options, only: [:new, :create, :show, :edit, :update]
    end
  end

  resources :questions, only: [:destroy]
end
