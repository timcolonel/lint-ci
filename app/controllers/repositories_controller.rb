# Repositories Api controller
class RepositoriesController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def show

  end

  def badge
    badge = LintCI::Badge.new('Style', @repository.badge_message,
                              @repository.badge_color,
                              params.except(:action))
    send_file badge.file, disposition: 'inline'
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
    github.create_hook(@repository, api_v1_revisions_url) do |hook|
      repo.update(hook_id: hook.id)
    end
  end

  def delete_webhook
    github.remove_hook(@repository, repo.hook_id) do
      repo.update(hook_id: nil)
    end
  end

end
