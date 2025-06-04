require "application_system_test_case"

class PhonesTest < ApplicationSystemTestCase
  setup do
    @phone = phones(:one)
  end

  test "visiting the index" do
    visit phones_url
    assert_selector "h1", text: "Phones"
  end

  test "should create phone" do
    visit phones_url
    click_on "New phone"

    fill_in "Department", with: @phone.department
    fill_in "Mail", with: @phone.mail
    fill_in "Mobile", with: @phone.mobile
    fill_in "Name", with: @phone.name
    fill_in "Number", with: @phone.number
    fill_in "Position", with: @phone.position
    click_on "Create Phone"

    assert_text "Phone was successfully created"
    click_on "Back"
  end

  test "should update Phone" do
    visit phone_url(@phone)
    click_on "Edit this phone", match: :first

    fill_in "Department", with: @phone.department
    fill_in "Mail", with: @phone.mail
    fill_in "Mobile", with: @phone.mobile
    fill_in "Name", with: @phone.name
    fill_in "Number", with: @phone.number
    fill_in "Position", with: @phone.position
    click_on "Update Phone"

    assert_text "Phone was successfully updated"
    click_on "Back"
  end

  test "should destroy Phone" do
    visit phone_url(@phone)
    click_on "Destroy this phone", match: :first

    assert_text "Phone was successfully destroyed"
  end
end
