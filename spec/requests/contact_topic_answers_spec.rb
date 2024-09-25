require "rails_helper"

RSpec.describe "/contact_topic_answers", type: :request do
  let(:casa_org) { create :casa_org }
  let(:contact_topic) { create :contact_topic, casa_org: }
  let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
  let(:casa_case) { volunteer.casa_cases.first }
  let(:case_contact) { create :case_contact, casa_case:, creator: volunteer }

  let(:valid_attributes) do
    attributes_for(:contact_topic_answer)
      .merge({contact_topic_id: contact_topic.id, case_contact_id: case_contact.id})
  end
  let(:invalid_attributes) { valid_attributes.merge({contact_topic_id: nil}) }

  before { sign_in volunteer }

  describe "POST /create" do
    let(:params) { {contact_topic_answer: valid_attributes} }

    subject { post contact_topic_answers_path, params:, as: :json }

    it "creates a record and responds created" do
      expect { subject }.to change(ContactTopicAnswer, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "returns the record as json" do
      subject
      expect(response.content_type).to match(a_string_including("application/json"))
      answer = ContactTopicAnswer.last
      response_json = JSON.parse(response.body)
      expect(response_json["id"]).to eq answer.id
      expect(response_json.keys)
        .to contain_exactly("id", "contact_topic_id", "value", "case_contact_id", "created_at", "updated_at", "selected")
    end

    context "with invalid parameters" do
      let(:params) { {contact_topic_answer: invalid_attributes} }

      it "fails and responds unprocessable_entity" do
        expect { subject }.to change(ContactTopicAnswer, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns errors as json" do
        subject
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(response.body).to be_present
        response_json = JSON.parse(response.body)
        expect(response_json["contact_topic"]).to include("must exist")
      end
    end

    context "html request" do
      subject { post contact_topic_answers_path, params: }

      it "raises RoutingError" do
        expect { subject }.to raise_error(ActionController::RoutingError)
        expect(response).to be_blank
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:contact_topic_answer) { create :contact_topic_answer, case_contact:, contact_topic: }

    subject { delete contact_topic_answer_url(contact_topic_answer), as: :json }

    it "destroys the record and responds no content" do
      expect { subject }
        .to change(ContactTopicAnswer, :count).by(-1)
      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end

    context "html request" do
      subject { delete contact_topic_answer_url(contact_topic_answer) }

      it "raises RoutingError" do
        expect { subject }.to raise_error(ActionController::RoutingError)
        expect(response).to be_blank
      end
    end
  end
end
