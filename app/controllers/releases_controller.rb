# frozen_string_literal: true
class ReleasesController < ApplicationController
  include CurrentProject

  before_action :authorize_project_deployer!, except: [:show, :index]

  def show
    @release = @project.releases.find_by_version!(params[:id])
    @changeset = @release.changeset
  end

  def index
    @stages = @project.stages
    @releases = @project.releases.sort_by_version.page(params[:page])
  end

  def new
    @release = @project.releases.build
    @release.assign_release_number
  end

  def create
    @release = ReleaseService.new(@project).release!(release_params)
    if @release.persisted?
      redirect_to [@project, @release]
    else
      flash[:error] = @release.errors.full_messages.to_sentence
      render action: :new
    end
  end

  private

  def release_params
    params.require(:release).permit(:commit, :number).merge(author: current_user)
  end
end
