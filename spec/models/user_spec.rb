# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  email              :string           not null
#  phone              :string           not null
#  first_name         :string(255)      not null
#  last_name          :string(255)      not null
#  middle_name        :string(255)
#  role               :integer          default("customer"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  password_digest    :string           not null
#  email_otp_code     :string
#  email_otp_sent_at  :datetime
#  email_otp_attempts :integer          default(0), not null
#  two_factor_enabled :boolean          default(FALSE), not null
#
require "rails_helper"


RSpec.describe User, type: :model do
  subject(:user) { User.new(valid_attributes) }

  let(:valid_attributes) do
    {
      email: "user@example.com",
      phone: "291234567",
      first_name: "John",
      last_name: "Doe",
      password: "password123",
      password_confirmation: "password123"
    }
  end

  describe 'associations' do
    it { should have_many(:bookings).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
    it { should have_one(:cart).dependent(:destroy) }
  end

  context "with valid attributes" do
    it "is valid" do
      expect(user).to be_valid
    end
  end

  context "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:email).is_at_most(255) }
    it { should allow_value("user@example.com").for(:email) }
    it { should_not allow_value("invalid_email").for(:email) }

    it { should validate_presence_of(:phone) }
    it { should validate_uniqueness_of(:phone).case_insensitive } # <-- FIXED
    it { should allow_value("291234567").for(:phone) }
    it { should_not allow_value("12345").for(:phone).with_message(:invalid_phone) }

    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_length_of(:first_name).is_at_most(255) }
    it { should validate_length_of(:last_name).is_at_most(255) }

    it { should validate_length_of(:middle_name).is_at_most(255) }
    it { should allow_value(nil).for(:middle_name) }

    it { should validate_length_of(:password).is_at_least(6).on(:create) }
  end

  context "enums and roles" do
    it "defaults role to customer" do
      expect(user.role).to eq("customer")
      expect(user.role_customer?).to be true
    end

    it "correctly identifies an admin" do
      user.role = :admin
      expect(user.admin?).to be true
      expect(user.manager?).to be true
    end

    it "correctly identifies a manager" do
      user.role = :manager
      expect(user.admin?).to be false
      expect(user.manager?).to be true
    end

    it "correctly identifies a customer" do
      user.role = :customer
      expect(user.admin?).to be false
      expect(user.manager?).to be false
    end
  end

  context "instance methods" do
    it "#full_name returns last name, first name, and middle name" do
      user.middle_name = "William"
      expect(user.full_name).to eq("Doe John William")
    end

    it "#full_name returns last name and first name if middle name is blank" do
      expect(user.full_name).to eq("Doe John")
    end

    it "#formatted_phone formats the number correctly" do
      expect(user.formatted_phone).to eq("+375 (29) 123-45-67")
    end

    it "#formatted_phone returns empty string if phone is blank" do
      user.phone = ""
      expect(user.formatted_phone).to eq("")
    end

    it "#confirmed? reflects the two_factor_enabled status" do
      expect(user.confirmed?).to be false
      user.two_factor_enabled = true
      expect(user.confirmed?).to be true
    end
  end

  describe 'OTP' do
    describe '#email_otp_valid?' do
      let(:user) { create(:user) }

      before do
        user.generate_email_otp!
      end

      it 'returns false if the code has expired' do
        travel_to(User::OTP_TTL.from_now + 1.second) do
          expect(user.email_otp_valid?(user.email_otp_code)).to be false
        end
      end
    end
  end
end
