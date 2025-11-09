class ApplicationsController < ApplicationController
  before_action :set_application, only: [ :show, :update ]

  def index
    apps = Application.all
    render json: apps.as_json(only: [ :token, :name ])
  end

  def show
    render json: @application.as_json(only: [ :token, :name ])
  end

  def create
    app = Application.new(application_params)
    if app.save
      render json: { token: app.token, name: app.name }, status: :created
    else
      render json: { errors: app.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @application.update(application_params)
      render json: @application.as_json(only: [ :token, :name ])
    else
      render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_application
    @application = Application.find_by!(token: params[:token])
  end

  def application_params
    params.require(:application).permit(:name)
  end
end
