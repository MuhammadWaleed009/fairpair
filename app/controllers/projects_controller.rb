# frozen_string_literal: true

class ProjectsController < ApplicationController
  # before_action :authorization
  before_action :set_project, except: %i[index create new]

  def index
    @projects = current_user.projects.id_ordered_desc
    authorize @projects
  end

  def show
    @developers = User.where(id: @project.project_developer_ids(current_user))
    @sprints = @project.sprints.count
  end

  def new
    @project = Project.new
  end

  def edit; end

  def create
    @project = current_user.projects.create(project_params)
    if @project.valid?
      respond_to do |format|
        format.html { redirect_to projects_path, notice: 'Project was successfully created.' }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to root_path
    else
      render :edit
    end
  end

  def destroy
    if @project.present?
      redirect_to projects_path, flash: { failure: 'Project cant be deleted' } unless @project.destroy

      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Project was successfully destroyed.' }
        format.turbo_stream
      end
    else
      redirect_to projects_path, flash: { failure: 'Project does not exists.' }
    end
  end

  def manage_developers
    developer_ids = current_user.subordinates.where.not(id: @project.project_developer_ids(current_user))
    @developers = User.where(id: developer_ids)
  end

  def add_developer
    user = fetch_developer
    @project.user_projects.create(user: user)
    redirect_back fallback_location: manage_developers_project_path(@project)
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end

  def fetch_developer
    User.find_by(id: params[:developer_id])
  end

  def set_project
    @project = Project.preload(:user_projects).find_by(id: params[:id])
    return redirect_to root_path if @project.nil?

    authorize @project
  end
end
