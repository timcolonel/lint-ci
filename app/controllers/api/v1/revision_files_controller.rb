# Revision file controller
class Api::V1::RevisionFilesController < Api::V1::BaseController
  load_and_auth_revision_file parents: true

  def content
    content = github.content(@revision_file)
    value = LintCI::Highlighter.new(@revision_file, content).highlight
    render json: {highlighted: Base64.encode64(value)}
  end

  def search_params
    params.permit(:path)
  end
end
