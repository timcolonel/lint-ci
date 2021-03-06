require 'rails_helper'

RSpec.describe Api::V1::RevisionFilesController do
  let(:owner) { FactoryGirl.create(:user) }
  let(:repository) { FactoryGirl.create(:repository, owner: owner) }
  let(:branch) { FactoryGirl.create(:branch, repository: repository) }
  let(:revision) { FactoryGirl.create(:revision, branch: branch) }
  
  let(:collection_params) { {user: owner.username, repo: repository.name,
                             branch: branch.name, revision: revision.sha} }
  let(:params) { collection_params.merge(file: file.path) }

  describe 'GET #index' do
    before do
      get :index, collection_params
    end

    it { expect(response).to be_success }
    it { expect(response).to have_http_status(200) }
    it { expect(response).to return_json }

    it_has_behavior 'Pagination API', :index do
      let(:records) do
        FactoryGirl.create_list(:revision_file, 3, revision: revision, offense_count: 0)
      end
    end
  end

  describe 'GET #show' do
    let(:file) { FactoryGirl.create(:revision_file, revision: revision) }
    before do
      get :show, params
    end

    it_behaves_like 'successful api request'
    it { expect(json_response[:id]).to eq(file.id) }
    it { expect(json_response[:path]).to eq(file.path) }
  end

  describe 'GET #content' do
    let(:file) { FactoryGirl.create(:revision_file, revision: revision) }
    let(:raw_content) { Faker::Lorem.paragraph }
    let(:content) { Faker::Lorem.paragraph }
    let(:highlighter) { double(:highlighter, highlight: content) }
    let(:github) { double(:github_api, content: content) }
    before do
      allow(controller).to receive(:github).and_return(github)
      allow(LintCI::Highlighter).to receive(:new).and_return(highlighter)
      get :content, params
    end

    it_behaves_like 'successful api request'
    it { expect(LintCI::Highlighter).to have_received(:new) }
    it { expect(highlighter).to have_received(:highlight) }
    it { expect(github).to have_received(:content).with(file) }
    it { expect(Base64.decode64(json_response[:highlighted])).to eq(content) }
  end
end
