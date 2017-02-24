require 'rails_helper'

describe 'Creating page' do
  before { login_as create :admin, :scrooge }

  it 'creates a page and removes abandoned images', js: true do
    visit new_page_path

    expect(page).to have_title 'Create Page - Base'
    expect(page).to have_active_navigation_items 'Admin', 'Create Page'
    expect(page).to have_breadcrumbs 'Base', 'Pages', 'Create'
    expect(page).to have_headline 'Create Page'

    fill_in 'page_title',            with: 'new title'
    fill_in 'page_navigation_title', with: 'new navigation title'
    fill_in 'page_content',          with: 'A cool image: ![image](referenced-identifier)'
    fill_in 'page_notes',            with: 'new notes'

    # Let's add an image that is referenced in the content
    expect {
      click_link 'Add image'
    } .to change { all('#images .nested-fields').count }.by 1

    nested_field_id = get_latest_nested_field_id(:page_images)
    fill_in "page_images_attributes_#{nested_field_id}_file", with: base64_image[:data]
    fill_in "page_images_attributes_#{nested_field_id}_identifier", with: 'referenced-identifier'

    # Let's add another image that's not referenced
    click_link 'Add image'
    nested_field_id = get_latest_nested_field_id(:page_images)
    fill_in "page_images_attributes_#{nested_field_id}_file", with: base64_image[:data]
    fill_in "page_images_attributes_#{nested_field_id}_identifier", with: 'abandoned-identifier'

    within '.actions' do
      expect(page).to have_css 'h2', text: 'Actions'

      expect(page).to have_button 'Create Page'
      expect(page).to have_link 'List of Pages'
    end

    scroll_by(0, 10000) # Otherwise the footer overlaps the element and results in a Capybara::Poltergeist::MouseEventFailed, see http://stackoverflow.com/questions/4424790/cucumber-capybara-scroll-to-bottom-of-page

    click_button 'Create Page'

    expect(page).to have_flash 'Page was successfully created.'

    # Only the referenced image is kept
    expect(Image.count).to eq 1
    expect(Image.last.identifier).to eq 'referenced-identifier'
  end

  # See https://github.com/layerssss/paste.js/issues/39
  it 'allows to paste images directly into the textarea'
end