Rails.application.routes.draw do
  # Utilise devise_for pour générer les routes de devise pour les utilisateurs
  devise_for :users

  # Définit la route racine ("/") vers le contrôleur pages#home
  root to: "pages#home"

  # Ajoute les routes pour les pages about et contact
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
# Ajoutez une route pour la collecte des réponses
  post '/collect_responses', to: 'user_test_scores#collect_responses', as: 'collect_responses'
# Routes pour le CRUD de la ressource UserTestScore
  resources :user_test_scores, only: [:create]

  # Définir la route pour les options
  get 'iqtests/:iqtest_id/questions/:question_id/options/new', to: 'options#new', as: 'iqtest_question_option_new'

  # Ajoute une route pour la suppression d'une option
  delete 'iqtests/:iqtest_id/questions/:question_id/options/:id', to: 'options#destroy', as: 'iqtest_question_option_destroy'
# Ajoute une route pour la suppression d'une question
  delete 'iqtests/:iqtest_id/questions/:question_id', to: 'questions#destroy', as: 'iqtest_question_destroy'

  # Ajoutez une route pour la prochaine question
  get 'iqtests/:iqtest_id/questions/:id/next', to: 'questions#next_question', as: 'next_question'
# Définition d'un chemin nommé pour accéder à la première question du premier IQTest
  get 'first_question', to: 'questions#first_question'
  # Ajoutez une route pour afficher le score
  get 'iqtests/:iqtest_id/questions/:id/show_score', to: 'questions#show_score', as: 'iqtest_question_show_score'

  # Ajoute les routes pour le CRUD de la ressource IqTest
  resources :iqtests do
    resources :questions, only: [:new, :create,:show, :edit, :update] do
      resources :options, only: [:new, :create, :show, :edit, :update]
    end
  end
  # Ajoute la route pour créer les scores des tests utilisateur
  resources :user_test_scores, only: [:create]

  # Ajoute la route pour supprimer une question
  resources :questions, only: [:destroy]

   # Ajoute la route pour créer un utilisateur à partir d'un invité
  resources :users, only: [:create]
end
