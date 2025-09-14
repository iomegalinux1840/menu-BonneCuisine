class Admin::SessionsController < ApplicationController
  layout 'admin'
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
  end

  def create
    admin = Admin.authenticate(params[:email], params[:password])

    if admin
      session[:admin_id] = admin.id
      redirect_to admin_menu_items_path, notice: 'Connexion réussie!'
    else
      flash.now[:alert] = 'Email ou mot de passe incorrect'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to root_path, notice: 'Déconnexion réussie!'
  end

  private

  def redirect_if_logged_in
    redirect_to admin_menu_items_path if admin_logged_in?
  end
end