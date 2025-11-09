require 'rails_helper'

RSpec.describe Application, type: :model do
  it "generates a token during creation" do
    app = Application.create!(name: "Test")
    expect(app.token).to be_present
    expect(app.token.length).to eq(20)
  end
end
