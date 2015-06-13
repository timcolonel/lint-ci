# Repositories Api controller
class RepositoriesController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html

      format.json do
        render json: @repositories, each_serializer: RepositorySerializer
      end
    end
  end

  def show

  end

  def sync
    current_user.sync_repositories
    render json: @repositories
  end

  def enable
    create_webhook
    @repository.enabled = true
    @repository.save
    render json: @repository
  end

  def disable
    delete_webhook
    @repository.enabled = false
    @repository.save
    render json: @repository
  end

  private

  def query_params
    params.permit(:name)
  end

  def init
    @repository = Repository.new
    @repositories = Repository.empty
  end

  def create_webhook
    github.create_hook(@repository, revisions_url) do |hook|
      repo.update(hook_id: hook.id)
    end
  end

  def delete_webhook
    github.remove_hook(@repository, repo.hook_id) do
      repo.update(hook_id: nil)
    end
  end
end
