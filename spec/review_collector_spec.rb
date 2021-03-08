require 'review_collector'

RSpec.describe LendingTreeReview do
	subject(:lending_tree_reviews) { described_class.new(lender_type, lender_name, lender_identifier) }

  let(:lender_type) { 'personal' }
	let(:lender_name) { 'first-midwest-bank' }
	let(:lender_identifier) { '52903183' }

	describe ".get_reviews" do
		let(:url) { "http://www.lendingtree.com/reviews/#{lender_type}/#{lender_name}/#{lender_identifier}" }
    let(:response) { HTTParty.get(url) }

    it 'fetches the data from a correct url' do
      expect(response.parsed_response['valid']).to eq "valid"
    end

		it 'should return a response with a lendingtree url' do
			expect(response).not_to be_empty
		end
	end

	describe ".reviews" do
		let(:response) { lending_tree_reviews.reviews }

		it 'should return the review data' do
			expect(response).not_to be_nil
			expect(response).to have_key(:reviews)
		end
		
		it 'should contain a title' do
			expect(response[:reviews][0]).to have_key(:title)
			expect(response[:reviews][0]).to have_value("Great experience!")
		end

		it 'should contain review content' do
			expect(response[:reviews][0]).to have_key(:content)
			expect(response[:reviews][0][:content]).to be_a_kind_of(String)
		end

		it 'should contain an author' do
			expect(response[:reviews][0]).to have_key(:author)
			expect(response[:reviews][0][:author]).to be_a_kind_of(String)
		end

		it 'should contain a star rating' do
			expect(response[:reviews][0]).to have_key(:star_rating)
			expect(response[:reviews][0][:star_rating]).to be_a_kind_of(String)
		end

		it 'should contain a review date' do
			expect(response[:reviews][0]).to have_key(:review_date)
			expect(response[:reviews][0][:review_date]).to be_a_kind_of(String)
		end

		it 'should contain lender recommended information' do
			expect(response[:reviews][0]).to have_key(:recommended_by_reviewer)
			expected_responses = ["Yes", "No"]
			expect(expected_responses).to include(response[:reviews][0][:recommended_by_reviewer])
		end
	end

end